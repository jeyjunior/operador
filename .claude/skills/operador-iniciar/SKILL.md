---
name: operador-iniciar
description: Entrada única do gerente. Na primeira vez, entrevista o usuário e monta a operação. Depois, retoma o cartão aberto ou abre um cartão novo e conduz o ciclo inteiro - briefing, análise por subagente, plano aprovado, execução por subagente e conferência - até o /operador-encerrar.
disable-model-invocation: true
argument-hint: "[o que você precisa, opcional]"
---

# Iniciar

Esta sessão é o **gerente** (veja "Papéis" no `CLAUDE.md`). Use os modelos de `.claude/modelos/documentos.md`. Grave cada resposta e decisão no `cartao.md` antes de seguir para o passo seguinte: é assim que um gerente novo retoma.

`<cartao>` é `operacao/cartoes/NNN-titulo/`.

## 1. Descobrir onde a operação está

Uma vez por sessão, antes de tudo, siga "Motores: conta e modelos" (no fim deste arquivo). Depois, siga o primeiro caso que valer:

1. **Não existe `operacao/QUADRO.md`:** operação nova. Vá ao passo 2.
2. **O quadro tem cartão aberto:** leia `<cartao>/cartao.md` e retome pelo `Status` (passo 4 em diante). Diga de onde está retomando. Pedido novo vai para o Backlog.
3. **Nenhum cartão aberto:**
   1. Se esta conversa já fechou um cartão, peça uma sessão nova: um cartão por gerente.
   2. Leia `operacao/docs/operacao.md`, `ambiente.md`, `ferramentas.md` e a lista de `docs/fluxos/`.
   3. Mostre o Backlog e "A fazer" em poucas linhas. Pergunte o que será feito (`$ARGUMENTS` pode já trazer).
   4. Classifique com o usuário:
      - **Consulta** (só saber algo, nada muda): responda aqui mesmo, só lendo, sem criar cartão. Siga as regras de `.claude/skills/operador-consultar/SKILL.md`.
      - **Ciclo curto:** cabe nesta sessão, sem análise nem decisão. Siga `.claude/skills/operador-ciclo-curto/SKILL.md`.
      - **Ciclo:** todo o resto. Vá ao passo 3.

## 2. Montar a operação (só na primeira vez)

Uma entrevista curta, em no máximo duas rodadas:

- o que esta operação cuida, para quem e por quê;
- o ambiente: onde fica, como se acessa (sem pedir senha), o que já existe;
- as ferramentas que o usuário já usa ou quer usar;
- limites: custo, o que nunca fazer, o que só ele faz;
- como ele gosta de trabalhar (formato de relatório, nível de detalhe, tom);
- se já tem um jeito fixo de trabalhar para algum tipo de pedido (vira fluxo depois, com `/operador-fluxo`).

Com as respostas:

1. Crie `operacao/docs/{fluxos,pesquisas,decisoes}/`, `operacao/cartoes/_arquivo/` e `operacao/parametros/`.
2. Grave `operacao/docs/operacao.md`, `ferramentas.md` (cada ferramenta como `pendente` até ser testada), `.claude/rules/operacao.md` e `operacao/QUADRO.md` com "Próximo ID: 001".
3. **Levantamento do ambiente.** Proponha um cartão `#001 Levantamento do ambiente`: o `operador-sub-analista` lê o estado atual (servidor, quadro do Trello, perfis) e o gerente grava `ambiente.md`. Com o ok, siga o passo 3 com esse cartão. Se o ambiente ainda não está acessível, crie `ambiente.md` com o que o usuário contou, marcado "segundo o usuário, não verificado".
4. Ferramenta `pendente`: siga "Ferramentas" abaixo antes de qualquer cartão que dependa dela.

## 3. Briefing

1. Crie o cartão: número = "Próximo ID" (ou o do item de Backlog/A fazer que originou); incremente o "Próximo ID". Crie `<cartao>` com `cartao.md`, `entregas/` e `backups/`. No quadro, o cartão vai para "Fazendo" e a "Situação" aponta para ele.
2. Veja se um fluxo de `docs/fluxos/` serve ("Quando usar"). Se servir, pergunte se usa; grave em `Fluxo:`.
3. Pergunte só o que mudar o trabalho: o que deve existir no fim, como saber que está pronto (observável), o que fica de fora. Com fluxo, pergunte a "Entrada" que ele pede. O que já está em `ambiente.md` não vira pergunta.
4. Grave em "Briefing" e mude o `Status` para `análise`.

## 4. Análise

**Com fluxo:** siga os passos dele no lugar dos passos 4, 6 e 7. Cada papel é um subagente `general-purpose` (ou `geral` na conta secundária, veja "Disparo de um papel") com o texto do papel, os caminhos de `operacao/docs/operacao.md`, `ambiente.md` e `<cartao>`, e a regra: "grave só em `<cartao>/entregas/`; não converse com o usuário: se algo fugir do pedido, pare e devolva". Em cada ⏸, mostre o resultado ao usuário e espere. Grave o resumo de cada passo em "Execução". Ação que altera algo fora de `operacao/` (publicar, mover cartão do Trello, mudar o servidor) só com plano aprovado (passo 5) ou ok específico.

**Sem fluxo:** dispare o analista (veja "Disparo de um papel") com:

> Cartão #NNN. Leia `operacao/docs/operacao.md`, `operacao/docs/ambiente.md`, `operacao/docs/ferramentas.md` e o "Briefing" de `<cartao>/cartao.md`. Investigue o ambiente real só com leitura e pesquise o que faltar, com fonte e data. Devolva: situação atual, o que é viável e o que não é, 1 a 3 opções com riscos e custo, o que precisa de ferramenta que não está `ok`, e o que mudou no ambiente em relação ao `ambiente.md`.

Pesquisas independentes podem ir em subagentes paralelos. Pesquisa que serve além deste cartão vira `docs/pesquisas/NNN-tema.md`.

Mostre o resumo, decida com o usuário a opção e grave em "Análise". Decisão que vale além do cartão vai para `docs/decisoes/`. Mude o `Status` para `plano`.

## 5. Plano

Escreva em "Plano" a lista de ações, cada uma com: o que altera, o backup (arquivo em `backups/`, ou o motivo de não haver) e como desfazer. Inclua a instalação de algo só depois da pesquisa de segurança da regra global do usuário. Marque as ações que pedem ok específico (publicar, enviar, apagar dados, gastar).

Revise antes de mostrar: nada "a definir", cada ação verificável, critério de pronto conferível. Mostre e peça o **ok explícito**. Com o ok, grave a data em "Aprovado pelo usuário em" e o `Status` `aprovado`.

## 6. Execução

Mude o `Status` para `execução` e dispare o subagente `operador-sub-executor`, sempre na principal (veja "Disparo de um papel" para o modelo), com:

> Cartão #NNN. Execute o "Plano" de `<cartao>/cartao.md`, na ordem. Antes de cada ação que altera algo, salve o backup em `<cartao>/backups/`. Gere os arquivos de resultado em `<cartao>/entregas/`. Não faça nada fora do plano. Se algo der diferente do esperado, pare e devolva. Devolva, por ação: feito ou não, o comando e o trecho da saída, o backup e como desfazer.

Ações que pedem ok específico: pare antes delas, mostre ao usuário e só então dispare o executor para elas.

Grave o retorno em "Execução" e em "Alterações". Se o executor parou, mostre ao usuário e decida: ajustar o plano (volta ao passo 5), desfazer ou seguir.

## 7. Conferência

Pergunte se o usuário quer conferência. Se sim, dispare o conferente (veja "Disparo de um papel") com:

> Cartão #NNN. Leia `<cartao>/cartao.md`. Confira cada critério de "Pronto quando" no ambiente real, só com leitura. Confira se cada alteração tem backup e jeito de desfazer registrados. Devolva um critério por linha: ok ou falhou, com a evidência.

Grave em "Conferência". Falha: volte ao passo 5 ou 6 com o usuário. Sem conferência, registre "dispensada pelo usuário" e o que o próprio executor mostrou.

Mude o `Status` para `conferência` e indique `/operador-encerrar`.

## Ferramentas

Quando falta uma ferramenta, ou ela está `pendente`:

1. Pesquise as opções (preferindo o que já está instalado e o oficial do serviço), aplicando a regra global de segurança de dependências do usuário a qualquer pacote ou MCP.
2. Proponha uma ao usuário, com custo e o que ela acessa.
3. O usuário liga: login no conector, chave em `operacao/parametros/` ou no cofre, `~/.ssh/config`. Alterar `.mcp.json` ou `.claude/settings.json`, só com o ok dele.
4. Teste com uma leitura simples e atualize `ferramentas.md` com `ok (testado AAAA-MM-DD)`.

## Motores: conta e modelos

O usuário pode ter uma segunda conta do Claude Code na CLI para tirar consumo da conta principal, e pode escolher o modelo e o esforço de cada tipo de tarefa. `.claude/bin/secundaria.sh` cuida da secundária: a cada chamada, entrega ao papel a regra global do usuário, o `CLAUDE.md` e as rules da operação, as travas da operação e os hooks globais da principal. Nada é gravado na pasta da secundária.

### Na abertura da sessão

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

### Tipos de tarefa e padrão do operador

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

### Disparo de um papel

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
