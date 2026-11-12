#!/usr/bin/env bash
# Nomes e funções compartilhados pelos hooks do kit. Uso: source "<pasta>/comum.sh".

PASTA_OPERACAO="operacao"
RAIZ="${CLAUDE_PROJECT_DIR:-$PWD}"
RAIZ="${RAIZ//\\//}"

minusculas() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# Caminho relativo ao Root, sempre com /. No Windows a letra do drive pode variar de caixa.
relativo_a_raiz() {
  local arq="${1//\\//}" raiz="${RAIZ%/}" estava
  estava=$(shopt -p nocasematch)
  shopt -s nocasematch
  [[ "$arq" == "$raiz"/* ]] && arq="${arq:${#raiz}+1}"
  eval "$estava"
  while [[ "$arq" == ./* ]]; do arq="${arq#./}"; done
  printf '%s' "$arq"
}

# dentro_de PASTA CAMINHO: imprime o caminho relativo a PASTA/ e retorna 0 se estiver dentro dela.
dentro_de() {
  local p r
  p=$(minusculas "$1"); r=$(minusculas "$2")
  [[ "$r" == "$p"/* ]] || return 1
  printf '%s' "${2:${#1}+1}"
}

fora_do_root() { [[ "$1" == /* || "$1" == ../* || "$1" =~ ^[A-Za-z]:/ ]]; }

# Campo de texto da entrada do hook. Funciona sem jq para campos sem aspas internas.
campo_da_entrada() {
  local entrada=$1 caminho=$2 nome=${2##*.} valor
  if command -v jq >/dev/null 2>&1; then
    valor=$(printf '%s' "$entrada" | jq -r "$caminho // empty")
  else
    valor=$(printf '%s' "$entrada" | sed -n "s/.*\"$nome\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -n1)
    valor=${valor//\\\\/\\}
  fi
  printf '%s' "$valor"
}

caminho_da_entrada() { campo_da_entrada "$1" '.tool_input.file_path'; }

# O Claude Code só envia agent_id quando a ferramenta é chamada de dentro de um subagente.
# Papel rodado na conta secundária é uma sessão própria, sem agent_id: secundaria.sh marca com OPERADOR_PAPEL.
eh_subagente() { [ "${OPERADOR_PAPEL:-}" = sub ] || [ -n "$(campo_da_entrada "$1" '.agent_id')" ]; }

json_texto() {
  local s=$1
  s=${s//\\/\\\\}; s=${s//\"/\\\"}; s=${s//$'\n'/ }; s=${s//$'\r'/}; s=${s//$'\t'/ }
  printf '%s' "$s"
}

negar_ferramenta() {
  printf '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "%s"}}\n' "$(json_texto "$1")"
  exit 0
}
