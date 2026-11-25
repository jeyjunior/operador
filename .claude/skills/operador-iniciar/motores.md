# Motores: conta e modelos

O usuário pode ter uma segunda conta do Claude Code na CLI para tirar consumo da conta principal, e pode escolher o modelo e o esforço de cada tipo de tarefa. `.claude/bin/secundaria.sh` cuida da secundária: a cada chamada, entrega ao papel a regra global do usuário, o `CLAUDE.md` e as rules da operação, as travas da operação e os hooks globais da principal. Nada é gravado na pasta da secundária.

## Na abertura da sessão (antes do primeiro disparo)

1. Leia "Motores" de `operacao/docs/ferramentas.md`. Se há um setup salvo, mostre-o numa linha e pergunte: usar o salvo ou ajustar. Usar o salvo: vá ao passo 5. Ajustar: siga.
2. Rode `bash .claude/bin/secundaria.sh status`:
   - `ok`: siga ao passo 3.
   - `ausente`: tudo na principal, sem a pergunta 1.
   - `sem-jq`: tudo na principal; diga numa linha que a secundária precisa de jq.
   - `sem-login`: tudo na principal; diga que a conta secundária existe mas não está logada (ele abre um terminal com `$env:CLAUDE_CONFIG_DIR` apontando para ela e roda `claude`).
3. **Pergunta 1, onde rodam os subagentes** (só com status `ok`), em múltipla escolha: (1) perguntar a cada subagente; (2) na secundária durante todo o ciclo; (3) só na principal. Avise: o executor e os papéis que escrevem por MCP rodam sempre na principal.
4. **Pergunta 2, modelos**, em múltipla escolha: (1) padrão do operador (tabela abaixo); (2) montar o meu setup. No setup, uma rodada de múltipla escolha com uma pergunta por tipo (pesquisa, análise, execução, conferência; opções: haiku baixo, sonnet médio, opus alto), e uma pergunta para criação; o usuário também pode escrever livre ("opus para análise, o resto sonnet"). Mostre o setup montado numa tabela antes de seguir.
5. Pergunte se salva para a operação (se já veio do salvo, não pergunte). Sim: grave em "Motores" de `ferramentas.md` (se o arquivo ainda não existe, grave quando criá-lo).
6. Ao abrir ou retomar um cartão, grave a escolha numa linha `Motores:` do `cartao.md`. Gerente que retoma o cartão usa essa linha e não pergunta de novo.

## Tipos de tarefa e padrão do operador

Cada disparo é de um tipo. O analista é análise (ou pesquisa, quando só busca informação de fora); o executor é execução; o conferente é conferência; papel de fluxo usa o `Tipo:` escrito no fluxo.

| Tipo | O que é | Padrão | Sobe para opus alto quando |
|---|---|---|---|
| Pesquisa | buscar e resumir informação de fora | sonnet baixo | serve a uma decisão de segurança ou de custo |
| Análise | investigar o ambiente e propor opções | sonnet médio | há risco difícil de desfazer, ou mais de um caminho razoável |
| Execução | fazer o que o plano manda | sonnet médio | passos encadeados em que o erro de um quebra o seguinte |
| Criação | produzir conteúdo (texto, roteiro, arte) | sonnet médio | peça importante ou pública |
| Conferência | verificar contra critérios | sonnet baixo | o conferido é crítico (DNS, firewall, acesso, dados de pessoas) |

- **Padrão:** você sobe de nível pelos critérios acima e diz o motivo numa linha. Se um papel devolver algo raso, rode de novo um nível acima e registre.
- **Setup do usuário:** use exatamente o que ele escolheu. Não suba nada sozinho: se achar o modelo fraco para a tarefa, pergunte antes ("análise de firewall com haiku: mantenho ou subo para sonnet?").

## Disparo de um papel

1. **Conta.** Executor e papel que escreve por MCP: principal. Com "perguntar a cada subagente": pergunte. Com "secundária no ciclo": secundária. Com "só principal": principal.
2. **MCP, só se vai rodar na secundária.** Se o papel precisa de MCP (pelo tipo da tarefa, pelas `Ferramentas` do papel no fluxo e pelo `ferramentas.md`), rode `bash .claude/bin/secundaria.sh mcp` (sem tokens) e procure o MCP pelo nome. Conectado: siga. Ausente ou desconectado, pergunte em múltipla escolha:
   1. **Habilitar na secundária:** explique como (no claude.ai com a conta secundária, ou num terminal com `$env:CLAUDE_CONFIG_DIR` apontando para ela, `claude` e `/mcp`); o login é dele. Espere o aviso, rode `mcp` de novo e só siga com o MCP conectado.
   2. **Rodar na principal:** o papel vira subagente normal aqui.
   3. **Abortar o passo:** o cartão fica no `Status` em que está, com o motivo em "Execução"; a próxima sessão retoma dali. Não cancele o cartão.

   Anote no `cartao.md` (linha `Motores:`) quais MCPs a secundária tem, para não perguntar de novo na sessão.
3. **Modelo e esforço**, pelo tipo da tarefa (padrão ou setup).
4. **Avise numa linha e dispare**, por exemplo "análise → secundária, sonnet médio (sem risco)". Registre em "Execução" do `cartao.md` a conta, o modelo e o esforço de cada papel.

**Na principal:** subagente com o modelo e o esforço escolhidos (os parâmetros `model` e `effort` do disparo).

**Na secundária**, com o prompt pela entrada padrão:

```bash
bash .claude/bin/secundaria.sh rodar analista --model sonnet --effort medium "Bash(ssh casa *)" "mcp__claude_ai_Trello__trelloRead*" <<'PROMPT'
<o mesmo prompt que iria para o subagente>
PROMPT
```

- O papel é `analista`, `conferente` ou `geral` (papel de fluxo: o texto do papel vai no prompt). Esforço: `low`, `medium` ou `high`.
- Leitura, pesquisa e gravação já estão liberadas; as travas da operação valem e o papel só grava em `entregas/` e `backups/`. Passe só o que o papel precisa a mais: o acesso ao servidor e as ferramentas **de leitura** do MCP, com o nome que a secundária usa (a coluna "Leitura na secundária" de "MCP por conta" em `ferramentas.md`; se faltar, monte a lista e mostre ao usuário antes). Nunca libere ferramenta de MCP que escreve. O "só leitura" no servidor continua por instrução do papel.
- A saída do comando é a resposta do papel. Papel longo: rode o comando em segundo plano e leia quando terminar.
- Se o comando falhar (limite da conta, erro, sem login), mostre o erro e pergunte se o papel roda na principal.
