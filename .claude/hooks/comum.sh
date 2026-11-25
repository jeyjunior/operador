#!/usr/bin/env bash
# Nomes e funções compartilhados pelos hooks do kit. Uso: source "<pasta>/comum.sh".

PASTA_OPERACAO="operacao"
RAIZ="${CLAUDE_PROJECT_DIR:-$PWD}"
RAIZ="${RAIZ//\\//}"

minusculas() { printf '%s' "${1,,}"; }

# Resolve "." e ".." sem tocar o disco (o arquivo pode ainda não existir). Resultado em NORMALIZADO.
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
  NORMALIZADO="$prefixo${saida[*]}"
}

# Caminho relativo ao Root, sempre com /. No Windows a letra do drive pode variar de caixa.
relativo_a_raiz() {
  local arq raiz="${RAIZ%/}"
  normalizar "$1"
  arq=$NORMALIZADO
  [[ "${arq,,}" == "${raiz,,}"/* ]] && arq="${arq:${#raiz}+1}"
  while [[ "$arq" == ./* ]]; do arq="${arq#./}"; done
  printf '%s' "$arq"
}

# dentro_de PASTA CAMINHO: imprime o caminho relativo a PASTA/ e retorna 0 se estiver dentro dela.
dentro_de() {
  [[ "${2,,}" == "${1,,}"/* ]] || return 1
  printf '%s' "${2:${#1}+1}"
}

fora_do_root() { [[ "$1" == /* || "$1" == ../* || "$1" =~ ^[A-Za-z]:/ ]]; }

# Sem jq: lê um campo de texto sem aspas internas.
campo_sem_jq() {
  local valor
  valor=$(printf '%s' "$1" | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n1)
  valor=${valor//\\\\/\\}
  printf '%s' "$valor"
}

# Lê a entrada do hook de uma vez (cada processo custa caro no Windows). Preenche ARQ_ENTRADA, AGENTE_ID,
# AGENTE_TIPO, FERRAMENTA, COMANDO e CONTEUDO. Sem jq, COMANDO e CONTEUDO ficam com a entrada inteira.
ler_entrada() {
  local campos=()
  if command -v jq >/dev/null 2>&1; then
    mapfile -d '' -t campos < <(printf '%s' "$1" | jq -j '
      (.tool_input.file_path // .tool_input.notebook_path // ""), "\u0000",
      (.agent_id // ""), "\u0000", (.agent_type // ""), "\u0000", (.tool_name // ""), "\u0000",
      (.tool_input.command // ""), "\u0000",
      (.tool_input | (.new_string // .content // .new_source // ((.edits // []) | map(.new_string // "") | join("\n")))), "\u0000"')
    ARQ_ENTRADA=${campos[0]-} AGENTE_ID=${campos[1]-} AGENTE_TIPO=${campos[2]-} FERRAMENTA=${campos[3]-}
    COMANDO=${campos[4]-} CONTEUDO=${campos[5]-}
  else
    ARQ_ENTRADA=$(campo_sem_jq "$1" file_path)
    [ -n "$ARQ_ENTRADA" ] || ARQ_ENTRADA=$(campo_sem_jq "$1" notebook_path)
    AGENTE_ID=$(campo_sem_jq "$1" agent_id)
    AGENTE_TIPO=$(campo_sem_jq "$1" agent_type)
    FERRAMENTA=$(campo_sem_jq "$1" tool_name)
    COMANDO=$1
    CONTEUDO=${1//\\\"/\"}
  fi
}

# O Claude Code só envia agent_id quando a ferramenta é chamada de dentro de um subagente.
# Papel rodado na conta secundária é uma sessão própria, sem agent_id: secundaria.sh marca com OPERADOR_PAPEL.
eh_subagente() { [ "${OPERADOR_PAPEL:-}" = sub ] || [ -n "$AGENTE_ID" ]; }
eh_executor() { [ "${OPERADOR_PAPEL:-}" != sub ] && [ "$AGENTE_TIPO" = operador-sub-executor ]; }

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
