#!/usr/bin/env bash
# Autoteste das travas do kit, numa pasta temporária. Os segredos de teste são fictícios e montados
# por partes, para a própria trava de segredos não barrar este arquivo.
# Uso: bash .claude/bin/testar-hooks.sh

KIT=$(cd "$(dirname "$0")/../.." && pwd)
BASE=$(mktemp -d)
trap 'rm -rf "$BASE"' EXIT
FALHAS=0
K="$BASE/kit"
SENHA_FICTICIA="pass""word: \\\"SuperFicticia123\\\""
TOKEN_FICTICIO="ghp""_abcdefghijklmnopqrstuvwxyz0123456789"

ok() { echo "ok    $1"; }
falha() { echo "FALHA $1"; FALHAS=$((FALHAS + 1)); }

mkdir -p "$K/.claude" "$K/operacao/docs"
cp -r "$KIT/.claude/hooks" "$K/.claude/"

# editar ARQUIVO [CONTEUDO] [AGENTE]: saída do hook $HOOK para uma edição (caminho relativo ao Root).
editar() {
  local agente=""
  [ -n "${3:-}" ] && agente=",\"agent_id\":\"$3\",\"agent_type\":\"operador-sub-executor\""
  printf '{"session_id":"s1"%s,"tool_input":{"file_path":"%s","content":"%s"}}' "$agente" "$K/$1" "${2:-x}" \
    | CLAUDE_PROJECT_DIR="$K" bash "$K/.claude/hooks/$HOOK"
}
nega()        { if editar "$2" "${3:-x}" | grep -q '"deny"'; then ok "$1"; else falha "$1"; fi; }
permite()     { if editar "$2" "${3:-x}" | grep -q '"deny"'; then falha "$1"; else ok "$1"; fi; }
nega_sub()    { if editar "$2" x a1 | grep -q '"deny"'; then ok "$1"; else falha "$1"; fi; }
permite_sub() { if editar "$2" x a1 | grep -q '"deny"'; then falha "$1"; else ok "$1"; fi; }

HOOK=proteger-estrutura.sh
nega        "arquivo solto no Root é negado"              "solto.txt"
nega        "pasta fora do padrão é negada"               "entregas/a.png"
nega        "parametros/ é negado ao gerente"             "operacao/parametros/chave.json"
permite     "gerente edita o quadro"                      "operacao/QUADRO.md"
permite     "gerente edita docs/"                         "operacao/docs/ambiente.md"
permite     "gerente edita cartao.md"                     "operacao/cartoes/001-x/cartao.md"
permite     "gerente edita o kit"                         ".claude/rules/operacao.md"
permite     "gerente edita .mcp.json"                     ".mcp.json"
permite     "fora do Root não interfere"                  "../fora/a.txt"
nega_sub    "subagente não edita o quadro"                "operacao/QUADRO.md"
nega_sub    "subagente não edita docs/"                   "operacao/docs/ambiente.md"
nega_sub    "subagente não edita cartao.md"               "operacao/cartoes/001-x/cartao.md"
nega_sub    "subagente não edita o kit"                   ".claude/settings.json"
nega_sub    "subagente não grava solto no cartão"         "operacao/cartoes/001-x/a.txt"
permite_sub "subagente grava em entregas/"                "operacao/cartoes/001-x/entregas/relatorio.md"
permite_sub "subagente grava em backups/"                 "operacao/cartoes/001-x/backups/01-resolv.conf"

HOOK=bloquear-segredos.sh
nega    "senha literal é negada"                  "operacao/cartoes/001-x/entregas/a.yml" "$SENHA_FICTICIA"
nega    "token de API conhecido é negado"         "operacao/docs/ferramentas.md" "$TOKEN_FICTICIO"
permite "texto comum é liberado"                  "operacao/docs/ambiente.md" 'porta 53 aberta'

comando() {
  printf '{"session_id":"s1","tool_input":{"command":"%s"}}' "$1" \
    | CLAUDE_PROJECT_DIR="$K" bash "$K/.claude/hooks/bloquear-comandos.sh"
}
nega_cmd()    { if comando "$2" | grep -q '"deny"'; then ok "$1"; else falha "$1"; fi; }
permite_cmd() { if comando "$2" | grep -q '"deny"'; then falha "$1"; else ok "$1"; fi; }

nega_cmd    "rm -rf remoto a partir de / é negado"    'ssh casa \"sudo rm -rf /var/lib/x\"'
nega_cmd    "apagar em operacao/ é negado"            'rm -r operacao/cartoes/001-x'
nega_cmd    "Remove-Item em operacao é negado"        'Remove-Item -Recurse operacao\\\\cartoes\\\\001-x'
nega_cmd    "parar o ssh do servidor é negado"        'ssh casa \"sudo systemctl stop ssh\"'
permite_cmd "arquivar cartão (mv) é liberado"         'mv operacao/cartoes/001-x operacao/cartoes/_arquivo/'
permite_cmd "leitura remota é liberada"               'ssh casa \"systemctl status adguardhome\"'
permite_cmd "palavra com rm no meio é liberada"       'echo confirm operacao/x'

SAIDA=$(CLAUDE_PROJECT_DIR="$K" bash "$K/.claude/hooks/verificar-ambiente.sh")
if printf '%s' "$SAIDA" | grep -q '/operador-iniciar'; then ok "abertura sem quadro indica /operador-iniciar"; else falha "abertura sem quadro indica /operador-iniciar"; fi
echo "# Quadro" > "$K/operacao/QUADRO.md"
printf '| Ferramenta | Tipo | Para quê | Segredo | Status |\n|---|---|---|---|---|\n| Trello | MCP | x | conector | pendente: autorizar |\n| ssh casa | SSH | x | ~/.ssh | ok |\n' > "$K/operacao/docs/ferramentas.md"
touch "$K/solto.txt"
SAIDA=$(CLAUDE_PROJECT_DIR="$K" bash "$K/.claude/hooks/verificar-ambiente.sh")
if printf '%s' "$SAIDA" | grep -q 'pendentes.*Trello' && ! printf '%s' "$SAIDA" | grep -q 'ssh casa'; then ok "abertura avisa só a ferramenta pendente"; else falha "abertura avisa só a ferramenta pendente"; fi
if printf '%s' "$SAIDA" | grep -q 'solto.txt'; then ok "abertura avisa arquivo solto"; else falha "abertura avisa arquivo solto"; fi
if ! command -v jq >/dev/null 2>&1 || printf '%s' "$SAIDA" | jq -e . >/dev/null 2>&1; then ok "abertura gera JSON válido"; else falha "abertura gera JSON válido"; fi

echo
if [ "$FALHAS" -eq 0 ]; then echo "Todas as travas passaram."; else echo "$FALHAS falha(s)."; exit 1; fi
