---
name: operador-encerrar
description: Roda no gerente para fechar o cartão aberto - atualiza ambiente.md, registra lições e pendências, move o cartão para "Feito" e termina a sessão. Com "pausar", tira o cartão de "Fazendo" sem fechar; com "cancelar", fecha sem concluir e arquiva; com "homologar", leva cartões de "Feito" para "Homologado".
disable-model-invocation: true
argument-hint: "[pausar | cancelar | homologar, opcional]"
---

# Encerrar

Você é o **gerente** (veja "Papéis" no `CLAUDE.md`). `<cartao>` é a pasta do cartão aberto, indicada em "Cartão aberto" na "Situação" do quadro.

## 1. Situar

Leia `operacao/QUADRO.md`.

- `$ARGUMENTS` é `homologar`: vá ao passo 7 (não precisa de cartão aberto).
- Sem cartão aberto: diga isso e pare.
- Leia `<cartao>/cartao.md`.
- `$ARGUMENTS` é `pausar`, ou o usuário quer trocar de trabalho e voltar a este depois: vá ao passo 6.
- `$ARGUMENTS` é `cancelar`, ou o usuário quer desistir: vá ao passo 5.
- Status antes de `conferência`: liste o que falta (plano, execução ou conferência) e pergunte se o usuário quer terminar o ciclo (volte a `/operador-iniciar`), pausar ou cancelar.

## 2. Ambiente

Se o cartão mudou o ambiente, consolide `operacao/docs/ambiente.md`: só o que é verdade agora, citando `#NNN`, sem as marcas "em curso", e a data em "Atualizado". Mostre o trecho ao usuário. Se nada mudou no ambiente, diga isso em uma linha.

Se o cartão revelou algo novo sobre a operação, uma ferramenta ou um fluxo, proponha a mudança em `operacao.md`, `ferramentas.md` ou no fluxo e, com o ok, grave.

## 3. Lições e pendências

1. Releia o cartão: o que deu errado, o que se repetiu, o que o usuário precisou explicar que deveria estar escrito. Proponha as lições e o que fazer com cada uma (regra em `.claude/rules/`, ajuste em `operacao.md`, `ambiente.md` ou num fluxo, ou nada). Pergunte o que o usuário acrescenta. Com o ok, aplique e grave em "Lições".
   Lição que é do kit e não da operação (uma trava que barrou algo legítimo, uma skill que mandou fazer errado, fato genérico sobre geração de imagem ou vídeo): não edite `.claude/`. Grave o fato na operação (`docs/pesquisas/` ou `docs/decisoes/`, se servir a ela) e acrescente em "Para o backlog" um item que começa com "Levar ao kit:". O `atualizar-kit.sh` lista esses itens quando o kit é atualizado.
2. Cada item de "Para o backlog" entra no Backlog do quadro com um número novo do "Próximo ID".
3. Confira "Entregas": cada arquivo de `<cartao>/entregas/` está listado com uma linha do que é.

## 4. Fechar

1. Em `cartao.md`: `Status: concluído` e a data em "Fechado".
2. No quadro: o cartão vai de "Fazendo" para "Feito" (`#NNN <título> — AAAA-MM-DD — cartoes/NNN-titulo/`); "Cartão aberto" fica "nenhum".
3. Pergunte se o resultado já foi validado no uso real. Se sim, siga o passo 7 para este cartão.
4. Diga ao usuário para fechar esta sessão: o próximo cartão começa numa sessão nova, com `/operador-iniciar`.

## 5. Cancelar

1. Peça uma confirmação explícita, citando `#NNN`.
2. Mostre as "Alterações" já feitas. Pergunte, item por item, se o usuário desfaz. Desfazer é uma ação como outra: com o ok, o `operador-sub-executor` desfaz pelo que está registrado, e o retorno vai para "Execução". Não desfaça nada sem o ok.
3. Em `cartao.md`: `Status: cancelado`, a data em "Fechado", o motivo e o que ficou alterado no ambiente. Atualize `ambiente.md` com o que ficou alterado.
4. Mova a pasta para o arquivo (não apague):
   ```bash
   mv operacao/cartoes/NNN-titulo operacao/cartoes/_arquivo/
   ```
5. No quadro: o cartão sai de "Fazendo"; se o usuário quiser retomar um dia, um item no Backlog citando `cartoes/_arquivo/NNN-titulo/`. "Cartão aberto" fica "nenhum".
6. Diga ao usuário para fechar esta sessão. O número não é reutilizado.

## 6. Pausar

O cartão para de ocupar "Fazendo" sem perder nada; a pasta fica onde está.

1. Regrave "Onde parou" com o que falta e o status em que o trabalho estava (ex.: "Status ao retomar: análise"). Em `cartao.md`: `Status: pausado`.
2. `ambiente.md` já está com as marcas `#NNN, em curso` das alterações feitas: deixe como está, para quem consultar saber que há algo pela metade.
3. No quadro: o cartão sai de "Fazendo" e vai para o topo de "A fazer" (`#NNN <título> — pausado em AAAA-MM-DD: <próximo passo> — cartoes/NNN-titulo/`); "Cartão aberto" fica "nenhum".
4. Diga ao usuário para fechar esta sessão. O `/operador-iniciar` numa sessão nova mostra o pausado em "A fazer" e retoma de "Onde parou".

## 7. Homologar

"Homologado" quer dizer: o usuário validou no uso real (o serviço rodou, o post foi publicado, o relatório foi entregue). Quem afirma é o usuário; você só registra.

1. Com "Feito" vazio, diga isso e pare.
2. Pergunte quais cartões foram validados (pode já vir no pedido) e onde e como, em uma linha.
3. No topo de "Homologado", crie `### AAAA-MM-DD — <onde e como foi validado>` e mova os cartões para lá.
4. "Homologado" guarda os 3 grupos mais recentes; os anteriores vão para o topo de `operacao/docs/historico.md`, no mesmo formato.
