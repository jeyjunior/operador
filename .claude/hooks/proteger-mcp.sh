#!/usr/bin/env bash
# Hook PreToolUse (mcp__.*): ferramenta de MCP que escreve (enviar, publicar, criar, mover, apagar...).
#   analista, conferente, papéis de fluxo e conta secundária: negado.
#   gerente e executor: o usuário confirma cada chamada (o "ok específico" do CLAUDE.md).
# A ação é lida do último trecho do nome (mcp__servidor__acao). Ferramentas do próprio app ficam de fora.

ENTRADA=$(cat)
source "$(dirname "${BASH_SOURCE[0]}")/comum.sh"

ler_entrada "$ENTRADA"
NOME=$FERRAMENTA
[ -n "$NOME" ] || exit 0
case "$NOME" in
  mcp__ccd_*|mcp__visualize__*|mcp__Claude_Browser__*|mcp__claude-in-chrome__*) exit 0 ;;
esac

ACAO=$(printf '%s' "${NOME##*__}" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\2/g' | tr '[:upper:]' '[:lower:]' | tr '-' '_')
ESCREVE='(^|_)(send|post|publish|create|update|delete|remove|move|write|upload|reply|forward|archive|trash|edit|modify|cancel|share|invite|comment|add|set|insert|replace|schedule|draft|run|execute)(_|$)'
[[ "$ACAO" =~ $ESCREVE ]] || exit 0

if eh_subagente && ! eh_executor; then
  negar_ferramenta "Ferramenta de MCP que escreve ($NOME) é só do executor ou do gerente, com o ok do usuário. Devolva a proposta ao gerente."
fi
perguntar_ferramenta "Ferramenta de MCP que escreve ($NOME): confirme só se estiver no plano aprovado e com o seu ok específico."
