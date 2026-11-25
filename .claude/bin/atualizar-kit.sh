#!/usr/bin/env bash
# Instala ou atualiza o kit numa pasta de operação. Roda a partir do clone do kit.
# Uso: bash .claude/bin/atualizar-kit.sh <pasta-da-operacao> [--aplicar]
# Sem --aplicar só mostra o que mudaria. Com --aplicar, o que o kit troca vai antes para
# operacao/.versoes/kit-<data>/ (nada se perde). Não toca em .claude/rules/, settings.local.json, .mcp.json
# nem operacao/, que são da operação.

set -euo pipefail
KIT=$(cd "$(dirname "$0")/../.." && pwd)
ALVO=${1:-}
MODO=${2:-}

uso() { echo "uso: bash .claude/bin/atualizar-kit.sh <pasta-da-operacao> [--aplicar]" >&2; exit 2; }
[ -n "$ALVO" ] || uso
[ -z "$MODO" ] || [ "$MODO" = --aplicar ] || uso

if [ ! -d "$ALVO" ]; then
  [ "$MODO" = --aplicar ] || { echo "Pasta nova: o kit será instalado em $ALVO."; exit 0; }
  mkdir -p "$ALVO"
fi
ALVO=$(cd "$ALVO" && pwd)
case "$ALVO/" in "$KIT/"*) echo "A pasta da operação não pode ficar dentro do kit." >&2; exit 2 ;; esac
case "$KIT/" in "$ALVO/"*) echo "O kit não pode ficar dentro da pasta da operação." >&2; exit 2 ;; esac

ITENS=(CLAUDE.md .claude/settings.json .claude/.gitattributes .claude/hooks .claude/bin .claude/modelos)
for f in "$KIT"/.claude/agents/*.md; do ITENS+=(".claude/agents/$(basename "$f")"); done
for d in "$KIT"/.claude/skills/*/; do ITENS+=(".claude/skills/$(basename "$d")"); done
OBSOLETOS=()
while IFS= read -r linha || [ -n "$linha" ]; do
  linha=${linha%$'\r'}
  [ -n "$linha" ] && [ -e "$ALVO/$linha" ] && OBSOLETOS+=("$linha")
done < "$KIT/.claude/bin/obsoletos.txt"

MUDA=()
for i in "${ITENS[@]}"; do
  if [ ! -e "$ALVO/$i" ]; then echo "novo    $i"; MUDA+=("$i")
  elif ! diff -rq "$KIT/$i" "$ALVO/$i" >/dev/null 2>&1; then echo "muda    $i"; MUDA+=("$i")
  fi
done
for o in "${OBSOLETOS[@]}"; do echo "sai     $o (vai para o backup)"; done

# Permissões que a operação pôs no settings.json do kit passam para o settings.local.json, que é dela.
EXTRAS='{}'
if [ -f "$ALVO/.claude/settings.json" ] && ! diff -q "$KIT/.claude/settings.json" "$ALVO/.claude/settings.json" >/dev/null; then
  command -v jq >/dev/null 2>&1 || { echo "O settings.json da operação difere do kit e falta jq para separar as permissões dela." >&2; exit 3; }
  EXTRAS=$(jq -n --slurpfile op "$ALVO/.claude/settings.json" --slurpfile kit "$KIT/.claude/settings.json" '
    reduce ("allow", "ask", "deny") as $k ({};
      (($op[0].permissions[$k] // []) - ($kit[0].permissions[$k] // [])) as $x
      | if ($x | length) > 0 then .[$k] = $x else . end)')
  [ "$EXTRAS" = '{}' ] || echo "permissões próprias do settings.json vão para .claude/settings.local.json: $(printf '%s' "$EXTRAS" | jq -c .)"
  HOOKS_PROPRIOS=$(jq -rn --slurpfile op "$ALVO/.claude/settings.json" --slurpfile kit "$KIT/.claude/settings.json" '
    ([$op[0].hooks // {} | .. | .command? // empty] - [$kit[0].hooks // {} | .. | .command? // empty]) | .[]')
  [ -z "$HOOKS_PROPRIOS" ] || echo "ATENÇÃO: hooks próprios no settings.json, passe-os à mão para o settings.local.json: $HOOKS_PROPRIOS"
fi

if [ -f "$ALVO/operacao/QUADRO.md" ]; then
  grep -i "levar ao kit" "$ALVO/operacao/QUADRO.md" | sed 's/^/para o kit: /' || true
fi

if [ ${#MUDA[@]} -eq 0 ] && [ ${#OBSOLETOS[@]} -eq 0 ] && [ "$EXTRAS" = '{}' ]; then
  echo "Kit já está atualizado em $ALVO."; exit 0
fi
[ "$MODO" = --aplicar ] || { echo; echo "Nada foi alterado. Para aplicar: bash .claude/bin/atualizar-kit.sh \"$ALVO\" --aplicar"; exit 0; }

BACKUP=""
if [ -d "$ALVO/operacao" ]; then
  BACKUP="$ALVO/operacao/.versoes/kit-$(date +%Y-%m-%d-%H%M%S)"
  mkdir -p "$BACKUP"
fi
guardar() {
  [ -e "$ALVO/$1" ] || return 0
  if [ -n "$BACKUP" ]; then
    mkdir -p "$(dirname "$BACKUP/$1")"
    mv "$ALVO/$1" "$BACKUP/$1"
  else
    rm -rf "${ALVO:?}/$1"
  fi
}

for o in "${OBSOLETOS[@]}"; do guardar "$o"; done
if [ "$EXTRAS" != '{}' ]; then
  LOCAL="$ALVO/.claude/settings.local.json"
  [ -f "$LOCAL" ] || echo '{}' > "$LOCAL"
  [ -z "$BACKUP" ] || cp "$LOCAL" "$BACKUP/settings.local.json"
  jq --argjson x "$EXTRAS" 'reduce ($x | keys[]) as $k (.; .permissions[$k] = (((.permissions[$k] // []) + $x[$k]) | unique))' \
    "$LOCAL" > "$LOCAL.novo" && mv "$LOCAL.novo" "$LOCAL"
fi
for i in "${MUDA[@]}"; do
  guardar "$i"
  mkdir -p "$(dirname "$ALVO/$i")"
  cp -r "$KIT/$i" "$ALVO/$i"
done

VERSAO=$(git -C "$KIT" log -1 --format='%h %cs' 2>/dev/null || date +%Y-%m-%d)
RAMO=$(git -C "$KIT" branch --show-current 2>/dev/null || true)
echo "$VERSAO ${RAMO}" > "$ALVO/.claude/kit-versao.txt"
echo
echo "Kit aplicado em $ALVO (versão $VERSAO ${RAMO})."
[ -z "$BACKUP" ] || echo "O que saiu está em $BACKUP."
