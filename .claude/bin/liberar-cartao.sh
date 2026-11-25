#!/usr/bin/env bash
# Solta o cartão da sessão que o pegou, para outra sessão continuar. Uso: bash .claude/bin/liberar-cartao.sh NNN
# Rodar ao pausar e quando a sessão dona foi fechada sem pausar (com o ok do usuário).

set -euo pipefail
NUM=${1:-}
[[ $NUM =~ ^[0-9]+$ ]] || { echo "uso: bash .claude/bin/liberar-cartao.sh NNN" >&2; exit 2; }
OP="$(cd "$(dirname "$0")/../.." && pwd)/operacao"
achou=0
for d in "$OP"/cartoes/"$(printf '%03d' "$((10#$NUM))")"-*/; do
  [ -d "$d" ] || continue
  achou=1
  rm -f "$d.dono"
  echo "Cartão $(basename "$d") liberado."
done
[ "$achou" = 1 ] || { echo "Cartão $NUM não encontrado em operacao/cartoes/." >&2; exit 1; }
