#!/usr/bin/env bash
# Hook PreToolUse e PostToolUse (Edit|Write|MultiEdit), com cartões em paralelo: uma sessão por vez grava no
# quadro, no ambiente.md e no historico.md. Uso: bash vez.sh pegar | soltar
# A vez é uma pasta (mkdir é atômico) com o id da sessão. Com a vez, a checagem da ferramenta Edit
# ("o arquivo mudou depois da leitura?") e a gravação acontecem sem outra sessão no meio.
# Vez esquecida (gravação negada por outro hook, sessão que caiu) vence em 15 s.

ENTRADA=$(cat)
case "$ENTRADA" in *QUADRO.md*|*ambiente.md*|*historico.md*) ;; *) exit 0 ;; esac
source "$(dirname "${BASH_SOURCE[0]}")/comum.sh"
ler_entrada "$ENTRADA"
[ -n "$ARQ_ENTRADA" ] || exit 0
REL=$(relativo_a_raiz "$ARQ_ENTRADA")
case "${REL,,}" in
  "$PASTA_OPERACAO"/quadro.md|"$PASTA_OPERACAO"/docs/ambiente.md|"$PASTA_OPERACAO"/docs/historico.md) ;;
  *) exit 0 ;;
esac
[ "$(limite_paralelo)" -gt 1 ] || exit 0

VEZ="$RAIZ/$PASTA_OPERACAO/.ids/.gravando"
QUEM="${SESSAO:-sem-sessao}"
dona() { head -n1 "$VEZ/sessao" 2>/dev/null | tr -d '\r'; }

case "${1:-}" in
  pegar)
    mkdir -p "$(dirname "$VEZ")"
    for i in $(seq 1 80); do
      if mkdir "$VEZ" 2>/dev/null; then printf '%s\n' "$QUEM" > "$VEZ/sessao"; exit 0; fi
      [ "$(dona)" = "$QUEM" ] && exit 0
      if [ -n "$(find "$VEZ" -maxdepth 0 -newermt '15 seconds ago' 2>/dev/null)" ]; then sleep 0.1; continue; fi
      rm -rf "$VEZ"
    done
    exit 0 ;;
  soltar)
    [ "$(dona)" = "$QUEM" ] && rm -rf "$VEZ"
    exit 0 ;;
esac
exit 0
