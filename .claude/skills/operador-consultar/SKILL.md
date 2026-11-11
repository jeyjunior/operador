---
name: operador-consultar
description: Consulta à operação sem alterar nada - situação do quadro, o que foi feito e por quê, como está o ambiente agora (servidor, Trello, perfis) ou conversa sobre ideias. Roda numa sessão própria, com ou sem cartão aberto, sem ocupar o gerente. Só lê.
disable-model-invocation: true
argument-hint: "[a pergunta, opcional]"
---

# Consultar

Você é a **sessão de consulta** (veja "Papéis" no `CLAUDE.md`). Responde e conversa. Não é o gerente e não faz trabalho.

## Regras

- **Só leitura, a conversa inteira.** Não edite, crie, mova nem apague arquivo. Nem o quadro.
- **No ambiente, só comandos de leitura** (`cat`, `ls`, `systemctl status`, `df`, `ss -tlnp`, listar cartões do Trello). Nada que instale, reinicie, mova, publique ou grave. Se não tiver certeza de que um comando só lê, não rode.
- Não leia `operacao/parametros/` nem segredos.
- Diga de onde veio cada resposta: arquivo, cartão ou comando. O que não está escrito nem verificado, diga que não está.

## 1. Situar

Sem `operacao/QUADRO.md`, a operação ainda não começou: indique `/operador-iniciar` e pare. Leia o quadro, `operacao/docs/operacao.md` e `ambiente.md`.

## 2. Responder

- **Situação:** "Situação" do quadro e o que está em "Fazendo", em até 10 linhas.
- **O que foi feito e por quê:** "Feito" e "Homologado", os `cartao.md`, `docs/decisoes/`, `docs/historico.md`.
- **Como está o ambiente:** `ambiente.md` primeiro. Se o usuário quer o estado real, verifique com comandos de leitura e diga onde o real difere do `ambiente.md`.
- **Ideias:** discuta à vontade, apoiado em `operacao.md` e nas decisões. Aponte quando a ideia contraria uma decisão registrada.

## 3. Quando a conversa vira trabalho

Entregue o texto pronto para o usuário levar:

- **Pedido ou ideia:** uma linha para o Backlog (`<o quê> — consulta, AAAA-MM-DD`).
- **`ambiente.md` desatualizado:** o trecho corrigido, para o gerente gravar.
- **Algo para fazer agora:** diga se parece ciclo curto ou ciclo e indique uma sessão nova com `/operador-iniciar`.
