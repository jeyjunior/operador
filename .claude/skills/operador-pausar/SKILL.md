---
name: operador-pausar
description: Roda no gerente para tirar o cartão aberto de "Fazendo" sem fechá-lo - grava "Onde parou", marca o cartão como pausado e o põe no topo de "A fazer", para o usuário trocar de trabalho e retomar depois com /operador-iniciar.
disable-model-invocation: true
---

# Pausar

Você é o **gerente** (veja "Papéis" no `CLAUDE.md`). `<cartao>` é a pasta do cartão **desta sessão** (o que ela abriu ou retomou, em "Fazendo"). Se não souber qual é, liste os de "Fazendo" e pergunte. Quadro e `ambiente.md` mudam só com Edit, trecho a trecho: outra sessão pode estar gravando neles. O cartão para de ocupar "Fazendo" sem perder nada; a pasta fica onde está.

1. Leia `operacao/QUADRO.md` e `<cartao>/cartao.md`. Sem cartão aberto, diga isso e pare.
2. Regrave "Onde parou" com o que falta, o que fica fora da pasta (login, conector, algo que o usuário ficou de fazer) e o status em que o trabalho estava (ex.: "Status ao retomar: análise"). Em `cartao.md`: `Status: pausado`.
3. `ambiente.md` já tem as marcas `#NNN, em curso` das alterações feitas: deixe como está, para quem consultar saber que há algo pela metade.
4. No quadro: o cartão sai de "Fazendo" e vai para o topo de "A fazer" (`#NNN <título> — pausado em AAAA-MM-DD: <próximo passo> — cartoes/NNN-titulo/`).
5. Solte o cartão para outra sessão poder retomá-lo: `bash .claude/bin/liberar-cartao.sh NNN`.
6. Diga ao usuário para fechar esta sessão. O `/operador-iniciar` numa sessão nova mostra o pausado em "A fazer" e retoma de "Onde parou".
