# Relatório V1 — análise de A, B, C e D e a versão consolidada

Data: 2026-11-25 · Pasta `operador-v1`, branch `melhoria-v1` (base: `melhoria-c`, `43823a5`) · Sem commit, sem push, sem merge.

Lido: os quatro relatórios; o diff arquivo a arquivo de cada branch contra a versão atual (`correcao-travas-retomada`, `bf44f97`); o `instalar.sh` de A/C e o `atualizar-kit.sh` de B/D linha a linha; hooks, skills, modelos e testes de todas; a sessão "Subagentes comparação A/B/Atual"; e o `instalar.sh` do `construtor-equipe-v3`, que é o padrão que você pediu para o instalador seguir. Nas operações reais, só leitura do `Status` dos cartões, sem `parametros/`, `.env`, `.mcp.json` nem `settings.local.json`.

---

## 1. O que são A, B, C e D

```
bf44f97 (atual) ─┬─ A: 0bfa3a1 → 6f70b5b → e3dcf18 ── C: 43823a5 ── v1 (esta pasta)
                 ├─ B: fcbe7e9 → 96e7aa7 → ab107b6
                 └─ D: 11fdf2e
```

| | Parte de | O que trouxe | Testes (rodei de novo aqui) |
|---|---|---|---|
| Atual | — | travas confirmadas, retomada por "Onde parou" | 84 ok |
| A | atual | `instalar.sh` que mescla o `settings.json`, pausar e cancelar, hooks 2x mais rápidos, cartões em paralelo (`novo-id.sh`, `.dono`, `Alvos:`, `vez.sh`) | 104 + 30 do instalador, ok |
| B | atual | `atualizar-kit.sh` que move o próprio da operação para o `settings.local.json`, `registro.md`, rotinas, paralelo pelo `cartao.sh` | 113 ok |
| C | A | junção de A e B; corrige um bug grave de A e cinco problemas no paralelo | 118 + 30, ok |
| D | atual | o mínimo: atualizador de B, `registro.md`, peças de A; sem paralelo e sem rotinas | 99 ok |

Os números batem com os relatórios. As quatro versões preservam os dados da operação na atualização (provado por cada agente em cópias das operações 2 a 8). A diferença está no desenho e nos defeitos abaixo.

---

## 2. O que conferi além dos relatórios

- **O bug grave de A existe.** No Git Bash, `${x,,}` e o `tolower` do `gawk` estragam o UTF-8: `Concluído` vira `conclu\343\255do`. Em A, todo cartão fechado contava como aberto e o hook negaria cartão novo em toda operação. A correção de C (fechado = status que começa por `pausad`, `conclu` ou `cancelad`, só ASCII) funciona. C e D usam `${x,,}` só para comparar caminhos sem acento contra caminhos do mesmo jeito, o que é seguro.
- **A trava de cartões enxerga o caminho que o app manda.** Rodei a detecção de cartões abertos de C, só leitura, nas operações reais com `CLAUDE_PROJECT_DIR` em `D:\...`: 2_Servidor → #029; 5, 6, 7 e 8 → um cartão cada; 3 e 4 → nenhum. Nenhum teste das variantes cobria o formato `C:\...`; a v1 tem esse teste.
- **O padrão do dono é o de A.** O `construtor-equipe-v3` mescla as permissões próprias **dentro** do `settings.json` novo, guarda a versão em `.claude/VERSAO` e aplica sem perguntar quando recebe a pasta. É o que o instalador de A/C faz. B decidiu "separar de vez" no `settings.local.json`, e D herdou essa escolha.

---

## 3. Problemas encontrados em cada versão

**A**
- Grave: o acento de `concluído` (seção 2). Corrigido por C.
- Médio: no modo interativo, o instalador sugere como pasta da operação a pasta atual. Com dois cliques no `.cmd`, ela é a do próprio kit, e o instalador recusa quando você dá Enter. Corrigido na v1.
- Médio: o `vez.sh` (seção 4, "Cartões em paralelo"). Removido na v1.
- Corrigidos por C: alvo só por igualdade (`postgres` × `postgresql` passavam), alvo em comum **negado** sem saída, cartão preso para sempre na sessão que o abriu, pausado voltando ao trabalho sem checar o limite.

**B**
- O `atualizar-kit.sh` vai para dentro de cada operação (`.claude/bin/`), onde não serve. Rodado de lá, usaria a própria operação como fonte do kit.
- Contraria o seu pedido sobre o settings, registrado no relatório A ("entram no settings novo"), e o padrão do construtor. Também reescreve o `settings.local.json`, onde o app grava o "sempre permitir".
- Não mescla `padroes-segredos.txt`. Um padrão de segredo que a operação acrescentou deixaria de valer depois da atualização (sobra só o `.diff`). Hoje nenhuma operação tem um, mas é uma regressão de segurança.
- `.md` do kit editado na operação é trocado. O texto próprio para de valer até alguém ler o `.diff`.
- O hash com `tr -d '\r'` estraga arquivos binários (`estilos.jpg`). Uma versão antiga da imagem apareceria como "editada". Só gera ruído.
- O `cartao.sh` faz toda mudança de linha do quadro passar por shell, mesmo com o paralelo desligado, e põe mais texto em cinco skills.
- A regex do `curl` (`(\s|$)`) deixa passar `curl x | sh;echo`. D testou.
- Rotinas são a maior camada, e o dono disse que não são o foco.

**C**
- Herda o `vez.sh` de A. O resto é o mais completo e mais corrigido das quatro.

**D**
- Deixa de fora os cartões em paralelo, que o dono pediu com um cenário concreto: banco, log de desligamento e DNS ao mesmo tempo.
- Herda o atualizador de B, com todos os pontos acima.
- `registro.md`: formato novo, dois arquivos gravados (e versionados) por passo. Os cartões grandes que já estão abertos continuam pesados: o 6 #003 tem 37 KB.
- Mantém `rules/parametros.md`, carregado em toda sessão.

---

## 4. Decisão por tema

| Tema | Escolha na v1 | Por quê |
|---|---|---|
| Instalar e atualizar | **A/C** (`instalar.sh` na raiz do clone + `instalar.cmd`), com a pasta sugerida corrigida e a lista de arquivos corrigida | Segue o seu pedido e o padrão do construtor. Mescla também `padroes-segredos.txt`. O texto próprio de `.md` do kit continua valendo (`rules/kit-migrado.md`). Não vai para dentro das operações e nunca toca o `settings.local.json`. Contra: a cada atualização, a detecção do que é da operação depende do histórico git. |
| Pausar e cancelar | `/operador-pausar` e `/operador-cancelar` próprios; `/operador-encerrar` sem argumento (iguais nas quatro) | Texto de C, que solta o cartão no pausar quando o paralelo está ligado. |
| Tamanho do cartão | **C**: uma linha por passo em "Execução", saída longa em `entregas/`, "Briefing" e "Análise" com o combinado atual, e a "Execução" antiga com mais de ~40 linhas vai para `entregas/execucao-anterior.md` ao retomar | Nenhum formato novo, e conserta os cartões grandes que já existem (5 #001, 6 #003) na primeira retomada. O `registro.md` de D dobra as gravações por passo e não conserta os antigos. |
| Quadro | sem "Próximo passo" (A) e com a dica de D: apagar as linhas antigas "Cartão aberto"/"Próximo passo" na próxima edição | O mesmo dado em dois lugares se desencontrava (operações 4 e 8). |
| Ciclo curto | com `Status` e "Onde parou" (A) | Outra conta retoma se a sessão cair. |
| Hooks | um `jq` por hook (A); `/c/` × `C:/` (B); `sed -i` negado em todo `.md` de `operacao/` (A); `curl \| sha256sum` liberado com a regex de A | Cada um resolve uma falha vista numa operação real. |
| "Trava negou, pare" e matar só pelo PID | A | Resposta ao contorno de trava visto no 8 #008. |
| Skill `iniciar` | `motores.md` (A) e `montar.md` (B) à parte: de 14,7 para 9,4 KB | Menos tokens em toda sessão. |
| `parametros.md` | sai de `rules/` e vai para `modelos/documentos.md` (A) | Era um arquivo do kit dentro de uma pasta da operação, carregado em toda sessão. O instalador tira o antigo se ele não foi editado. |
| Secundária | recebe também os hooks do `settings.local.json` (B) | Hook próprio da operação também vale na conta 2. |
| Cartões em paralelo | **C sem o `vez.sh`** | Veja abaixo. |
| Rotinas, `registro.md`, `cartao.sh`, `ferramentas.md`/`rotina.md` à parte | fora | Não foram pedidos, ou o ganho é menor que a peça a mais. |
| Versão | `.claude/VERSAO` = `1.0.0` | No formato do construtor (`3.0.0`), batendo com o nome `operador-v1`. |

**Cartões em paralelo.** Ficam porque foram pedidos e C já os corrigiu. O padrão continua um cartão por vez, agora com trava de verdade. O que fica: `novo-id.sh` (número reservado de forma atômica), limite por hook (inclusive pausado voltando ao trabalho), dono por sessão que vence em 30 minutos, `liberar-cartao.sh`, `Alvos:` com confirmação quando há alvo em comum, reboot, firewall e restart avisando os outros cartões, e Write negado em quadro, `ambiente.md` e `historico.md` quando o paralelo está ligado.

**Por que o `vez.sh` saiu.** Ele pega uma trava no PreToolUse e só a solta no PostToolUse. Problemas:
1. Quando a edição falha (texto não encontrado, arquivo mudado) ou outro hook a nega, o PostToolUse não roda. As outras sessões esperam até 15 s em cada gravação no quadro.
2. A espera do `pegar` (até 80 tentativas, cada uma com vários processos) pode passar do timeout de 10 s do hook.
3. Com o Write já negado nesses arquivos, sobra o Edit, que troca só o trecho dele e recusa quando o arquivo mudou depois da leitura. O que o `vez.sh` ainda protege é a janela de milissegundos dentro da própria gravação.

Custo: um hook a mais em **toda** edição de **toda** operação, mesmo com o paralelo desligado. Sem ele, o `settings.json` da v1 fica idêntico ao da versão atual: nenhum hook novo. Se um dia aparecer gravação perdida no quadro com o paralelo ligado, o `vez.sh` está no branch `melhoria-c`.

---

## 5. O que é a v1

C, mais estas mudanças:

| # | Mudança | Arquivos |
|---|---|---|
| 1 | Sai o `vez.sh`, o hook de PreToolUse dele e o bloco PostToolUse. O `settings.json` fica igual ao da versão atual | `.claude/hooks/vez.sh` (removido), `.claude/settings.json` |
| 2 | Texto sobre quadro e ambiente com paralelo: só Edit; se o Edit recusar, reler e refazer o próprio trecho | `CLAUDE.md`, `README.md` |
| 3 | Instalador: a pergunta da pasta sugere a pasta **ao lado** do kit (era a do kit, recusada no Enter) | `instalar.sh` |
| 4 | Instalador: a lista de arquivos do kit ignora arquivo apagado e ainda não commitado (antes, o `cp` falhava no meio da instalação) | `instalar.sh` |
| 5 | Testes: −2 do `vez.sh`; +1 da trava de cartões com o caminho `C:\...` que o app envia; +2 do modo interativo do instalador; o teste de pasta nova confere o kit inteiro (antes conferia 2 arquivos e não pegou o item 4) | `.claude/bin/testar-hooks.sh`, `testar-instalar.sh` |
| 6 | Dica para quadro antigo: apagar "Cartão aberto" e "Próximo passo" da "Situação" (de D) | `.claude/modelos/documentos.md` |
| 7 | `VERSAO` 1.0.0 | `.claude/VERSAO` |
| 8 | Este relatório; o `RELATORIO-C.md` sai da pasta (fica no histórico) | `RELATORIO-V1.md` |

Para ver tudo o que mudou em relação a C: `git diff refs/remotes/c/melhoria-c`. Em relação à versão atual: `git diff correcao-travas-retomada`. O `ANALISE.md` local (fora do git) ganhou a seção 6.

---

## 6. Testes da v1

| Teste | Resultado |
|---|---|
| `bash .claude/bin/testar-hooks.sh` | **117 ok, 0 falha**: os 118 do C, menos os 2 do `vez.sh`, mais 1 novo (trava de cartões com o caminho `C:\...`) |
| `bash testar-instalar.sh` | **32 ok, 0 falha**: os 30 do C mais 2 do modo interativo. O teste de pasta nova agora confere o kit inteiro |
| `bash -n` em todos os scripts | ok |

**Migração em cópias das 7 operações.** As cópias foram feitas sem `parametros/`, `.env`, `.mcp.json`, `entregas/` e `backups/`, e com o `settings.local.json` trocado por um de teste. Instalação sem perguntas, retrato SHA-1 antes e depois, e segunda rodada:

| Operação | Novos | Trocados | Outros | Fora do kit | `rules/` próprias | `settings.local.json` | Arquivo de kit sem cópia | `deny` | 2ª rodada |
|---|---|---|---|---|---|---|---|---|---|
| 2_Servidor_Linux | 15 | 18 | sai `parametros.md` | igual | igual | igual | 0 | 9 → 10 | nada muda |
| 3_Doc_Space | 15 | 18 | sai `parametros.md` | igual | igual | igual | 0 | 9 → 10 | nada muda |
| 4_Worker | 15 | 18 | sai `parametros.md` | igual | igual | igual | 0 | 9 → 10 | nada muda |
| 5_GoogleFlow | 9 | 18 | sai `parametros.md` | igual | igual | igual | 0 | 9 → 10 | nada muda |
| 6_ContaModeloInstagram | 15 | 18 | sai `parametros.md` | igual | igual | igual | 0 | 9 → 10 | nada muda |
| 7_Gmail | 15 | 17 | mescla `settings.json`; sai `parametros.md` | igual | igual | igual | 0 | 29 → 30 (os 20 do Gmail ficam) | nada muda |
| 8_InsaneIA_Lab | 9 | 18 | sai `parametros.md` | igual | igual | igual | 0 | 9 → 10 | nada muda |

- Nenhum `deny` se perdeu. O que entra a mais é o `Edit(~/.ssh/**)` da correção de 18/11.
- As travas novas (`proteger-mcp`, `versionar`) chegaram ao `settings.json` das sete.
- Não houve `REVISAR.md` nem `kit-migrado.md`: nenhuma operação tinha edição local em arquivo do kit.

**O que o gerente encontra depois de migrar.** Chamei o hook nas cópias migradas como o app chama, com o caminho `C:\...`:
- 2: nega cartão novo citando o #029, e libera pausar o #029;
- 3: abre cartão novo;
- 5: libera editar o #001 e nega um segundo cartão.

O `testar-hooks.sh` rodado dentro das cópias migradas da 2 e da 7 deu "Todas as travas passaram".

**Operação que tivesse o kit do C.** Testei uma operação com o `vez.sh` e um `deny` próprio no `settings.json`, atualizada para a v1. O `vez.sh` sai e fica na cópia; o `settings.json` fica o da v1 mais o `deny` próprio, sem o PostToolUse.

**Tempo dos hooks** (Windows, média de 8 chamadas, mesma operação de teste com 30 cartões):

| Hook | Atual | v1 |
|---|---|---|
| proteger-estrutura, editando `ambiente.md` | 710 ms | 376 ms |
| proteger-estrutura, mudando o `Status` de um cartão | 735 ms | 831 ms |
| bloquear-segredos | 645 ms | 408 ms |
| versionar | 748 ms | 441 ms |
| bloquear-comandos, `ssh ... systemctl status` | 571 ms | 656 ms |
| proteger-mcp | 538 ms | 410 ms |

- Os três hooks de edição rodam juntos: a espera por edição cai de ~0,75 s para ~0,44 s.
- Mudar o `Status` de um cartão, umas 10 vezes por cartão, fica ~0,1 s mais lento: é a contagem de cartões abertos da trava.
- Comando que cita `systemctl`, `service` ou `docker` paga um `grep` a mais; os outros, não.

**Contexto.** O `/operador-iniciar` lê 5,3 KB a menos (14,7 → 9,4 KB). O que é carregado em toda sessão cresce ~1,3 KB: o `CLAUDE.md` ganha as regras de cartões em paralelo e o "trava negou, pare", e o `rules/parametros.md` (0,7 KB) sai.

---

## 7. Impacto nas operações e migração (não executado)

Positivo:
- Recebem de uma vez a correção de segurança de 18/11 (`proteger-mcp`, `versionar`, travas de `rm`, `..` e escrita por shell), pausar, cancelar, `sha256sum` liberado e hooks mais rápidos.
- Nada da operação muda (seção 6). Os 20 `deny` do Gmail continuam no `settings.json` da 7, e o `settings.local.json` nem é lido.
- O formato de cartão e quadro não muda. Cartão antigo, sem `Alvos:` e sem `.dono`, continua válido.
- Nenhum hook novo em relação à versão atual.

Atenção:
- **2_Servidor:** o #029 está em "A fazer" com `Status: análise`. Para o hook, ele está aberto e nega cartão novo até ser pausado (`/operador-iniciar` → retomar o #029 → `/operador-pausar`). A negação cita o #029.
- **5, 6, 7 e 8:** cada uma tem um cartão em `execução`. Cartão novo é negado até esse ser fechado, pausado ou cancelado. É a regra de sempre, agora com trava.
- `rules/parametros.md` sai das sete (sem edição local); fica na cópia em `operacao/.versoes/kit-<data>/`.
- `sed -i` em `.md` de `entregas/` passa a ser negado.

Passo a passo:
1. Revisar o diff da v1, fazer o commit no `melhoria-v1` e, quando quiser, push e merge.
2. No clone: `bash .claude/bin/testar-hooks.sh` e `bash testar-instalar.sh`.
3. Fechar as sessões do Claude Code das operações.
4. Para cada operação: dois cliques em `instalar.cmd`, informar `D:\1_Projetos\0_JR\jeyjunior-operador` e o nome da pasta, conferir a lista e confirmar. O esperado é `novo`/`troca`, `sai .claude/rules/parametros.md` e, na 7, `mescla .claude/settings.json`. Sem perguntas: `bash instalar.sh <pasta> --ver`, depois sem `--ver`.
5. Rodar de novo numa delas: "O kit já está atualizado. Nada muda."
6. Arrumar o estado, numa sessão normal de cada operação:
   - 2: pausar o #029 e tirar de `docs/operacao.md` a lição do `| sha256sum`;
   - 5, 6, 7 e 8: retomar e fechar, pausar ou cancelar o cartão aberto. Ao retomar os da 5 e da 6, a "Execução" antiga vai para `entregas/`;
   - 8: levar ao `operador-midia` os itens "Levar ao kit" (#003, #005).
7. Desfazer, se preciso: copiar de volta `operacao/.versoes/kit-<data>/`.
8. Paralelo é opcional e por operação: `- Cartões em paralelo: N` em `operacao/docs/operacao.md`.

---

## 8. O que não foi verificado

- As skills rodando com um modelo de verdade: pausar, retomar com "Execução" longa, `Alvos:`.
- As confirmações (`ask`) dentro do app e a conta secundária real.
- Que o Edit do app aplica a troca sobre o arquivo atual e recusa arquivo mudado também quando outra sessão grava ao mesmo tempo. É nisso que se apoia a retirada do `vez.sh`.
- A janela do `instalar.cmd` aberta com dois cliques e com digitação real. O modo interativo foi testado com respostas pela entrada padrão.
- Limites que continuam: alvos comparados por palavra; uma sessão viva parada há mais de 30 minutos perde o cartão para quem editar; sem `session_id`, o dono e a pergunta de alvos não funcionam (o limite continua); escrita por shell sem citar o caminho; MCP com nome fora do padrão.
