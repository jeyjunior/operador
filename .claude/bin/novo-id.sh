#!/usr/bin/env bash
# Reserva o próximo #NNN da operação e o imprime. Uso: bash .claude/bin/novo-id.sh
# A reserva é uma pasta em operacao/.ids/: mkdir é atômico, então duas sessões ao mesmo tempo nunca
# recebem o mesmo número. Parte do maior número já usado (cartões, arquivo, quadro, "Próximo ID" antigo).

set -euo pipefail
OP="$(cd "$(dirname "$0")/../.." && pwd)/operacao"
[ -d "$OP" ] || { echo "operacao/ não existe: rode /operador-iniciar." >&2; exit 2; }
mkdir -p "$OP/.ids"

maior=0
usar() { local n=$((10#$1)); [ "$n" -gt "$maior" ] && maior=$n; return 0; }
for d in "$OP"/.ids/[0-9]* "$OP"/cartoes/[0-9]* "$OP"/cartoes/_arquivo/[0-9]*; do
  [ -e "$d" ] || continue
  n=$(basename "$d" | grep -oE '^[0-9]+' || true)
  [ -n "$n" ] && usar "$n"
done
if [ -f "$OP/QUADRO.md" ]; then
  for n in $(grep -oE '#[0-9]{1,5}' "$OP/QUADRO.md" | tr -d '#'); do usar "$n"; done
  proximo=$(grep -m1 -iE 'Próximo ID' "$OP/QUADRO.md" | grep -oE '[0-9]+' | head -n1 || true)
  [ -n "$proximo" ] && usar "$((10#$proximo - 1))"
fi

n=$((maior + 1))
until mkdir "$OP/.ids/$(printf '%03d' "$n")" 2>/dev/null; do n=$((n + 1)); done
printf '%03d\n' "$n"
