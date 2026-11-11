#!/usr/bin/env bash
# Hook SessionStart: avisa o usuário e o Claude quando falta jq, a estrutura está fora do padrão,
# sobrou um .git do kit na operação ou há ferramenta pendente. Escreve o JSON sem jq de propósito.

source "$(dirname "${BASH_SOURCE[0]}")/comum.sh"
AVISOS=()

if ! command -v jq >/dev/null 2>&1; then
  AVISOS+=("Falta jq: os bloqueios de comandos e de segredos funcionam em modo menos preciso. No Windows: winget install jqlang.jq e reabra o Claude Code.")
fi

OP="$RAIZ/$PASTA_OPERACAO"
if [ ! -f "$OP/QUADRO.md" ]; then
  AVISOS+=("Operação ainda não montada: rode /operador-iniciar.")
elif [ -e "$RAIZ/.git" ]; then
  AVISOS+=("Há um .git no Root desta operação, provavelmente copiado do kit modelo. A operação não usa git: o usuário pode apagar a pasta .git do Root.")
fi

FERR="$OP/docs/ferramentas.md"
if [ -f "$FERR" ]; then
  PEND=$(grep -iE '^\|.*\|[[:space:]]*pendente' "$FERR" | cut -d'|' -f2 | sed 's/^ *//; s/ *$//' | paste -sd ',' - | sed 's/,/, /g')
  [ -n "$PEND" ] && AVISOS+=("Ferramentas pendentes em $PASTA_OPERACAO/docs/ferramentas.md: $PEND. Cartão que depende delas não roda até o usuário ligar.")
fi

FORA=()
for item in "$RAIZ"/* "$RAIZ"/.[!.]* "$RAIZ"/..?*; do
  [ -e "$item" ] || continue
  nome=$(basename "$item")
  case "$nome" in
    "$PASTA_OPERACAO"|.claude|CLAUDE.md|CLAUDE.local.md|README.md|.mcp.json|.git|.gitattributes|.gitignore) ;;
    .vs|.vscode|.idea|desktop.ini|Desktop.ini|Thumbs.db|.DS_Store) ;;
    *) FORA+=("$nome") ;;
  esac
done
if [ ${#FORA[@]} -gt 0 ]; then
  AVISOS+=("Fora da estrutura no Root: ${FORA[*]}. No Root só ficam o kit e $PASTA_OPERACAO/; arquivos de trabalho vão para a pasta do cartão.")
fi

[ ${#AVISOS[@]} -gt 0 ] || exit 0
TEXTO="Operador:"
for a in "${AVISOS[@]}"; do TEXTO="$TEXTO [$a]"; done
printf '{"systemMessage": "%s", "hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "%s Explique ao usuário e ajude a corrigir antes de seguir."}}\n' \
  "$(json_texto "$TEXTO")" "$(json_texto "$TEXTO")"
exit 0
