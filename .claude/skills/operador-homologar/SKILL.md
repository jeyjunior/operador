---
name: operador-homologar
description: Roda no gerente. Leva cartões de "Feito" para "Homologado" no quadro quando o usuário confirma que o resultado foi validado no uso real.
disable-model-invocation: true
argument-hint: "[números dos cartões, opcional]"
---

# Homologar

"Homologado" quer dizer: o usuário validou no uso real (o serviço rodou, o post foi publicado, o relatório foi entregue). Quem afirma é o usuário; você só registra.

1. Leia `operacao/QUADRO.md`. Com "Feito" vazio, diga isso e pare.
2. Pergunte quais cartões foram validados (`$ARGUMENTS` pode já trazer) e onde e como, em uma linha.
3. No topo de "Homologado", crie `### AAAA-MM-DD — <onde e como foi validado>` e mova os cartões para lá.
4. "Homologado" guarda os 3 grupos mais recentes; os anteriores vão para o topo de `operacao/docs/historico.md`, no mesmo formato.
