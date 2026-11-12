#!/usr/bin/env bash
# Conta secundária do Claude Code (CLI) para rodar papéis fora da conta principal.
# Uso: bash .claude/bin/secundaria.sh status
#      bash .claude/bin/secundaria.sh mcp     (MCPs que a secundária enxerga e se estão conectados)
#      bash .claude/bin/secundaria.sh rodar <analista|conferente|geral> [--model M] [--effort E] [ferramenta...] < prompt
#      bash .claude/bin/secundaria.sh regras | instrucoes <papel>   (o que a chamada recebe, para conferir)
# Pasta da conta: $OPERADOR_CONTA_CLI, ou ~/.claude-secundaria. Nada é gravado nela.

set -u
CONTA="${OPERADOR_CONTA_CLI:-$HOME/.claude-secundaria}"
PRINCIPAL="${OPERADOR_CONTA_PRINCIPAL:-$HOME/.claude}"
RAIZ=$(cd "$(dirname "$0")/../.." && pwd)

# O processo herda variáveis da sessão do app (conta, sessão, conectores); sem limpar, a CLI se mistura com a principal.
limpo() {
  local fora=() v
  for v in $(env | grep -oE '^(CLAUDE|ANTHROPIC|MCP_)[A-Za-z0-9_]*'); do fora+=(-u "$v"); done
  env "${fora[@]}" CLAUDE_CONFIG_DIR="$CONTA" "$@"
}

status() {
  command -v claude >/dev/null 2>&1 && [ -d "$CONTA" ] || { echo ausente; return; }
  command -v jq >/dev/null 2>&1 || { echo sem-jq; return; }
  [ "$(limpo claude auth status 2>/dev/null | jq -r '.loggedIn // false')" = true ] && echo ok || echo sem-login
}

# Regras do projeto sem "ask" (o modo -p não pergunta: "ask" vira negação), somadas aos hooks globais da principal.
regras() {
  local globais='{}'
  [ -f "$PRINCIPAL/settings.json" ] && globais=$(jq '.hooks // {}' "$PRINCIPAL/settings.json")
  jq -c --argjson g "$globais" '
    del(.permissions.ask)
    | .hooks = reduce ($g | keys[]) as $k ((.hooks // {}); .[$k] = ((.[$k] // []) + $g[$k]))
  ' "$RAIZ/.claude/settings.json"
}

# A chamada roda sem as configurações do projeto, e com isso o Claude não carrega nenhum CLAUDE.md: vão todos aqui.
instrucoes() {
  local papel=$1 f
  for f in "$PRINCIPAL/CLAUDE.md" "$RAIZ/CLAUDE.md" "$RAIZ"/.claude/rules/*.md; do
    [ -f "$f" ] && printf '\n# Instruções de %s\n\n%s\n' "$f" "$(cat "$f")"
  done
  case "$papel" in
    analista|conferente) printf '\n# Seu papel\n\n%s\n' "$(awk 'f>=2{print} /^---$/{f++}' "$RAIZ/.claude/agents/operador-sub-$papel.md")" ;;
    *) printf '\n# Seu papel\n\nVocê é um papel de fluxo do kit Operador. O texto do papel vem no pedido do gerente.\n' ;;
  esac
  printf '\nVocê roda como subagente do gerente, numa sessão sem usuário: não pergunte, não espere resposta. Se algo fugir do pedido, pare e devolva.\n'
}

rodar() {
  local papel=${1:-}
  shift || true
  case "$papel" in
    analista|conferente|geral) ;;
    executor) echo "o executor roda na conta principal" >&2; exit 2 ;;
    *) echo "papel: analista, conferente ou geral" >&2; exit 2 ;;
  esac
  local motor=() mcp=() situacao
  while [ $# -gt 0 ]; do
    case "$1" in
      --model|--effort) [ -n "${2:-}" ] || { echo "$1 sem valor" >&2; exit 2; }; motor+=("$1" "$2"); shift 2 ;;
      *) break ;;
    esac
  done
  situacao=$(status)
  [ "$situacao" = ok ] || { echo "conta secundária indisponível: $situacao" >&2; exit 3; }
  cd "$RAIZ" || exit 1
  [ -f .mcp.json ] && mcp=(--mcp-config .mcp.json)
  limpo OPERADOR_PAPEL=sub claude -p --setting-sources user --settings "$(regras)" "${mcp[@]}" "${motor[@]}" \
    --append-system-prompt "$(instrucoes "$papel")" \
    --allowedTools Read Glob Grep Write Edit WebSearch WebFetch "$@"
}

mcp() {
  command -v claude >/dev/null 2>&1 && [ -d "$CONTA" ] || { echo "conta secundária ausente" >&2; exit 3; }
  cd "$RAIZ" || exit 1
  limpo claude mcp list 2>&1 | grep -v '^Checking MCP' | grep -v '^$'
}

case "${1:-}" in
  status) status ;;
  rodar) shift; rodar "$@" ;;
  mcp) mcp ;;
  regras) regras ;;
  instrucoes) instrucoes "${2:-geral}" ;;
  *) echo "uso: secundaria.sh status | mcp | rodar <papel> [ferramenta...] < prompt | regras | instrucoes <papel>" >&2; exit 2 ;;
esac
