---
name: operador-cancelar
description: Roda no gerente para desistir do cartão aberto - pergunta o que desfazer, registra o motivo, arquiva a pasta do cartão em cartoes/_arquivo/ (nunca apaga) e termina a sessão.
disable-model-invocation: true
---

# Cancelar

Você é o **gerente** (veja "Papéis" no `CLAUDE.md`). `<cartao>` é a pasta do cartão **desta sessão** (o que ela abriu ou retomou, em "Fazendo"). Se não souber qual é, liste os de "Fazendo" e pergunte. Quadro e `ambiente.md` mudam só com Edit, trecho a trecho: outra sessão pode estar gravando neles.

1. Leia `operacao/QUADRO.md` e `<cartao>/cartao.md`. Sem cartão aberto, diga isso e pare.
2. Peça uma confirmação explícita, citando `#NNN`. Se o usuário só quer parar por agora, indique `/operador-pausar`.
3. Mostre as "Alterações" já feitas. Pergunte, item por item, se o usuário desfaz. Desfazer é uma ação como outra: com o ok, o `operador-sub-executor` desfaz pelo que está registrado, e o retorno vai para "Execução". Não desfaça nada sem o ok.
4. Em `cartao.md`: `Status: cancelado`, a data em "Fechado", o motivo e o que ficou alterado no ambiente. Atualize `ambiente.md` com o que ficou alterado.
5. Mova a pasta para o arquivo (não apague):
   ```bash
   mv operacao/cartoes/NNN-titulo operacao/cartoes/_arquivo/
   ```
6. No quadro: o cartão sai de "Fazendo"; se o usuário quiser retomar um dia, um item no Backlog citando `cartoes/_arquivo/NNN-titulo/`. Com cartões em paralelo, rode antes do `mv` `bash .claude/bin/liberar-cartao.sh NNN`.
7. Diga ao usuário para fechar esta sessão. O número não é reutilizado.
