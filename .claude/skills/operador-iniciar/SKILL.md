---
name: operador-iniciar
description: Entrada única do gerente. Na primeira vez, entrevista o usuário e monta a operação. Depois, retoma o cartão aberto ou abre um cartão novo e conduz o ciclo inteiro - briefing, análise por subagente, plano aprovado, execução por subagente e conferência - até o /operador-encerrar.
disable-model-invocation: true
argument-hint: "[o que você precisa, opcional]"
---

# Iniciar

Esta sessão é o **gerente** (veja "Papéis" no `CLAUDE.md`). Use os modelos de `.claude/modelos/documentos.md`. Grave cada resposta e decisão no `cartao.md` antes de seguir para o passo seguinte: é assim que um gerente novo, de qualquer conta, retoma. A cada parada (fim de passo, pausa, espera pelo usuário), regrave "Onde parou"; esperando o usuário, `Status: aguardando-usuario`, e com a resposta volte ao status do passo.

`<cartao>` é `operacao/cartoes/NNN-titulo/`, o cartão **desta sessão**. Cartões abertos são os de "Fazendo"; quantos podem ficar abertos ao mesmo tempo diz a linha "Cartões em paralelo" de `operacao/docs/operacao.md` (`não` ou sem ela: 1; `sim`: sem limite; número: o limite). Quem muda é o usuário, com `/operador-configurar`. Com o paralelo ligado, abra o cartão desta sessão sem perguntar se pode trabalhar em paralelo e sem pedir ao usuário que decida conflito: ele se resolve pela seção "Conflito com outro cartão".

## 1. Descobrir onde a operação está

Antes do primeiro disparo de subagente da sessão (e não antes), leia e siga `.claude/skills/operador-iniciar/motores.md` (conta, modelos e "Disparo de um papel"). Consulta não dispara; cartão retomado com linha `Motores:` não pergunta, mas o disparo segue o mesmo arquivo. Siga o primeiro caso que valer:

1. **Não existe `operacao/QUADRO.md`:** operação nova. Leia e siga `.claude/skills/operador-iniciar/montar.md`.
2. **Há cartão em "Fazendo" e o limite já foi atingido** (com o paralelo desligado, basta um): com um só, leia `<cartao>/cartao.md` e retome por "Onde parou" e pelo `Status` (passo 4 em diante). Com mais de um, mostre cada um numa linha (número, título, "Onde parou" e a hora dele) e pergunte qual esta sessão retoma: o de outra sessão ainda aberta não se retoma ("Onde parou" atualizado há menos de 30 minutos é sinal de sessão viva; o hook nega editar o cartão dela). Diga de onde está retomando. Ao retomar, se "Execução" passa de umas 40 linhas, mova as linhas antigas para `<cartao>/entregas/execucao-anterior.md` e deixe uma linha apontando o arquivo. Pedido novo vai para o Backlog. Se o usuário quer trocar de trabalho antes de terminar, ofereça `/operador-pausar`.
3. **Nenhum cartão aberto, ou abaixo do limite:** se há cartões abertos, diga numa linha quais (eles são de outras sessões) e siga, sem perguntar. Cartão com `Status: esperando` é de uma sessão viva que está esperando outro cartão: não se retoma.
   1. Se esta conversa já fechou ou pausou um cartão, peça uma sessão nova: um cartão por gerente.
   2. Leia `operacao/docs/operacao.md`, `ambiente.md`, `ferramentas.md` e a lista de `docs/fluxos/`.
   3. Mostre o Backlog e "A fazer" em poucas linhas (cartão pausado aparece em "A fazer"). Pergunte o que será feito (`$ARGUMENTS` pode já trazer). Retomar um pausado: ele volta para "Fazendo", o `Status` volta ao que está em "Onde parou" e o trabalho segue do passo 4 em diante. Item do Backlog marcado "devolvido" já tem pasta: use a mesma, com `Status: briefing`.
   4. Classifique com o usuário:
      - **Consulta** (só saber algo, nada muda): responda aqui mesmo, só lendo, sem criar cartão. Siga as regras de `.claude/skills/operador-consultar/SKILL.md`.
      - **Ciclo curto:** cabe nesta sessão, sem análise nem decisão. Siga `.claude/skills/operador-ciclo-curto/SKILL.md`.
      - **Ciclo:** todo o resto. Vá ao passo 3.

## 3. Briefing

1. Crie o cartão: número = o do item de Backlog/A fazer que originou, ou um novo de `bash .claude/bin/novo-id.sh` (reserva o número; duas sessões nunca recebem o mesmo). Crie `<cartao>` com `cartao.md` (`Status: briefing` e `Alvos:`), `entregas/` e `backups/`. Se o hook negar pelo limite de cartões abertos, mostre o motivo ao usuário e não contorne. Se negar por alvo em comum com outro cartão aberto, siga "Conflito com outro cartão". No quadro, com Edit, o cartão vai para "Fazendo".
2. Veja se um fluxo de `docs/fluxos/` serve ("Quando usar"). Se servir, pergunte se usa; grave em `Fluxo:`.
3. Pergunte só o que mudar o trabalho: o que deve existir no fim, como saber que está pronto (observável), o que fica de fora. Com fluxo, pergunte a "Entrada" que ele pede. O que já está em `ambiente.md` não vira pergunta.
4. **Alvos:** o que o cartão vai alterar, em palavras curtas separadas por vírgula (ex.: `postgres`, `journald`, `ufw`, `quadro Aulas do Trello`). `*` quer dizer o ambiente inteiro (reboot, rede, firewall geral). Se a análise revelar alvo novo, acrescente na linha. Com cartões em paralelo, veja aqui e de novo no fim da análise se este cartão depende do resultado de um cartão aberto ou atrapalha o trabalho dele, mesmo sem alvo de nome parecido: se sim, siga "Conflito com outro cartão".
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

## Conflito com outro cartão

Vale com cartões em paralelo, em qualquer passo: o hook negou por alvo em comum (ao abrir, retomar ou acrescentar alvo) ou porque um comando afeta o cartão de outra sessão (reboot, firewall, restart de um alvo dele), ou você viu que este cartão depende do resultado de outro aberto. **Não pergunte ao usuário o que fazer**: decida entre as duas saídas abaixo e avise numa linha qual tomou e por quê.

- **Esperar** quando o outro cartão está em `aprovado`, `execução` ou `conferência` (perto de acabar), ou quando este cartão já alterou algo (`Alterações` com linhas).
  1. Em "Onde parou": o próximo passo e `Esperando: cartão #NNN`. Em `cartao.md`: `Status: esperando #NNN`. No quadro, na linha dele em "Fazendo": ` — esperando #NNN`.
  2. Rode em segundo plano `bash .claude/bin/esperar-cartao.sh NNN` (espera até 120 min; o segundo argumento muda isso). Ele termina quando o outro cartão fecha, pausa, espera ou é devolvido.
  3. Saiu 0: releia `ambiente.md` (o outro cartão pode ter mudado o alvo), tire a marca do quadro, volte o `Status` ao de "Onde parou" e siga. Se o hook negar de novo (um terceiro cartão pegou o alvo), espere esse.
  4. Saiu 1 (tempo acabou): devolva, se este cartão não alterou nada; senão, `/operador-pausar`.
- **Devolver** quando o outro cartão está em `briefing`, `análise`, `plano` ou `aguardando-usuario` (sem previsão de fim) e este cartão **não alterou nada**. Cancela sem registro: nada em "Execução", "Alterações" nem `ambiente.md`.
  1. Pasta ainda não criada: não crie; o item fica (ou volta) no Backlog.
  2. Pasta criada: em `cartao.md`, `Status: devolvido` e uma linha em "Onde parou" (`Devolvido: depende de #NNN`). Rode `bash .claude/bin/liberar-cartao.sh <este número>`. No quadro, o cartão sai de "Fazendo" e volta ao Backlog (`#NNN <título> — devolvido: depende de #MMM — cartoes/NNN-titulo/`).
  3. Diga ao usuário para fechar esta sessão. O cartão volta pelo `/operador-iniciar` quando o outro terminar.

Cartão esperando ou devolvido não ocupa vaga nem trava alvo, então dois cartões nunca esperam um pelo outro.

## Ferramentas

Quando falta uma ferramenta, ou ela está `pendente`:

1. Pesquise as opções (preferindo o que já está instalado e o oficial do serviço), aplicando a regra global de segurança de dependências do usuário a qualquer pacote ou MCP.
2. Proponha uma ao usuário, com custo e o que ela acessa.
3. O usuário liga: login no conector, chave em `operacao/parametros/` (formato `parametro.json` de `.claude/modelos/documentos.md`) ou no cofre, `~/.ssh/config`. Alterar `.mcp.json` ou as permissões da operação (`.claude/settings.local.json`), só com o ok dele.
4. Teste com uma leitura simples e atualize `ferramentas.md` com `ok (testado AAAA-MM-DD)`.
