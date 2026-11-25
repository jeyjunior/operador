---
name: operador-iniciar
description: Entrada única do gerente. Na primeira vez, entrevista o usuário e monta a operação. Depois, retoma o cartão aberto ou abre um cartão novo e conduz o ciclo inteiro - briefing, análise por subagente, plano aprovado, execução por subagente e conferência - até o /operador-encerrar.
disable-model-invocation: true
argument-hint: "[o que você precisa, opcional]"
---

# Iniciar

Esta sessão é o **gerente** (veja "Papéis" no `CLAUDE.md`). Use os modelos de `.claude/modelos/documentos.md`. Grave cada resposta e decisão no `cartao.md` antes de seguir para o passo seguinte: é assim que um gerente novo, de qualquer conta, retoma. A cada parada (fim de passo, pausa, espera pelo usuário), regrave "Onde parou"; esperando o usuário, `Status: aguardando-usuario`, e com a resposta volte ao status do passo.

`<cartao>` é `operacao/cartoes/NNN-titulo/`, o cartão **desta sessão**. Cartões abertos são os de "Fazendo"; quantos podem ficar abertos ao mesmo tempo diz a linha "Cartões em paralelo" de `operacao/docs/operacao.md` (sem ela, 1). Veja "Cartões em paralelo" no `CLAUDE.md`.

## 1. Descobrir onde a operação está

Antes do primeiro disparo de subagente da sessão (e não antes), leia e siga `.claude/skills/operador-iniciar/motores.md` (conta, modelos e "Disparo de um papel"). Consulta não dispara; cartão retomado com linha `Motores:` não pergunta, mas o disparo segue o mesmo arquivo. Siga o primeiro caso que valer:

1. **Não existe `operacao/QUADRO.md`:** operação nova. Vá ao passo 2.
2. **Há cartão em "Fazendo" e o limite já foi atingido:** com um só, leia `<cartao>/cartao.md` e retome por "Onde parou" e pelo `Status` (passo 4 em diante). Com mais de um, mostre cada um numa linha (número, título, "Onde parou" e a hora dele) e pergunte qual esta sessão retoma: o de outra sessão ainda aberta não se retoma. Diga de onde está retomando. Pedido novo vai para o Backlog. Se o usuário quer trocar de trabalho antes de terminar, ofereça `/operador-pausar`.
3. **Nenhum cartão aberto, ou abaixo do limite:** se há cartões abertos, diga quais (eles são de outras sessões) e siga com um trabalho que não mexa nos alvos deles.
   1. Se esta conversa já fechou ou pausou um cartão, peça uma sessão nova: um cartão por gerente.
   2. Leia `operacao/docs/operacao.md`, `ambiente.md`, `ferramentas.md` e a lista de `docs/fluxos/`.
   3. Mostre o Backlog e "A fazer" em poucas linhas (cartão pausado aparece em "A fazer"). Pergunte o que será feito (`$ARGUMENTS` pode já trazer). Retomar um pausado: ele volta para "Fazendo", o `Status` volta ao que está em "Onde parou" e o trabalho segue do passo 4 em diante.
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
2. Grave `operacao/docs/operacao.md` (com a linha "Cartões em paralelo: 1"; pergunte se o usuário quer mais de um cartão aberto ao mesmo tempo), `ferramentas.md` (cada ferramenta como `pendente` até ser testada), `.claude/rules/operacao.md` e `operacao/QUADRO.md`.
3. **Levantamento do ambiente.** Proponha um cartão `#001 Levantamento do ambiente`: o `operador-sub-analista` lê o estado atual (servidor, quadro do Trello, perfis) e o gerente grava `ambiente.md`. Com o ok, siga o passo 3 com esse cartão. Se o ambiente ainda não está acessível, crie `ambiente.md` com o que o usuário contou, marcado "segundo o usuário, não verificado".
4. Ferramenta `pendente`: siga "Ferramentas" abaixo antes de qualquer cartão que dependa dela.

## 3. Briefing

1. Crie o cartão: número = o do item de Backlog/A fazer que originou, ou um novo de `bash .claude/bin/novo-id.sh` (reserva o número; duas sessões nunca recebem o mesmo). Crie `<cartao>` com `cartao.md` (`Status: briefing` e `Alvos:`), `entregas/` e `backups/`. Se o hook negar (limite de cartões abertos, alvo de outro cartão), mostre o motivo ao usuário e não contorne. No quadro, com Edit, o cartão vai para "Fazendo".
2. Veja se um fluxo de `docs/fluxos/` serve ("Quando usar"). Se servir, pergunte se usa; grave em `Fluxo:`.
3. Pergunte só o que mudar o trabalho: o que deve existir no fim, como saber que está pronto (observável), o que fica de fora. Com fluxo, pergunte a "Entrada" que ele pede. O que já está em `ambiente.md` não vira pergunta.
4. **Alvos:** o que o cartão vai alterar, em palavras curtas separadas por vírgula (ex.: `postgres`, `journald`, `ufw`, `quadro Aulas do Trello`). `*` quer dizer o ambiente inteiro (reboot, rede, firewall geral). Com cartões em paralelo, o hook nega dois cartões abertos com alvo em comum; se a análise revelar alvo novo, acrescente na linha.
5. Grave em "Briefing" e mude o `Status` para `análise`.

## 4. Análise

**Com fluxo:** siga os passos dele no lugar dos passos 4, 6 e 7. Cada papel é um subagente `general-purpose` (ou `geral` na conta secundária, veja "Disparo de um papel" em `motores.md`) com o texto do papel, os caminhos de `operacao/docs/operacao.md`, `ambiente.md` e `<cartao>`, e a regra: "grave só em `<cartao>/entregas/`; não converse com o usuário: se algo fugir do pedido, pare e devolva". Em cada ⏸, mostre o resultado ao usuário e espere. Grave o resumo de cada passo em "Execução". Se o fluxo altera algo fora de `operacao/` (publicar, mover cartão do Trello, mudar o servidor), escreva antes o passo 5 só com essas ações (backup e desfazer) e peça o ok; durante os passos do fluxo, o `Status` fica `execução`. Publicar, enviar, apagar e gastar seguem pedindo ok específico.

**Sem fluxo:** dispare o analista (veja "Disparo de um papel" em `motores.md`) com:

> Cartão #NNN. Leia `operacao/docs/operacao.md`, `operacao/docs/ambiente.md`, `operacao/docs/ferramentas.md` e o "Briefing" de `<cartao>/cartao.md`. Investigue o ambiente real só com leitura e pesquise o que faltar, com fonte e data. Devolva: situação atual, o que é viável e o que não é, 1 a 3 opções com riscos e custo, o que precisa de ferramenta que não está `ok`, e o que mudou no ambiente em relação ao `ambiente.md`.

Cartão de imagem ou vídeo sem fluxo: acrescente ao prompt "Leia também `.claude/skills/operador-midia/SKILL.md` e o que ele indicar" e o caminho da decisão visual da operação, se houver.

Pesquisas independentes podem ir em subagentes paralelos. Pesquisa que serve além deste cartão vira `docs/pesquisas/NNN-tema.md`.

Mostre o resumo, decida com o usuário a opção e grave em "Análise". Decisão que vale além do cartão vai para `docs/decisoes/`. Mude o `Status` para `plano`.

## 5. Plano

Escreva em "Plano" a lista de ações, cada uma com: o que altera, o backup (arquivo em `backups/`, ou o motivo de não haver) e como desfazer. Inclua a instalação de algo só depois da pesquisa de segurança da regra global do usuário. Marque as ações que pedem ok específico (publicar, enviar, apagar dados, gastar).

Revise antes de mostrar: nada "a definir", cada ação verificável, critério de pronto conferível. Mostre e peça o **ok explícito**. Com o ok, grave a data e as ações aprovadas em "Aprovado pelo usuário" e o `Status` `aprovado`. Ação nova depois disso: mesma linha, nova data.

## 6. Execução

Mude o `Status` para `execução` e dispare o subagente `operador-sub-executor`, sempre na principal (veja "Disparo de um papel" em `motores.md` para o modelo), com:

> Cartão #NNN. Execute o "Plano" de `<cartao>/cartao.md`, na ordem. Antes de cada ação que altera algo, salve o backup em `<cartao>/backups/`. Gere os arquivos de resultado em `<cartao>/entregas/`. Não faça nada fora do plano. Se algo der diferente do esperado, pare e devolva. Devolva, por ação: feito ou não, o comando e o trecho da saída, o backup e como desfazer.

Ações que pedem ok específico: pare antes delas, mostre ao usuário e só então dispare o executor para elas.

Grave o retorno em "Execução" e em "Alterações". Cada alteração entra na hora em `ambiente.md`, marcada `#NNN, em curso`. Se o executor parou, mostre ao usuário e decida: ajustar o plano (volta ao passo 5), desfazer ou seguir.

## 7. Conferência

Pergunte se o usuário quer conferência. Se sim, dispare o conferente (veja "Disparo de um papel" em `motores.md`) com:

> Cartão #NNN. Leia `<cartao>/cartao.md`. Confira cada critério de "Pronto quando" no ambiente real, só com leitura. Confira se cada alteração tem backup e jeito de desfazer registrados. Devolva um critério por linha: ok ou falhou, com a evidência.

Grave em "Conferência". Falha: volte ao passo 5 ou 6 com o usuário. Sem conferência, registre "dispensada pelo usuário" e o que o próprio executor mostrou.

Mude o `Status` para `conferência` e indique `/operador-encerrar`.

## Ferramentas

Quando falta uma ferramenta, ou ela está `pendente`:

1. Pesquise as opções (preferindo o que já está instalado e o oficial do serviço), aplicando a regra global de segurança de dependências do usuário a qualquer pacote ou MCP.
2. Proponha uma ao usuário, com custo e o que ela acessa.
3. O usuário liga: login no conector, chave em `operacao/parametros/` ou no cofre, `~/.ssh/config`. Alterar `.mcp.json` ou as permissões da operação (`.claude/settings.local.json`), só com o ok dele.
4. Teste com uma leitura simples e atualize `ferramentas.md` com `ok (testado AAAA-MM-DD)`.
