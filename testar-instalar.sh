#!/usr/bin/env bash
# Autoteste do instalar.sh numa pasta temporária. Uso, no clone do kit: bash testar-instalar.sh

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="$(mktemp -d)"
trap "rm -rf \"$BASE\"" EXIT
FALHAS=0
export INSTALAR_SEM_AUTOTESTE=1

ok() { echo "ok    $1"; }
falha() { echo "FALHA $1"; FALHAS=$((FALHAS + 1)); }
checar() { local nome=$1; shift; if "$@" >/dev/null 2>&1; then ok "$nome"; else falha "$nome"; fi; }
instalar() { bash "$KIT/instalar.sh" "$@"; }
retrato() { (cd "$1" && find . -type f -exec sha1sum {} + | sort); }

command -v jq >/dev/null 2>&1 || { echo "Precisa do jq."; exit 1; }
ANTIGO="$(git -C "$KIT" log -n1 --format=%H -- .claude/rules/parametros.md 2>/dev/null)~1"
git -C "$KIT" rev-parse -q --verify "$ANTIGO" >/dev/null || { echo "Precisa do histórico git do kit."; exit 1; }

N="$BASE/nova"
instalar "$N" --ver >/dev/null
checar "pasta nova com --ver não é criada" test ! -e "$N"
instalar "$N" >/dev/null
checar "pasta nova recebe o kit inteiro" diff -rq -x settings.local.json -x rules "$KIT/.claude" "$N/.claude"
checar "pasta nova recebe VERSAO" diff -q "$KIT/.claude/VERSAO" "$N/.claude/VERSAO"
checar "pasta nova não recebe README nem instalador" test ! -e "$N/README.md" -a ! -e "$N/instalar.sh"

O="$BASE/antiga"
mkdir -p "$O"
git -C "$KIT" archive "$ANTIGO" CLAUDE.md .claude | tar -x -C "$O"
mkdir -p "$O/.claude/rules" "$O/.claude/skills/minha-skill" "$O/operacao/docs"
echo 'REGRA-PROPRIA' > "$O/.claude/rules/operacao.md"
echo 'SKILL-PROPRIA' > "$O/.claude/skills/minha-skill/SKILL.md"
echo 'echo HOOK-PROPRIO' > "$O/.claude/hooks/meu-hook.sh"
printf '\nLINHA-PROPRIA-DO-CLAUDE-MD\n' >> "$O/CLAUDE.md"
echo 'PADRAO-PROPRIO-[0-9]{40}' >> "$O/.claude/hooks/padroes-segredos.txt"
jq 'del(.hooks.PreToolUse[] | select(.matcher == "mcp__.*"))
    | .permissions.deny += ["mcp__gmail__send_message"]
    | .hooks.PostToolUse = [{"matcher": "Edit", "hooks": [{"type": "command", "command": "bash meu-hook.sh"}]}]
    | .env = {"MINHA_VAR": "1"}' "$O/.claude/settings.json" > "$O/settings.tmp" && mv "$O/settings.tmp" "$O/.claude/settings.json"
echo '{"permissions":{"allow":["Bash(ssh casa *)"]}}' > "$O/.claude/settings.local.json"
printf '# Quadro\n- #009 Levar ao kit: teste\n' > "$O/operacao/QUADRO.md"
echo 'AMBIENTE' > "$O/operacao/docs/ambiente.md"
ANTES="$(retrato "$O")"

SAIDA="$(instalar "$O" --ver)"
checar "--ver não altera a operação" test "$ANTES" = "$(retrato "$O")"
checar "--ver mostra a mesclagem do settings.json" grep -q "mescla.*settings.json" <<< "$SAIDA"
checar "--ver mostra a migração do CLAUDE.md" grep -q "migra.*CLAUDE.md" <<< "$SAIDA"
checar "--ver lista o que levar ao kit" grep -q "Levar ao kit: teste" <<< "$SAIDA"

instalar "$O" >/dev/null
G="$(ls -d "$O"/operacao/.versoes/kit-* 2>/dev/null | head -n1)"
checar "kit trocado" diff -q "$KIT/.claude/hooks/comum.sh" "$O/.claude/hooks/comum.sh"
checar "CLAUDE.md é o do kit novo" diff -q "$KIT/CLAUDE.md" "$O/CLAUDE.md"
checar "texto próprio do CLAUDE.md migrado para rules" grep -q LINHA-PROPRIA-DO-CLAUDE-MD "$O/.claude/rules/kit-migrado.md"
checar "rule própria intacta" grep -qx REGRA-PROPRIA "$O/.claude/rules/operacao.md"
checar "skill própria intacta" grep -qx SKILL-PROPRIA "$O/.claude/skills/minha-skill/SKILL.md"
checar "hook próprio intacto" grep -qx 'echo HOOK-PROPRIO' "$O/.claude/hooks/meu-hook.sh"
checar "settings.json mantém o deny próprio" jq -e '.permissions.deny | index("mcp__gmail__send_message")' "$O/.claude/settings.json"
checar "settings.json mantém o hook próprio" jq -e '[.. | .command? // empty] | index("bash meu-hook.sh")' "$O/.claude/settings.json"
checar "settings.json mantém a chave própria" jq -e '.env.MINHA_VAR == "1"' "$O/.claude/settings.json"
checar "settings.json tem as travas novas do kit" jq -e '[.. | .command? // empty] | any(test("proteger-mcp"))' "$O/.claude/settings.json"
checar "settings.json sem regra duplicada" jq -e '.permissions | [.allow // [], .ask // [], .deny // []] | all(length == (unique | length))' "$O/.claude/settings.json"
checar "padrão de segredo próprio mantido" grep -qxF 'PADRAO-PROPRIO-[0-9]{40}' "$O/.claude/hooks/padroes-segredos.txt"
checar "arquivo que saiu do kit é removido" test ! -e "$O/.claude/rules/parametros.md"
checar "o que saiu fica na cópia" test -f "$G/.claude/rules/parametros.md"
checar "o CLAUDE.md antigo fica na cópia" grep -q LINHA-PROPRIA-DO-CLAUDE-MD "$G/CLAUDE.md"
checar "edição local aparece em REVISAR.md" grep -q LINHA-PROPRIA-DO-CLAUDE-MD "$G/REVISAR.md"
checar "settings.local.json intacto" grep -q 'ssh casa' "$O/.claude/settings.local.json"
checar "quadro e docs intactos" grep -qx AMBIENTE "$O/operacao/docs/ambiente.md"

DEPOIS="$(retrato "$O")"
SAIDA="$(instalar "$O")"
checar "segunda rodada diz que nada muda" grep -q "Nada muda" <<< "$SAIDA"
checar "segunda rodada não altera nenhum arquivo" test "$DEPOIS" = "$(retrato "$O")"

mkdir -p "$BASE/outra" && echo x > "$BASE/outra/a.txt"
if instalar "$BASE/outra" >/dev/null 2>&1; then falha "recusa pasta com outra coisa"; else ok "recusa pasta com outra coisa"; fi
if instalar "$KIT/.claude" >/dev/null 2>&1; then falha "recusa pasta dentro do kit"; else ok "recusa pasta dentro do kit"; fi

C="$BASE/clone"
mkdir -p "$C" && cp -r "$KIT/instalar.sh" "$KIT/CLAUDE.md" "$KIT/.claude" "$C/"
SAIDA="$(printf '\nop-sugerida\nn\n' | bash "$C/instalar.sh" 2>&1)"
checar "Enter na pergunta da pasta usa a pasta ao lado do kit" grep -q "Pasta nova.*op-sugerida" <<< "$SAIDA"
checar "responder n não cria a operação" test ! -e "$BASE/op-sugerida"

echo
if [ "$FALHAS" -eq 0 ]; then echo "O instalador passou em tudo."; else echo "$FALHAS falha(s)."; exit 1; fi
