---
name: operador-encerrar
description: Roda no gerente para fechar o cartão aberto - atualiza ambiente.md, registra lições e pendências, move o cartão para "Feito" e termina a sessão.
disable-model-invocation: true
---

# Encerrar

Você é o **gerente** (veja "Papéis" no `CLAUDE.md`). `<cartao>` é a pasta do cartão **desta sessão** (o que ela abriu ou retomou, em "Fazendo"). Se não souber qual é, liste os de "Fazendo" e pergunte. Quadro e `ambiente.md` mudam só com Edit, trecho a trecho: outra sessão pode estar gravando neles.

## 1. Situar

Leia `operacao/QUADRO.md` e `<cartao>/cartao.md`. Sem cartão aberto, diga isso e pare.

- O usuário quer trocar de trabalho e voltar a este depois: indique `/operador-pausar` e pare.
- O usuário quer desistir: indique `/operador-cancelar` e pare.
- Status antes de `conferência`: liste o que falta (plano, execução ou conferência) e pergunte se o usuário quer terminar o ciclo (volte a `/operador-iniciar`), pausar (`/operador-pausar`) ou cancelar (`/operador-cancelar`).

## 2. Ambiente

Se o cartão mudou o ambiente, consolide `operacao/docs/ambiente.md`: só o que é verdade agora, citando `#NNN`, sem as marcas "em curso", e a data em "Atualizado". Mostre o trecho ao usuário. Se nada mudou no ambiente, diga isso em uma linha.

Se o cartão revelou algo novo sobre a operação, uma ferramenta ou um fluxo, proponha a mudança em `operacao.md`, `ferramentas.md` ou no fluxo e, com o ok, grave.

## 3. Lições e pendências

1. Releia o cartão: o que deu errado, o que se repetiu, o que o usuário precisou explicar que deveria estar escrito. Proponha as lições e o que fazer com cada uma (regra em `.claude/rules/`, ajuste em `operacao.md`, `ambiente.md` ou num fluxo, ou nada). Pergunte o que o usuário acrescenta. Com o ok, aplique e grave em "Lições".
   Lição que é do kit e não da operação (uma trava que barrou algo legítimo, uma skill que mandou fazer errado, fato genérico sobre geração de imagem ou vídeo): não edite `.claude/`. Grave o fato na operação (`docs/pesquisas/` ou `docs/decisoes/`, se servir a ela) e acrescente em "Para o backlog" um item que começa com "Levar ao kit:". O instalador do kit lista esses itens quando atualiza a operação.
2. Cada item de "Para o backlog" entra no Backlog do quadro com um número novo de `bash .claude/bin/novo-id.sh`.
3. Confira "Entregas": cada arquivo de `<cartao>/entregas/` está listado com uma linha do que é.

## 4. Fechar

1. Em `cartao.md`: `Status: concluído` e a data em "Fechado".
2. No quadro: o cartão vai de "Fazendo" para "Feito" (`#NNN <título> — AAAA-MM-DD — cartoes/NNN-titulo/`).
3. Pergunte se o resultado já foi validado no uso real. Se sim, siga `.claude/skills/operador-homologar/SKILL.md` para este cartão.
4. Diga ao usuário para fechar esta sessão: o próximo cartão começa numa sessão nova, com `/operador-iniciar`.
