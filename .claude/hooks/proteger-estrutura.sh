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
#   cartao.md novo, ou pausado voltando ao trabalho: negado se já há o limite de cartões abertos.
#   Com limite acima de 1: o cartão é da sessão que o editou por último (.dono: sessão, hora, alvos); outra
#   sessão é negada enquanto a dona editou há menos de DONO_MINUTOS (depois disso, assume); "Alvos:" em
#   comum com outro cartão aberto pede confirmação; Write em quadro, ambiente e histórico existentes é negado.
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

gravar_dono() { mkdir -p "$(dirname "$dono")"; printf '%s\n%s\n%s\n' "${SESSAO:-sem-sessao}" "$(agora)" "$alvos" > "$dono"; }

# Imprime o cartão aberto (de outra pasta) com alvo em comum e o par em conflito.
conflito_de_alvos() {
  local outra linha comum
  [ -n "$alvos" ] && [ "$limite" -gt 1 ] || return 1
  while IFS='|' read -r outra linha _; do
    [ "${outra,,}" = "${pasta,,}" ] && continue
    if comum=$(alvos_em_comum "$alvos" "$linha"); then printf '%s (%s)' "$outra" "$comum"; return 0; fi
  done <<< "$ABERTOS"
  return 1
}
perguntar_conflito() {
  perguntar_ferramenta "Alvos em comum com o cartão aberto $1. Dois cartões mexendo no mesmo alvo podem atrapalhar um ao outro. Confirme só se o usuário decidiu seguir assim; senão, espere, pause o outro ou junte os dois num cartão só."
}

conferir_paralelo() {
  local limite pasta dono alvos status abertos=0 outra sessao_dona="" quando="" alvos_antes="" novos_alvos="" conflito reabrir=""
  limite=$(limite_paralelo)
  if [[ $NO_OP_N =~ ^cartoes/([^/_][^/]*)/cartao\.md$ ]]; then
    pasta=${BASH_REMATCH[1]}
    dono="$RAIZ/$PASTA_OPERACAO/cartoes/$pasta/.dono"
    alvos="" status=""
    [[ $CONTEUDO =~ (^|$'\n')[Aa]lvos:[[:space:]]*([^$'\r\n']*) ]] && alvos=${BASH_REMATCH[2]}
    [[ $CONTEUDO =~ (^|$'\n')[Ss]tatus:[[:space:]]*([^[:space:]]+) ]] && status=${BASH_REMATCH[2],,}
    unset ABERTOS
    if [ ! -f "$RAIZ/$REL" ]; then reabrir=1
    elif [ -n "$status" ] && ! [[ $status =~ ^(pausad|conclu|cancelad) ]]; then
      ABERTOS=$(cartoes_abertos)
      grep -qi "^$pasta|" <<< "$ABERTOS" || reabrir=1
    fi
    if [ -n "$reabrir" ]; then
      travar_abertura
      ABERTOS=$(cartoes_abertos)
      while IFS='|' read -r outra _; do [ -z "$outra" ] || [ "${outra,,}" = "${pasta,,}" ] || abertos=$((abertos + 1)); done <<< "$ABERTOS"
      if [ "$abertos" -ge "$limite" ]; then
        soltar_abertura
        negar_ferramenta "Já há $abertos cartão(ões) aberto(s) ($(cut -d'|' -f1 <<< "$ABERTOS" | paste -sd' ' -)) e esta operação aceita $limite por vez (linha \"Cartões em paralelo\" de $PASTA_OPERACAO/docs/operacao.md). Pause (/operador-pausar) ou encerre um, ou peça ao usuário para aumentar o limite."
      fi
      conflito=$(conflito_de_alvos) || conflito=""
      gravar_dono
      soltar_abertura
      [ -z "$conflito" ] || perguntar_conflito "$conflito"
      return 0
    fi
    [ "$limite" -gt 1 ] || return 0
    [ -n "${ABERTOS+x}" ] || ABERTOS=$(cartoes_abertos)
    [ ! -f "$dono" ] || { read -r sessao_dona; read -r quando; read -r alvos_antes; } < "$dono"
    sessao_dona=${sessao_dona%$'\r'} quando=${quando%$'\r'} alvos_antes=${alvos_antes%$'\r'}
    novos_alvos=$alvos
    if [ -n "$SESSAO" ] && grep -qi "^$pasta|" <<< "$ABERTOS"; then
      if [ -n "$sessao_dona" ] && [ "$sessao_dona" != "$SESSAO" ] && [[ $quando =~ ^[0-9]+$ ]] \
        && [ $(( $(agora) - quando )) -lt $((DONO_MINUTOS * 60)) ]; then
        negar_ferramenta "O cartão $pasta está com outra sessão do Claude Code, que o editou há $(( ($(agora) - quando) / 60 )) min. Trabalhe no seu cartão. Se aquela sessão foi fechada, mostre isto ao usuário: com o ok dele, rode bash .claude/bin/liberar-cartao.sh ${pasta%%-*} (ou espere $DONO_MINUTOS min sem edição dela)."
      fi
      [ -n "$alvos" ] || alvos=$alvos_antes
      gravar_dono
    fi
    if [ -n "$novos_alvos" ] && [ "$novos_alvos" != "$alvos_antes" ] && conflito=$(conflito_de_alvos); then
      perguntar_conflito "$conflito"
    fi
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
