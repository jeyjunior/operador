#!/usr/bin/env bash
# Hook PreToolUse (Bash|PowerShell): nega comandos destrutivos óbvios e escrita por shell no estado da
# operação; pede confirmação para o que pode trancar ou derrubar um servidor.
# Com jq, examina o comando. Sem jq, examina a entrada inteira do hook (menos preciso, mas
# não fica desligado); o verificar-ambiente.sh avisa ao abrir a sessão.

ENTRADA=$(cat)
source "$(dirname "${BASH_SOURCE[0]}")/comum.sh"

ler_entrada "$ENTRADA"
[ -n "$COMANDO" ] || exit 0

# Shell POSIX (diferencia maiúsculas: nome de comando tem caixa fixa).
POSIX=(
  '(^|[^[:alnum:]_-])rm\s+([^|;&]*\s)?(-[a-zA-Z]*[rR][a-zA-Z]*|--recursive)(\s[^|;&]*)?\s["'"'"']?([~/$*]|\.\.|[A-Za-z]:[\\/])'  # apagar recursivo a partir de /, ~, variável, *, .. ou drive
  '--no-preserve-root'
  'git\s+clean\s+[^|;&]*-[a-zA-Z]*[xX]'               # apaga o que o .gitignore esconde, como operacao/
  '\bfind\s[^|;&]*operacao[^|;&]*\s-delete'
  'git\s+push\s+(--force|-f)\s+.*\s+(main|master)\b'
  '>\s*/dev/sd[a-z]'
  'chmod\s+-R\s+777'
  '(curl|wget)\s+[^|]+\|\s*(sudo\s+)?(ba|z|da)?sh(\s|$|[;&|])'   # baixar e executar (| sha256sum passa)
  'mkfs\.'
  'dd\s+if=.*of=/dev/[sh]d'
  '(^|[^[:alnum:]_-])rm\s[^|;&]*operacao/'           # operacao/ não tem histórico: arquive, não apague
  'systemctl\s+(stop|disable|mask)\s+(ssh|sshd)\b'   # derruba o acesso ao servidor
)

# Windows: cmd e PowerShell (sem diferenciar maiúsculas). Mira o catastrófico e raramente
# legítimo em desenvolvimento; limpeza comum de pasta não entra.
WINDOWS=(
  '\b(del|erase|rd|rmdir)\b[^|]*\s/s\b'
  'format\s+[A-Za-z]:'
  '\bdiskpart\b'
  '\bcipher\s+/w'
  'remove-item\b[^|]*-recurse[^|]*([A-Za-z]:\\?(\s|["'"'"']|$)|\\(windows|system32|users)\\)'
  '\bvssadmin\s+delete\b'
  '\bwbadmin\s+delete\b'
  '\bbcdedit\b[^|]*(delete|recoveryenabled\s+no)'
  '(add|set)-mppreference\b'
  '\bcertutil\b[^|]*(-urlcache|-decode)'
  '\b(iex|invoke-expression)\b'
  '\bdownloadstring\b'
  '\bbitsadmin\b[^|]*/transfer'
  '\bmshta\s+https?'
  '\bregsvr32\b[^|]*/i:http'
  '\brundll32\b[^|]*javascript:'
  '\bnetsh\s+advfirewall\b[^|]*state\s+off'
  '\bwevtutil\s+cl\b'
  '\bfsutil\b[^|]*deletejournal'
  'set-executionpolicy\s+(bypass|unrestricted)'
  '-verb\s+runas'
  '\brunas\s+/'
  '\b(powershell|pwsh)(\.exe)?\b[^|]*\s-(e|ec|enc|encodedcommand)\s+[A-Za-z0-9+/=]{16,}'
  '\bnet\s+(user|localgroup)\b[^|]*\s/add'
  '\btakeown\b[^|]*\s/r\b'
  '\bicacls\b[^|]*/grant[^|]*everyone'
  '\bschtasks\b[^|]*/create'
  '\b(register|new)-scheduledtask'
  '\b(new|set)-itemproperty\b[^|]*\\currentversion\\run'
  '\bsc\s+(create|delete)\b'
  '\breg\s+delete\s+[^|]*hklm'
  '\breg\s+add\s+[^|]*\\run\b'
  '(\bremove-item\b|\bri\b|\bdel\b|\berase\b|\brd\b|\brmdir\b)[^|;]*operacao[\\/]'
)

# Estado da operação: quadro, docs/ e cartao.md só mudam por Edit/Write, que guardam a versão anterior;
# sed -i não toca nenhum .md de operacao/ (troca errada apaga texto sem cópia).
# parametros/ é do usuário. Sem diferenciar maiúsculas.
ALVO='["'"'"']?(\./)?operacao[\\/](quadro\.md|docs[\\/][^|;&[:space:]]*|cartoes[\\/][^\\/[:space:]]+[\\/]cartao\.md)'
ESTADO=(
  ">\s*$ALVO"
  "\b(cp|mv|install|ln)\b[^|;&]*\s$ALVO[\"']?\s*(\$|[|;&])"
  "\btee\b[^|;&]*\s$ALVO"
  "\bsed\b[^|;&]*\s-i[^|;&]*\s[\"']?(\./)?operacao[\\/][^|;&[:space:]]*\.md"
  "\b(set-content|add-content|out-file|clear-content|copy-item|move-item|new-item|rename-item)\b[^|;]*$ALVO"
  'operacao[\\/]parametros'
)

# Pode trancar o acesso ao servidor ou derrubá-lo: o usuário confirma. Sem diferenciar maiúsculas.
SEP='(^|[;&|"'"'"'[:space:]])(sudo\s+)?'
FIM='(\s|$|["'"'"';&|])'
PERGUNTAR=(
  '\bufw\s+(--force\s+)?(enable|reset|default\s+deny)'
  '\b(ip6?tables|iptables-legacy)\b[^|;&]*\s(-F|--flush|-X|-P\s+\S+\s+(DROP|REJECT))'
  '\bnft\s+flush\b'
  "${SEP}(reboot|poweroff|halt|shutdown)${FIM}"
  '\bsystemctl\s+(reboot|poweroff|halt|kexec)\b'
  '\bservice\s+sshd?\s+stop\b'
  '\bpasswd\s+-l\b'
  '\busermod\s+[^|;&]*-L\b'
  '\buserdel\b'
  'apt(-get)?\s+[^|;&]*(remove|purge)\b[^|;&]*openssh'
)

# casa OPCOES PADRAO...: imprime o primeiro padrão que casa com o comando. Um grep para o grupo
# inteiro; só procura qual foi quando algum casou (cada processo custa caro no Windows).
casa() {
  local opcoes=$1 junto="" p
  shift
  for p in "$@"; do junto="${junto:+$junto|}($p)"; done
  printf '%s' "$COMANDO" | grep -q"$opcoes" -- "$junto" || return 1
  for p in "$@"; do
    if printf '%s' "$COMANDO" | grep -q"$opcoes" -- "$p"; then printf '%s' "$p"; return 0; fi
  done
}

if MOTIVO=$(casa E "${POSIX[@]}") || MOTIVO=$(casa iE "${WINDOWS[@]}"); then
  negar_ferramenta "Comando destrutivo bloqueado pelo kit (padrão: $MOTIVO). Se for intencional, peça ao usuário que rode ele mesmo."
fi
if MOTIVO=$(casa iE "${ESTADO[@]}"); then
  negar_ferramenta "Quadro, docs/ e cartao.md só mudam pela ferramenta de edição (o kit guarda a versão anterior), e parametros/ é do usuário. Comando bloqueado (padrão: $MOTIVO)."
fi
if MOTIVO=$(casa iE "${PERGUNTAR[@]}"); then
  perguntar_ferramenta "Este comando pode trancar o acesso ao servidor ou derrubá-lo (padrão: $MOTIVO). Confirme só se estiver no plano aprovado."
fi
exit 0
