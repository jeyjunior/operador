#!/usr/bin/env bash
# Hook PreToolUse (Edit|Write|MultiEdit): antes de alterar um .md existente em operacao/, guarda a versão
# atual em operacao/.versoes/AAAA-MM-DD/<caminho com __>.<hhmmss>.<pid>.md. Nunca nega a edição.

ENTRADA=$(cat)
source "$(dirname "${BASH_SOURCE[0]}")/comum.sh"

ler_entrada "$ENTRADA"
ARQ=$ARQ_ENTRADA
[ -n "$ARQ" ] || exit 0
REL=$(relativo_a_raiz "$ARQ")
NO_OP=$(dentro_de "$PASTA_OPERACAO" "$REL") || exit 0
case "${NO_OP,,}" in
  .versoes/*|parametros/*) exit 0 ;;
  *.md) ;;
  *) exit 0 ;;
esac
ORIGEM="$RAIZ/$REL"
[ -f "$ORIGEM" ] || exit 0

DESTINO="$RAIZ/$PASTA_OPERACAO/.versoes/$(date +%Y-%m-%d)"
mkdir -p "$DESTINO" 2>/dev/null || exit 0
cp -p "$ORIGEM" "$DESTINO/${NO_OP//\//__}.$(date +%H%M%S).$$.md" 2>/dev/null
exit 0
