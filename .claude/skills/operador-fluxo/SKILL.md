---
name: operador-fluxo
description: Roda no gerente, sem cartão aberto. Cria ou ajusta um fluxo - uma receita de trabalho para um tipo de pedido que se repete, com os papéis (cada um vira um subagente) e as pausas em que o gerente fala com o usuário. Grava em operacao/docs/fluxos/.
disable-model-invocation: true
argument-hint: "[nome ou descrição do fluxo, opcional]"
---

# Fluxo

Você é o **gerente** (veja "Papéis" no `CLAUDE.md`). Um fluxo substitui a análise, a execução e a conferência padrão do `/operador-iniciar` para um tipo de pedido. Modelo em `.claude/modelos/documentos.md`.

## 1. Situar

1. Leia `operacao/QUADRO.md`, `operacao/docs/operacao.md`, `ferramentas.md` e os fluxos de `docs/fluxos/`. Com cartão aberto, diga que o fluxo é ajustado depois do `/operador-encerrar` e pare.
2. Novo ou ajuste? Para ajuste, mostre o fluxo atual.

## 2. Entender

Peça ao usuário para descrever o jeito de trabalhar (`$ARGUMENTS` pode já trazer). Depois pergunte só o que faltar:

- quando usar este fluxo (que pedido o dispara);
- o que o usuário entrega no começo e o que fica em `entregas/` no fim;
- para cada papel: o que faz, de que tipo é (pesquisa, análise, execução, criação ou conferência), que ferramenta usa (MCP: só leitura ou também escrita), o que entrega;
- onde o usuário quer decidir (as pausas ⏸);
- o que acontece se uma revisão reprovar: volta para qual passo, quantas vezes no máximo.

## 3. Conferir antes de gravar

- Cada ferramenta citada está `ok` em `ferramentas.md`? Se não, liste: o fluxo fica gravado, mas só roda depois de ela ser ligada (veja "Ferramentas" em `.claude/skills/operador-iniciar/SKILL.md`).
- Todo passo que publica, envia, apaga ou gasta tem um ⏸ antes.
- Toda volta tem limite de vezes e o que acontece quando esgota.
- Dois papéis que fazem a mesma coisa viram um.
- Aponte um caso concreto em que o fluxo falha e a menor mudança que resolve.

## 4. Gravar

Mostre o fluxo completo. Com o ok, grave `operacao/docs/fluxos/NN-nome.md` (NN = maior número da pasta + 1; ajuste mantém o número) com a data em "Atualizado". Decisão relevante (ferramenta paga, regra nova) vai para `docs/decisoes/`.

Diga que o fluxo vale a partir do próximo `/operador-iniciar`.
