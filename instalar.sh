#!/usr/bin/env bash
# Cria uma operação nova com o kit Operador ou atualiza o kit de uma operação que já existe.
#
#   bash instalar.sh                  pergunta a pasta, mostra o que muda e pede confirmação
#   bash instalar.sh <pasta>          sem perguntas: aplica
#   bash instalar.sh <pasta> --ver    só mostra o que mudaria
#
# O que é do kit é trocado; o que a operação acrescentou é migrado (settings.json mesclado, linhas próprias
# de padroes-segredos.txt mantidas, texto próprio de .md do kit levado para .claude/rules/kit-migrado.md).
# Tudo o que muda ou sai é copiado antes para operacao/.versoes/kit-<data>/, com REVISAR.md quando há edição local.

set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSAO_NOVA="$(tr -d '[:space:]' < "$KIT/.claude/VERSAO")"
INTERATIVO=1
SO_VER=0
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

parar() { echo "ERRO: $1" >&2; exit 1; }
info() { echo "  $1"; }

caminho() {
  # Resposta colada ou enviada pelo PowerShell pode chegar com BOM e \r.
  local c="${1//$'\r'/}"; c="${c#$'\xef\xbb\xbf'}"
  c="${c#\"}"; c="${c%\"}"; c="${c#\'}"; c="${c%\'}"
  c="${c/#\~/$HOME}"
  if command -v cygpath >/dev/null 2>&1; then cygpath -u "$c"; else printf '%s' "$c"; fi
}
exibir() { if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi; }
perguntar() { local r; read -r -p "$1 " r || true; printf '%s' "${r:-${2:-}}"; }
confirmar() {
  [ "$INTERATIVO" = 0 ] && return 0
  [[ "$(perguntar "$1 [S/n]" s)" =~ ^[sSyY] ]]
}
tem_kit() { compgen -G "$1/.claude/skills/operador-*" >/dev/null; }

hash_de() { git -C "$KIT" hash-object --path="$2" "$1"; }

arquivos_do_kit() {
  (cd "$KIT" && { git ls-files -co --exclude-standard -- CLAUDE.md .claude 2>/dev/null || find CLAUDE.md .claude -type f; } \
    | while IFS= read -r p; do if [ -f "$p" ]; then printf '%s\n' "$p"; fi; done) \
    | grep -v -e '^\.claude/settings\.local\.json$' -e '^\.claude/rules/' | sort -u
}

# "caminho hash" de cada arquivo do kit em todos os commits e na pasta atual.
montar_conhecidos() {
  local c p
  if git -C "$KIT" rev-parse --git-dir >/dev/null 2>&1; then
    for c in $(git -C "$KIT" rev-list --all); do
      git -C "$KIT" ls-tree -r "$c" | awk -F'\t' '{ split($1, a, " "); print $2 " " a[3] }'
    done
  fi
  while read -r p; do echo "$p $(hash_de "$KIT/$p" "$p")"; done < "$TMP/kit.lst"
}
conhecido() { grep -qxF -- "$1 $2" "$TMP/conhecidos"; }
caminho_conhecido() { awk -v p="$1" '$1 == p { achou = 1 } END { exit !achou }' "$TMP/conhecidos"; }
versoes_de() { awk -v p="$1" '$1 == p { print $2 }' "$TMP/conhecidos" | sort -u; }

conteudo_versao() {
  if [ "$(hash_de "$KIT/$1" "$1" 2>/dev/null)" = "$2" ]; then tr -d '\r' < "$KIT/$1"
  else git -C "$KIT" cat-file -p "$2"; fi
}

# Versão conhecida do kit mais parecida com o arquivo da operação (base para mostrar o que ela mudou).
base_mais_proxima() {
  local p=$1 arq=$2 v n menor="" melhor=""
  while read -r v; do
    n=$(diff <(conteudo_versao "$p" "$v") <(tr -d '\r' < "$arq") | wc -l || true)
    if [ -z "$menor" ] || [ "$n" -lt "$menor" ]; then menor=$n; melhor=$v; fi
  done < <(versoes_de "$p")
  printf '%s' "$melhor"
}

mesclar_settings() {
  local novo=$1 antigo=$2 historico="$TMP/settings-historico.json" v
  : > "$historico"
  while read -r v; do conteudo_versao .claude/settings.json "$v" >> "$historico"; echo >> "$historico"; done < <(versoes_de .claude/settings.json)
  jq -n --slurpfile kit "$novo" --slurpfile op "$antigo" --slurpfile hist "$historico" '
    def uniao(a; b): reduce (a + b)[] as $x ([]; if any(.[]; . == $x) then . else . + [$x] end);
    $kit[0] as $k | $op[0] as $o
    | ([$hist[] | .. | .command? // empty]) as $cmds_kit
    | ([$hist[] | keys[]] | unique) as $chaves_kit
    | ([$hist[] | (.permissions // {}) | keys[]] | unique) as $perm_kit
    | (reduce ("allow", "ask", "deny") as $t ({};
        .[$t] = [($o.permissions[$t] // [])[] as $x | select([$hist[] | (.permissions[$t] // [])[]] | index($x) | not) | $x])) as $proprias
    | $k
    + ($o | with_entries(select(.key as $c | $chaves_kit | index($c) | not)))
    | .permissions = (($k.permissions // {})
        + (($o.permissions // {}) | with_entries(select(.key as $c | ($perm_kit | index($c) | not) and (["allow", "ask", "deny"] | index($c) | not))))
        + (reduce ("allow", "ask", "deny") as $t ({};
            (uniao($k.permissions[$t] // []; $proprias[$t])) as $l | if ($l | length) > 0 then .[$t] = $l else . end)))
    | .hooks = (reduce (($o.hooks // {}) | to_entries[]) as $ev (($k.hooks // {});
        reduce $ev.value[] as $g (.;
          ([($g.hooks // [])[] | select(.command as $c | $cmds_kit | index($c) | not)]) as $meus
          | if ($meus | length) > 0 then .[$ev.key] = ((.[$ev.key] // []) + [$g + {hooks: $meus}]) else . end)))
  '
}

# Monta em $TMP/novo/ o que cada arquivo do kit deve ficar sendo nesta operação.
montar_novo() {
  local p op novo base proprias v
  while read -r p; do
    op="$ALVO/$p"; novo="$TMP/novo/$p"
    mkdir -p "$(dirname "$novo")"
    cp "$KIT/$p" "$novo"
    [ -f "$op" ] || continue
    conhecido "$p" "$(hash_de "$op" "$p")" && continue
    case "$p" in
      .claude/settings.json)
        command -v jq >/dev/null 2>&1 || parar "o settings.json da operação tem conteúdo próprio e a mesclagem precisa do jq."
        mesclar_settings "$KIT/$p" "$op" > "$novo" ;;
      .claude/hooks/padroes-segredos.txt)
        base=$(for v in $(versoes_de "$p"); do conteudo_versao "$p" "$v"; done | sort -u)
        proprias=$(grep -vxF -f <(printf '%s\n' "$base") <(tr -d '\r' < "$op") | grep -v -e '^# Da operação$' -e '^$' || true)
        [ -z "$proprias" ] || printf '\n# Da operação\n%s\n' "$proprias" >> "$novo" ;;
    esac
  done < "$TMP/kit.lst"
}

igual() { [ -f "$1" ] && [ -f "$2" ] && diff -q <(tr -d '\r' < "$1") <(tr -d '\r' < "$2") >/dev/null; }

analisar() {
  local p h
  TROCAR=() NOVOS=() EDITADOS=() SAIR=() PROPRIOS=()
  while read -r p; do
    if [ ! -f "$ALVO/$p" ]; then NOVOS+=("$p")
    elif ! igual "$TMP/novo/$p" "$ALVO/$p"; then
      if conhecido "$p" "$(hash_de "$ALVO/$p" "$p")"; then TROCAR+=("$p"); else EDITADOS+=("$p"); fi
    fi
  done < "$TMP/kit.lst"
  while read -r p; do
    grep -qxF -- "$p" "$TMP/kit.lst" && continue
    h=$(hash_de "$ALVO/$p" "$p")
    if conhecido "$p" "$h"; then SAIR+=("$p")
    elif caminho_conhecido "$p" && [[ $p != .claude/rules/* ]]; then SAIR+=("$p"); EDITADOS+=("$p")
    else PROPRIOS+=("$p"); fi
  done < <(cd "$ALVO" && find CLAUDE.md .claude -type f 2>/dev/null | grep -v -e '^\.claude/settings\.local\.json$' | sort)
}

mostrar() {
  local p
  for p in "${NOVOS[@]}"; do echo "  novo      $p"; done
  for p in "${TROCAR[@]}"; do echo "  troca     $p (versão antiga do kit)"; done
  for p in "${EDITADOS[@]}"; do
    case "$p" in
      .claude/settings.json) echo "  mescla    $p (o kit novo mais as permissões, hooks e chaves da operação)" ;;
      .claude/hooks/padroes-segredos.txt) echo "  mescla    $p (o kit novo mais as linhas da operação)" ;;
      *.md) echo "  migra     $p (editado na operação: o texto próprio vai para .claude/rules/kit-migrado.md)" ;;
      *) echo "  revisar   $p (editado na operação: o antigo fica na cópia, com a diferença em REVISAR.md)" ;;
    esac
  done
  for p in "${SAIR[@]}"; do echo "  sai       $p (o kit não tem mais; vai para a cópia)"; done
  [ ${#PROPRIOS[@]} -eq 0 ] || echo "  ficam ${#PROPRIOS[@]} arquivo(s) da operação em .claude/ (rules, skills e agentes próprios)"
}

migrar_md() {
  local p=$1 antigo=$2 base proprio
  base=$(base_mais_proxima "$p" "$antigo")
  proprio=$(diff <(conteudo_versao "$p" "$base") <(tr -d '\r' < "$antigo") | sed -n 's/^> //p' || true)
  [ -n "$(printf '%s' "$proprio" | tr -d '[:space:]')" ] || return 0
  mkdir -p "$ALVO/.claude/rules"
  [ -f "$ALVO/.claude/rules/kit-migrado.md" ] || printf '# Texto da operação que estava em arquivos do kit\n\nVeio da atualização do kit. Revise: mantenha aqui, mova para operacao.md ou apague o que o kit novo já cobre.\n' > "$ALVO/.claude/rules/kit-migrado.md"
  printf '\n## De %s (atualização %s)\n\n%s\n' "$p" "$CARIMBO" "$proprio" >> "$ALVO/.claude/rules/kit-migrado.md"
}

registrar_revisao() {
  local p=$1 antigo=$2 base
  base=$(base_mais_proxima "$p" "$antigo")
  {
    printf '\n## %s\n\nDiferença entre a versão do kit mais parecida e a da operação (o arquivo antigo inteiro está nesta pasta):\n\n```diff\n' "$p"
    diff -u <(conteudo_versao "$p" "$base") <(tr -d '\r' < "$antigo") | tail -n +3 || true
    printf '```\n'
  } >> "$GUARDA/REVISAR.md"
}

aplicar() {
  local p
  CARIMBO="$(date +%Y-%m-%d-%H%M%S)"
  GUARDA="$ALVO/operacao/.versoes/kit-$CARIMBO"
  mkdir -p "$GUARDA"
  for p in "${TROCAR[@]}" "${EDITADOS[@]}" "${SAIR[@]}"; do
    [ -f "$ALVO/$p" ] || continue
    mkdir -p "$(dirname "$GUARDA/$p")"
    cp -p "$ALVO/$p" "$GUARDA/$p"
  done
  for p in "${EDITADOS[@]}"; do
    case "$p" in
      .claude/settings.json|.claude/hooks/padroes-segredos.txt) ;;
      *.md) migrar_md "$p" "$GUARDA/$p"; registrar_revisao "$p" "$GUARDA/$p" ;;
      *) registrar_revisao "$p" "$GUARDA/$p" ;;
    esac
  done
  [ ! -f "$GUARDA/REVISAR.md" ] || sed -i '1i # Revisar depois da atualização do kit' "$GUARDA/REVISAR.md"
  for p in "${SAIR[@]}"; do
    rm -f "$ALVO/$p"
    rmdir -p --ignore-fail-on-non-empty "$(dirname "$ALVO/$p")" 2>/dev/null || true
  done
  for p in "${NOVOS[@]}" "${TROCAR[@]}" "${EDITADOS[@]}"; do
    grep -qxF -- "$p" "$TMP/kit.lst" || continue
    mkdir -p "$(dirname "$ALVO/$p")"
    cp "$TMP/novo/$p" "$ALVO/$p"
  done
  [ "$(ls -A "$GUARDA")" ] || rmdir "$GUARDA"
}

autoteste() {
  [ -n "${INSTALAR_SEM_AUTOTESTE:-}" ] && return 0
  echo
  echo "Autotestes do kit (cerca de 1 minuto):"
  (cd "$ALVO" && bash .claude/bin/testar-hooks.sh 2>&1 | tail -n 1) || echo "  Falharam: rode na pasta da operação bash .claude/bin/testar-hooks.sh"
}

instalar_novo() {
  echo "Pasta nova: o kit $VERSAO_NOVA será copiado para $(exibir "$ALVO")."
  [ "$SO_VER" = 1 ] && return 0
  confirmar "Criar a operação?" || { echo "Nada foi alterado."; exit 0; }
  mkdir -p "$ALVO"
  while read -r p; do mkdir -p "$(dirname "$ALVO/$p")"; cp "$KIT/$p" "$ALVO/$p"; done < "$TMP/kit.lst"
  echo "Kit $VERSAO_NOVA instalado em $(exibir "$ALVO")."
  autoteste
  echo
  echo "Próximo passo: abra o Claude Code (aba Code do app) na pasta $(exibir "$ALVO") e rode /operador-iniciar."
}

atualizar() {
  local anterior="sem VERSAO"
  [ -f "$ALVO/.claude/VERSAO" ] && anterior="$(tr -d '[:space:]' < "$ALVO/.claude/VERSAO")"
  echo "Kit encontrado em $(exibir "$ALVO") (versão $anterior). Nova: $VERSAO_NOVA."
  git -C "$KIT" rev-parse --git-dir >/dev/null 2>&1 || info "Sem o .git do kit: só a versão atual é reconhecida; o resto vai para revisão (nada se perde)."
  montar_conhecidos > "$TMP/conhecidos"
  montar_novo
  analisar
  if [ $(( ${#NOVOS[@]} + ${#TROCAR[@]} + ${#EDITADOS[@]} + ${#SAIR[@]} )) -eq 0 ]; then
    echo "O kit já está atualizado. Nada muda."
    return 0
  fi
  mostrar
  if [ -f "$ALVO/operacao/QUADRO.md" ] && grep -qi "levar ao kit" "$ALVO/operacao/QUADRO.md"; then
    echo
    echo "Itens do quadro para levar ao kit:"
    grep -i "levar ao kit" "$ALVO/operacao/QUADRO.md" | sed 's/^/  /'
  fi
  [ "$SO_VER" = 1 ] && { echo; echo "Nada foi alterado (--ver)."; return 0; }
  echo
  echo "Feche antes as sessões do Claude Code abertas nesta operação."
  confirmar "Aplicar?" || { echo "Nada foi alterado."; exit 0; }
  aplicar
  echo
  echo "Kit atualizado para $VERSAO_NOVA. O quadro, operacao/docs/ e os cartões não foram tocados."
  [ -d "$GUARDA" ] && info "O que mudou ou saiu está copiado em $(exibir "$GUARDA")."
  [ -f "$GUARDA/REVISAR.md" ] && info "Há edições locais para revisar: $(exibir "$GUARDA/REVISAR.md")."
  [ -f "$ALVO/.claude/rules/kit-migrado.md" ] && info "Texto próprio migrado: .claude/rules/kit-migrado.md (carregado em toda sessão)."
  autoteste
}

principal() {
  local pai nome sugerida
  command -v git >/dev/null 2>&1 || parar "falta o git (Git for Windows): ele dá o bash e reconhece as versões do kit."
  if [ $# -eq 0 ]; then
    echo "Operador $VERSAO_NOVA"
    sugerida="$(dirname "$KIT")"
    pai="$(caminho "$(perguntar "Pasta onde fica (ou vai ficar) a operação [$(exibir "$sugerida")]:" "$sugerida")")"
    nome="$(perguntar "Nome da pasta da operação:")"; nome="${nome//$'\r'/}"
    [ -n "$nome" ] || parar "informe o nome da pasta."
    ALVO="${pai%/}/$nome"
  else
    INTERATIVO=0
    ALVO="$(caminho "$1")"
    case "${2:-}" in "") ;; --ver) SO_VER=1 ;; *) parar "opção desconhecida: $2 (use --ver)." ;; esac
  fi
  ALVO="${ALVO%/}"
  if [ -d "$ALVO" ]; then ALVO="$(cd "$ALVO" && pwd)"; fi
  case "$ALVO/" in "$KIT/"*) parar "a operação não pode ficar dentro da pasta do kit." ;; esac
  case "$KIT/" in "$ALVO/"*) parar "o kit não pode ficar dentro da pasta da operação." ;; esac
  arquivos_do_kit > "$TMP/kit.lst"
  if tem_kit "$ALVO"; then atualizar; return; fi
  [ -z "$(ls -A "$ALVO" 2>/dev/null)" ] || parar "$(exibir "$ALVO") não está vazia e não tem o kit. Use uma pasta nova."
  instalar_novo
}

principal "$@"
