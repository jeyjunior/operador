#!/usr/bin/env bash
# Hook PreToolUse (Edit|Write|MultiEdit): estrutura do Root e papéis.
#   operacao/parametros/   negado a todos.
#   operacao/              gerente: liberado. Subagente: só cartoes/<cartão>/entregas/ e backups/.
#   kit (CLAUDE.md, README.md, .claude/, .mcp.json)   gerente: liberado. Subagente: negado.
#   qualquer outra coisa no Root: negado.
#   fora do Root: gerente liberado; executor liberado, menos config do Claude, ~/.ssh e outra operação;
#   demais subagentes e conta secundária: negado.

ENTRADA=$(cat)
source "$(dirname "${BASH_SOURCE[0]}")/comum.sh"

ler_entrada "$ENTRADA"
ARQ=$ARQ_ENTRADA
[ -n "$ARQ" ] || exit 0
REL=$(relativo_a_raiz "$ARQ")
SUB=""
eh_subagente && SUB=1

# Cartões abertos ao mesmo tempo (veja "Cartões em paralelo" no CLAUDE.md). Só o gerente passa por aqui.
#   cartao.md novo: negado se já há o limite de cartões abertos (1 sem a linha em operacao.md).
#   Com limite acima de 1: o cartão é da sessão que o editou primeiro (.dono); outra sessão é negada até
#   liberar-cartao.sh; "Alvos:" em comum com outro cartão aberto é negado; Write em quadro, ambiente e
#   histórico existentes é negado (Edit recusa texto que outra sessão mudou depois da leitura; Write não).
TRAVA_ABERTURA="$RAIZ/$PASTA_OPERACAO/.ids/.abrindo"
travar_abertura() {
  local i
  mkdir -p "$(dirname "$TRAVA_ABERTURA")"
  for i in $(seq 1 100); do
    mkdir "$TRAVA_ABERTURA" 2>/dev/null && { TRAVADO=1; return 0; }
    [ -n "$(find "$TRAVA_ABERTURA" -maxdepth 0 -mmin +1 2>/dev/null)" ] && rmdir "$TRAVA_ABERTURA" 2>/dev/null
    sleep 0.1
  done
}
soltar_abertura() { [ -z "${TRAVADO:-}" ] || rmdir "$TRAVA_ABERTURA" 2>/dev/null || true; TRAVADO=""; }

conferir_alvos() {
  local outra linha comum
  [ -n "$alvos" ] && [ "$limite" -gt 1 ] || return 0
  while IFS='|' read -r outra linha _; do
    [ "${outra,,}" = "${pasta,,}" ] && continue
    if comum=$(alvos_em_comum "$alvos" "$linha"); then
      soltar_abertura
      negar_ferramenta "Alvos em conflito com o cartão aberto $outra ($comum). Dois cartões não mexem no mesmo alvo ao mesmo tempo: pause ou encerre o outro, ou junte os dois num cartão só."
    fi
  done < <(cartoes_abertos)
}

conferir_paralelo() {
  local limite pasta dono linha outra alvos comum abertos=0
  limite=$(limite_paralelo)
  if [[ $NO_OP_N =~ ^cartoes/([^/_][^/]*)/cartao\.md$ ]]; then
    pasta=${BASH_REMATCH[1]}
    dono="$RAIZ/$PASTA_OPERACAO/cartoes/$pasta/.dono"
    alvos=$(printf '%s\n' "$CONTEUDO" | grep -m1 -iE '^Alvos:' | tr -d '\r' | sed 's/^Alvos:[[:space:]]*//I')
    if [ ! -f "$RAIZ/$REL" ] && [ ! -f "$dono" ]; then
      travar_abertura
      while IFS='|' read -r outra _ _; do [ "${outra,,}" = "${pasta,,}" ] || abertos=$((abertos + 1)); done < <(cartoes_abertos)
      if [ "$abertos" -ge "$limite" ]; then
        soltar_abertura
        negar_ferramenta "Já há $abertos cartão(ões) aberto(s) e esta operação aceita $limite por vez (linha \"Cartões em paralelo\" de $PASTA_OPERACAO/docs/operacao.md). Pause (/operador-pausar) ou encerre um, ou peça ao usuário para aumentar o limite."
      fi
      conferir_alvos
      mkdir -p "$(dirname "$dono")"
      printf '%s\n%s\n' "${SESSAO:-sem-sessao}" "$alvos" > "$dono"
      soltar_abertura
      return 0
    fi
    [ "$limite" -gt 1 ] || return 0
    if [ -n "$SESSAO" ]; then
      mkdir -p "$(dirname "$dono")"
      (set -o noclobber; printf '%s\n' "$SESSAO" > "$dono") 2>/dev/null || true
      linha=$(head -n1 "$dono" 2>/dev/null | tr -d '\r')
      if [ -n "$linha" ] && [ "$linha" != "$SESSAO" ]; then
        negar_ferramenta "O cartão $pasta está com outra sessão do Claude Code. Trabalhe no seu cartão. Se a outra sessão foi fechada, com o ok do usuário rode: bash .claude/bin/liberar-cartao.sh ${pasta%%-*}"
      fi
    fi
    conferir_alvos
    return 0
  fi
  [ "$limite" -gt 1 ] || return 0
  case "$NO_OP_N" in
    quadro.md|docs/ambiente.md|docs/historico.md)
      if [ "$FERRAMENTA" = Write ] && [ -f "$RAIZ/$REL" ]; then
        negar_ferramenta "Com cartões em paralelo, $REL muda só pela ferramenta Edit (trecho a trecho), para uma sessão não apagar o que a outra gravou."
      fi ;;
  esac
}

if fora_do_root "$REL"; then
  [ -n "$SUB" ] || exit 0
  eh_executor || negar_ferramenta "Este papel não grava fora da operação ($REL). Grave em $PASTA_OPERACAO/cartoes/<cartão>/entregas/."
  if [[ "/${REL,,}" =~ /(\.claude[^/]*|\.ssh|$PASTA_OPERACAO)/ ]]; then
    negar_ferramenta "Subagente não grava em configuração do Claude, em ~/.ssh nem em outra operação ($REL)."
  fi
  exit 0
fi

if NO_OP=$(dentro_de "$PASTA_OPERACAO" "$REL"); then
  NO_OP_N=${NO_OP,,}
  if [[ $NO_OP_N == parametros/* ]]; then
    negar_ferramenta "$PASTA_OPERACAO/parametros/ é do usuário: o Claude não lê nem grava nessa pasta."
  fi
  if [ -n "$SUB" ] && ! [[ $NO_OP_N =~ ^cartoes/[^/]+/(entregas|backups)/.+ ]]; then
    negar_ferramenta "Subagente só grava em $PASTA_OPERACAO/cartoes/<cartão>/entregas/ ou backups/ ($REL). Quadro, cartao.md e docs/ são do gerente: devolva o conteúdo na resposta."
  fi
  [ -z "$SUB" ] && conferir_paralelo
  exit 0
fi

case "${REL,,}" in
  claude.md|claude.local.md|readme.md|.gitignore|.mcp.json|.claude/*)
    [ -n "$SUB" ] && negar_ferramenta "Subagente não altera o kit ($REL). Devolva a sugestão ao gerente."
    exit 0 ;;
esac

negar_ferramenta "No Root só ficam o kit (CLAUDE.md, README.md, .claude/, .mcp.json) e $PASTA_OPERACAO/. Não crie nada fora disso ($REL): arquivo gerado vai para $PASTA_OPERACAO/cartoes/<cartão>/entregas/."
