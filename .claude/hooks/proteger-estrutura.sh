#!/usr/bin/env bash
# Hook PreToolUse (Edit|Write|MultiEdit): estrutura do Root e papéis.
#   operacao/parametros/   negado a todos.
#   operacao/              gerente: liberado. Subagente: só cartoes/<cartão>/entregas/ e backups/.
#   kit (CLAUDE.md, README.md, .claude/, .mcp.json)   gerente: liberado. Subagente: negado.
#   qualquer outra coisa no Root: negado. Fora do Root: não interfere.

ENTRADA=$(cat)
source "$(dirname "${BASH_SOURCE[0]}")/comum.sh"

ARQ=$(caminho_da_entrada "$ENTRADA")
[ -n "$ARQ" ] || exit 0
REL=$(relativo_a_raiz "$ARQ")
fora_do_root "$REL" && exit 0
SUB=""
eh_subagente "$ENTRADA" && SUB=1

if NO_OP=$(dentro_de "$PASTA_OPERACAO" "$REL"); then
  NO_OP_N=$(minusculas "$NO_OP")
  if [[ $NO_OP_N == parametros/* ]]; then
    negar_ferramenta "$PASTA_OPERACAO/parametros/ é do usuário: o Claude não lê nem grava nessa pasta."
  fi
  if [ -n "$SUB" ] && ! [[ $NO_OP_N =~ ^cartoes/[^/]+/(entregas|backups)/.+ ]]; then
    negar_ferramenta "Subagente só grava em $PASTA_OPERACAO/cartoes/<cartão>/entregas/ ou backups/ ($REL). Quadro, cartao.md e docs/ são do gerente: devolva o conteúdo na resposta."
  fi
  exit 0
fi

case "$(minusculas "$REL")" in
  claude.md|claude.local.md|readme.md|.gitignore|.mcp.json|.claude/*)
    [ -n "$SUB" ] && negar_ferramenta "Subagente não altera o kit ($REL). Devolva a sugestão ao gerente."
    exit 0 ;;
esac

negar_ferramenta "No Root só ficam o kit (CLAUDE.md, README.md, .claude/, .mcp.json) e $PASTA_OPERACAO/. Não crie nada fora disso ($REL): arquivo gerado vai para $PASTA_OPERACAO/cartoes/<cartão>/entregas/."
