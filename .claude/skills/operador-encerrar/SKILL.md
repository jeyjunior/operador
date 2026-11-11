---
name: operador-encerrar
description: Roda no gerente para fechar o cartão aberto - atualiza ambiente.md, registra lições e pendências, move o cartão para "Feito" e termina a sessão. Com "cancelar", fecha sem concluir e arquiva a pasta do cartão.
disable-model-invocation: true
argument-hint: "[cancelar, opcional]"
---

# Encerrar

Você é o **gerente** (veja "Papéis" no `CLAUDE.md`). `<cartao>` é a pasta do cartão aberto, indicada na "Situação" do quadro.

## 1. Situar

Leia `operacao/QUADRO.md` e `<cartao>/cartao.md`. Sem cartão aberto, diga isso e pare.

- `$ARGUMENTS` é `cancelar`, ou o usuário quer desistir: vá ao passo 5.
- Status antes de `conferência`: liste o que falta (plano, execução ou conferência) e pergunte se o usuário quer terminar o ciclo (volte a `/operador-iniciar`) ou cancelar.

## 2. Ambiente

Se o cartão mudou o ambiente, atualize `operacao/docs/ambiente.md` só com o que é verdade agora, citando `#NNN`, e a data em "Atualizado". Mostre o trecho ao usuário. Se nada mudou no ambiente, diga isso em uma linha.

Se o cartão revelou algo novo sobre a operação, uma ferramenta ou um fluxo, proponha a mudança em `operacao.md`, `ferramentas.md` ou no fluxo e, com o ok, grave.

## 3. Lições e pendências

1. Releia o cartão: o que deu errado, o que se repetiu, o que o usuário precisou explicar que deveria estar escrito. Proponha as lições e o que fazer com cada uma (regra em `.claude/rules/`, ajuste em `operacao.md`, `ambiente.md` ou num fluxo, ou nada). Pergunte o que o usuário acrescenta. Com o ok, aplique e grave em "Lições".
2. Cada item de "Para o backlog" entra no Backlog do quadro com um número novo do "Próximo ID".
3. Confira "Entregas": cada arquivo de `<cartao>/entregas/` está listado com uma linha do que é.

## 4. Fechar

1. Em `cartao.md`: `Status: concluído` e a data em "Fechado".
2. No quadro: o cartão vai de "Fazendo" para "Feito" (`#NNN <título> — AAAA-MM-DD — cartoes/NNN-titulo/`); a "Situação" fica com cartão "nenhum" e próximo passo "`/operador-iniciar` num gerente novo".
3. Pergunte se o resultado já foi validado no uso real. Se sim, siga `.claude/skills/operador-homologar/SKILL.md` para este cartão.
4. Diga ao usuário para fechar esta sessão: o próximo cartão começa numa sessão nova, com `/operador-iniciar`.

## 5. Cancelar

1. Peça uma confirmação explícita, citando `#NNN`.
2. Mostre as "Alterações" já feitas. Pergunte, item por item, se o usuário desfaz. Desfazer é uma ação como outra: com o ok, o `operador-sub-executor` desfaz pelo que está registrado, e o retorno vai para "Execução". Não desfaça nada sem o ok.
3. Em `cartao.md`: `Status: cancelado`, a data em "Fechado", o motivo e o que ficou alterado no ambiente. Atualize `ambiente.md` com o que ficou alterado.
4. Mova a pasta para o arquivo (não apague):
   ```bash
   mv operacao/cartoes/NNN-titulo operacao/cartoes/_arquivo/
   ```
5. No quadro: o cartão sai de "Fazendo"; se o usuário quiser retomar um dia, um item no Backlog citando `cartoes/_arquivo/NNN-titulo/`. A "Situação" fica com cartão "nenhum".
6. Diga ao usuário para fechar esta sessão. O número não é reutilizado.
