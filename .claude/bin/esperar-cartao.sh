#!/usr/bin/env bash
# Espera o cartão NNN deixar de estar aberto (concluído, cancelado, pausado, esperando, devolvido ou arquivado).
# Uso: bash .claude/bin/esperar-cartao.sh NNN [minutos, padrão 120]. Sai 0 quando liberou, 1 quando o tempo acabou.

set -uo pipefail
NUM=${1:-}
MAX=${2:-120}
[[ $NUM =~ ^[0-9]+$ && $MAX =~ ^[0-9]+$ ]] || { echo "uso: bash .claude/bin/esperar-cartao.sh NNN [minutos]" >&2; exit 2; }
OP="$(cd "$(dirname "$0")/../.." && pwd)/operacao"
PADRAO="$OP/cartoes/$(printf '%03d' "$((10#$NUM))")-*/cartao.md"
FIM=$(( $(date +%s) + MAX * 60 ))
while :; do
  ARQ=$(compgen -G "$PADRAO" | head -n1)
  if [ -z "$ARQ" ] || grep -qiE '^status:[[:space:]]*(pausad|conclu|cancelad|esperand|devolvid)' "$ARQ"; then
    echo "Cartão $NUM liberou: $( [ -n "$ARQ" ] && grep -m1 -i '^status:' "$ARQ" || echo arquivado)."
    exit 0
  fi
  [ "$(date +%s)" -lt "$FIM" ] || { echo "Cartão $NUM continua aberto depois de $MAX min."; exit 1; }
  sleep "${ESPERA_INTERVALO:-30}"
done
