#!/usr/bin/env bash
# Nomes e funções compartilhados pelos hooks do kit. Uso: source "<pasta>/comum.sh".

PASTA_OPERACAO="operacao"
RAIZ="${CLAUDE_PROJECT_DIR:-$PWD}"
RAIZ="${RAIZ//\\//}"

minusculas() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# Resolve "." e ".." sem tocar o disco: o arquivo pode ainda não existir.
normalizar() {
  local caminho="${1//\\//}" prefixo="" parte partes=() saida=() IFS=/
  if [[ "$caminho" =~ ^([A-Za-z]:)?/ ]]; then prefixo="${BASH_REMATCH[0]}"; caminho="${caminho:${#prefixo}}"; fi
  read -ra partes <<< "$caminho"
  for parte in "${partes[@]}"; do
    case "$parte" in
      ""|.) ;;
      ..) if [ ${#saida[@]} -gt 0 ] && [ "${saida[-1]}" != .. ]; then unset 'saida[-1]'; elif [ -z "$prefixo" ]; then saida+=(..); fi ;;
      *) saida+=("$parte") ;;
    esac
  done
  printf '%s%s' "$prefixo" "${saida[*]}"
}

# Caminho relativo ao Root, sempre com /. No Windows a letra do drive pode variar de caixa.
relativo_a_raiz() {
  local arq raiz="${RAIZ%/}" estava
  arq=$(normalizar "$1")
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

caminho_da_entrada() {
  local c
  c=$(campo_da_entrada "$1" '.tool_input.file_path')
  [ -n "$c" ] || c=$(campo_da_entrada "$1" '.tool_input.notebook_path')
  printf '%s' "$c"
}

# O Claude Code só envia agent_id quando a ferramenta é chamada de dentro de um subagente.
# Papel rodado na conta secundária é uma sessão própria, sem agent_id: secundaria.sh marca com OPERADOR_PAPEL.
eh_subagente() { [ "${OPERADOR_PAPEL:-}" = sub ] || [ -n "$(campo_da_entrada "$1" '.agent_id')" ]; }
eh_executor() { [ "${OPERADOR_PAPEL:-}" != sub ] && [ "$(campo_da_entrada "$1" '.agent_type')" = operador-sub-executor ]; }

json_texto() {
  local s=$1
  s=${s//\\/\\\\}; s=${s//\"/\\\"}; s=${s//$'\n'/ }; s=${s//$'\r'/}; s=${s//$'\t'/ }
  printf '%s' "$s"
}

negar_ferramenta() {
  printf '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "%s"}}\n' "$(json_texto "$1")"
  exit 0
}

# Na conta secundária (claude -p) ninguém responde: perguntar vira negar.
perguntar_ferramenta() {
  [ "${OPERADOR_PAPEL:-}" = sub ] && negar_ferramenta "$1 (Na conta secundária não há quem confirme.)"
  printf '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "ask", "permissionDecisionReason": "%s"}}\n' "$(json_texto "$1")"
  exit 0
}
