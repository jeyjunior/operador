---
name: operador-ciclo-curto
description: Trabalho pequeno numa sessão só - um ajuste, uma instalação simples, um relatório rápido - sem análise nem decisão. Mostra o que vai fazer, pede o ok, faz com backup e registra direto em "Feito".
disable-model-invocation: true
argument-hint: "[o que fazer]"
---

# Ciclo curto

Você é o **gerente** (veja "Papéis" no `CLAUDE.md`), num trabalho que cabe nesta sessão.

## 1. Cabe aqui?

1. Leia `operacao/QUADRO.md`, `operacao/docs/ambiente.md` e `ferramentas.md`. Sem quadro, indique `/operador-iniciar` e pare. Se o limite de cartões abertos já foi atingido (linha "Cartões em paralelo" de `operacao/docs/operacao.md`; sem ela, 1), o pedido vai para o Backlog: pare.
2. Não é ciclo curto se pede escolha entre opções, pesquisa, instalação de algo novo, mais de uma sessão, ou se é difícil de desfazer. Diga isso e indique `/operador-iniciar`.

## 2. Combinar

Diga em até 5 linhas: o que vai fazer, o que altera, o backup e como desfazer, e como vai provar que funcionou. Espere o ok.

## 3. Fazer

1. Número: o do item do Backlog que originou, ou um novo de `bash .claude/bin/novo-id.sh`. Se o trabalho altera algo ou gera arquivo, crie `operacao/cartoes/NNN-titulo/` com `cartao.md` no modelo de ciclo curto de `.claude/modelos/documentos.md` (`Status: execução` e "Onde parou", para outra sessão retomar se esta cair) e as pastas que usar; com a linha `Alvos:` (veja o passo 3 do `/operador-iniciar`). Conflito com outro cartão aberto: "Conflito com outro cartão" do `/operador-iniciar`, sem perguntar ao usuário. Enquanto durar, ele fica em "Fazendo". No fim, `Status: concluído`.
2. Faça só o combinado: backup em `backups/` antes de alterar, arquivos de resultado em `entregas/`. Pode fazer você mesmo ou com o `operador-sub-executor`.
3. Prove: rode a verificação combinada e mostre o trecho da saída.

## 4. Registrar

1. Se mudou o ambiente, atualize `ambiente.md` citando `#NNN`.
2. No quadro, em "Feito": `#NNN [curto] <o que foi feito> — AAAA-MM-DD — cartoes/NNN-titulo/` (ou "sem pasta"). Se veio do Backlog, tire de lá.

Comece a última resposta pelo resultado (ex.: `#014 [curto]: feito`).
