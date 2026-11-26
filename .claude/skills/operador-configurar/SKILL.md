---
name: operador-configurar
description: Mostra e muda as configurações da operação (seção "Configurações" de operacao/docs/operacao.md), como ligar ou desligar o trabalho em paralelo. Vale para toda sessão e toda conta que abrir a operação.
disable-model-invocation: true
argument-hint: "[configuração e valor, opcional: paralelo sim]"
---

# Configurar

As configurações ficam em `operacao/docs/operacao.md`, na seção `## Configurações`, uma por linha. Elas são da operação, não da sessão: todo `/operador-iniciar`, de qualquer conta, lê dali. Só o usuário muda. Não abre cartão.

| Configuração | Valores | O que faz |
|---|---|---|
| `Cartões em paralelo` | `não` (padrão) · `sim` · número | `não`: um cartão aberto por vez; enquanto houver um em "Fazendo", nenhuma sessão abre outro. `sim`: sem limite; cada sessão abre o seu cartão sem perguntar, e o conflito com outro cartão aberto se resolve sozinho (veja "Conflito com outro cartão" no `/operador-iniciar`). Número: como `sim`, com esse limite. |

1. Leia `operacao/docs/operacao.md`. Sem ele, indique `/operador-iniciar` e pare.
2. Mostre a tabela acima com o valor atual de cada linha (sem a linha, o padrão). Se `$ARGUMENTS` já diz o que mudar, vá ao passo 3; senão pergunte.
3. Grave com Edit, só a linha da configuração. Se ela estiver em outra seção (ex.: "Limites", de operação antiga), tire de lá e ponha em `## Configurações`; sem a seção, crie-a antes de "## Como o usuário gosta de trabalhar". Atualize a data em "Atualizado:".
4. Diga o que muda a partir de agora:
   - Paralelo desligado com mais de um cartão em "Fazendo": os abertos continuam até fechar ou pausar; só não abre outro.
   - Paralelo ligado: para tocar outra tarefa, abra outra sessão na mesma pasta e rode `/operador-iniciar`.
