# Relatório C — junção de A, B e da versão atual

Data: 2026-11-25 · Branch `melhoria-c` (base: `melhoria-a`, `e3dcf18`) · Sem push, sem merge.

Comparadas: **Atual** (`operador/`, `correcao-travas-retomada`, `bf44f97`), **A** (`melhoria-a`, `e3dcf18`, com `RELATORIO-A.md`) e **B** (`melhoria-b`, `ab107b6`, com `RELATORIO-B.md`). Lidos arquivo a arquivo: `.claude/` inteiro, `CLAUDE.md`, `README.md`, `ANALISE.md`, instaladores, scripts de atualização e testes. Operações (só leitura, sem `parametros/`, `.env` nem `settings.local.json`): 2 a 8 e `operador-usar`; a 9 está vazia.

O objetivo do kit (README): cada operação guarda quadro, ambiente e histórico em arquivo, para qualquer sessão retomar sem o usuário reexplicar; o gerente conversa, os subagentes analisam, executam e conferem; nada muda fora da pasta sem plano, backup e ok. Toda escolha abaixo foi pesada contra isso e contra o custo de levar a mudança às 7 operações que já existem.

---

## 1. Estado das operações hoje

- Todas ainda estão no kit de 2026-11-11/16: sem `proteger-mcp.sh`, `versionar.sh`, `.claude/VERSAO`, e com `rules/parametros.md`. Nenhuma recebeu a correção de 18/11 nem A nem B.
- Personalização: `rules/` próprias em todas; 20 `deny` de MCP do Gmail no `settings.json` da 7; `settings.local.json` na 2 (não lido).
- Cartões com status de trabalho: 2 #029 (`análise`, mas em "A fazer": pausa improvisada), 5 #001, 6 #003 (37 KB), 7 #002, 8 #008 (todos `execução`). 4 #011, citado por A e B, já fechou.
- Quadros ainda com "Próximo passo" e "Próximo ID" na "Situação".

---

## 2. Comparação por tema

| Tema | Atual | A | B | Em C |
|---|---|---|---|---|
| Instalar e atualizar | cópia manual do `operador-usar` (perde o `settings.json` da 7) | `instalar.sh` na raiz do clone + `instalar.cmd`; reconhece versões pelo histórico git; **mescla** o `settings.json`; texto próprio de `.md` do kit vai para `rules/kit-migrado.md`; cópia em `.versoes/kit-<data>/` + `REVISAR.md`; nunca toca `settings.local.json` | `.claude/bin/atualizar-kit.sh` (vai para dentro de cada operação) + `.cmd`; **move** o que é da operação para o `settings.local.json`; `.md` editado vira só `.diff`; tira BOM e `\r` da resposta | **A** + limpeza de BOM e `\r` de B |
| Comandos | 6 (sem pausar/cancelar) | `/operador-pausar`, `/operador-cancelar` próprios | idem | **A** (equivalentes); "o que fica fora da pasta" no pausar, de B |
| Tamanho do cartão | "Execução" vira diário (até 24 KB) | "Execução" com uma linha por passo, saída longa em `entregas/` | `registro.md` separado, só acrescentado, a retomada não lê | **A** + regra de B "Briefing e Análise guardam o combinado atual" + mover a "Execução" longa ao retomar |
| Rotinas | — | fora (dono disse que não é foco) | `rotinas/NN/` com autorização e teto, seção no quadro, `rotina.md` | **fora** |
| Quadro | "Próximo passo" na Situação | sem "Próximo passo" (só em "Onde parou") | mantém, com outro sentido | **A** |
| `curl \| sha256sum` | negado (falso positivo) | liberado; `\| sh`, `\| sudo bash`, `\| zsh` negados | liberado | **A** (regex mais completa) |
| Caminho `/c/...` × `C:/...` | falha calada | — | normaliza | **B** (estava pela metade no C, agora com teste) |
| Velocidade dos hooks | 0,6–0,8 s | 1 `jq` por hook, ~2x mais rápido nas edições | sem mudança | **A** (e C ficou igual ou mais rápido que A, seção 5) |
| Skill `iniciar` | 14,7 KB | 10,4 KB (`motores.md` à parte) | 8,3 KB (`motores`, `montar`, `rotina`, `ferramentas`) | **A** + `montar.md` de B: 8,9 KB |
| `rules/parametros.md` | em `rules/` (carregado sempre) | vira seção de `modelos/documentos.md` | fica | **A**, com o ponteiro para `parametro.json` no `montar.md` e em "Ferramentas" |
| "Trava negou, pare"; executor mata só pelo PID | — | sim | — | **A** |
| Ciclo curto com `Status` e "Onde parou" | — | sim | — | **A** |
| Secundária recebe hooks do `settings.local.json` | só permissões | só permissões | permissões e hooks | **B** |
| Paralelo: onde liga | — | `Cartões em paralelo: N` em `operacao/docs/operacao.md` | `**Cartões em paralelo:** sim, até N` em `rules/operacao.md` | **A** |
| Paralelo: números | "Próximo ID" à mão | `novo-id.sh` (reserva em `.ids/`) | `cartao.sh id` (reescreve o quadro sob trava) | **A** |
| Paralelo: quadro e ambiente | Write livre | só Edit + `vez.sh` (uma sessão grava por vez) | `cartao.sh quadro/ambiente` (shell sob trava) | **A** (as skills continuam com Edit; versão anterior pelo `versionar.sh`) |
| Paralelo: dono do cartão | — | primeira sessão, para sempre, até `liberar-cartao.sh` | última sessão; outra **pede confirmação**; livre após 30 min | **mistura**: outra sessão é **negada** enquanto a dona editou há menos de 30 min; depois assume sozinha; `liberar-cartao.sh` libera antes |
| Paralelo: alvos | igualdade exata; conflito **nega** | igualdade exata; `cartao.sh conflitos` só avisa | igualdade, `*` ou um começando pelo outro (≥ 4 letras: `postgres`/`postgresql`, `/etc`/`/etc/fstab`); **pede confirmação**, uma vez por mudança de alvos |
| Paralelo: limite | — | só cartão novo | só cartão novo | cartão novo **e pausado voltando ao trabalho**; reserva de pasta vence em 10 min |
| Paralelo: ação compartilhada | — | reboot/firewall citam os outros cartões | `systemctl/service/docker restart\|stop` pedem confirmação | os dois |
| Testes | 84 | 104 + 30 do instalador | 113 (instalador dentro) | **118 + 30** |

---

## 3. Veredito por tema (por quê)

**Instalação e atualização: A.** As duas migram sem perder nada, mas A é mais segura para as operações que existem:
- não toca o `settings.local.json`, que é também onde o app grava o "sempre permitir" e pode ter conteúdo sensível (B reescreve esse arquivo em toda operação com permissão própria);
- texto próprio num `.md` do kit continua valendo (vai para `rules/kit-migrado.md`); em B vira só um `.diff` que ninguém lê;
- fica na raiz do clone; o de B é copiado para dentro de cada operação, onde não serve (o "kit" passaria a ser a própria operação).
- De B entrou a limpeza do caminho digitado: BOM e `\r` (B achou o caso real: resposta pelo PowerShell criou pasta no lugar errado).

**Cartão menor: A, sem `registro.md`.** O `registro.md` resolve a retomada, mas cria um segundo arquivo por cartão, mais uma trava, mais texto nas skills e um formato que as operações não conhecem. A regra de A (uma linha por passo, saída em `entregas/`) chega ao mesmo resultado sem mudar o formato. De B entrou a parte que A não tinha: "Briefing" e "Análise" guardam o combinado atual (o 8 #008 acumulava rodadas no Briefing). "Plano" ficou de fora dessa regra porque guarda o rastro das aprovações. Para os cartões abertos que já estão grandes (5 #001, 6 #003), o `/operador-iniciar`, ao retomar, move as linhas antigas da "Execução" para `entregas/execucao-anterior.md`.

**Rotinas: fora.** Há sinal de necessidade (4_Worker roda à noite fora do kit e falhou calado; 3_Doc_Space repete "Aula N"), mas é a maior camada proposta, o dono disse que não é o foco, e muda quadro, estrutura, hooks e skills. Fica como próximo cartão do kit, de preferência começando pelo aviso menor que A sugeriu (log da rotina externa lido ao abrir a sessão).

**Cartões em paralelo: base A, com três ideias de B.**
- Mantida de A a forma de gravar: o gerente edita quadro e ambiente com Edit, como sempre, e o `vez.sh` garante uma gravação por vez. O `cartao.sh` de B obriga o modelo a montar a linha exata do quadro num comando de shell, fora do `versionar.sh`, e é mais texto em toda skill.
- De B: dono que vence por inatividade. Com o dono "para sempre" de A, uma sessão fechada sem pausar (o caso mais comum nas operações: 5 cartões parados) prenderia o cartão até o usuário rodar o `liberar-cartao.sh`. Em C a outra sessão é negada só enquanto a dona editou há menos de 30 minutos; o "Onde parou" é regravado a cada parada, então sessão viva edita com frequência.
- De B: alvo em comum **pede confirmação** em vez de negar. Com a comparação por começo de palavra (que pega `postgres`/`postgresql`, o limite que A deixou em aberto), negar daria falso positivo sem saída; perguntando, o usuário decide (esperar, pausar, juntar ou seguir). Só pergunta quando os alvos mudam, não a cada edição.
- De B: `systemctl/service/docker restart|stop` pede confirmação enquanto outra sessão tem cartão aberto (cobre o "coisas que se afetam sem o mesmo nome").
- Correções novas: pausado que volta ao trabalho conta no limite (em A, mudar `Status: pausado` para `execução` passava do limite sem checagem); reserva de pasta cuja gravação foi negada vence em 10 min (em A contava como aberta até `liberar-cartao.sh`).

**Outros:** "trava negou, pare", PID, ciclo curto com status, quadro sem "Próximo passo", `sha256sum`, hooks rápidos e `parametros.md` fora de `rules/` vêm de A, sem mudança. `/c/` × `C:/` e os hooks do `settings.local.json` na secundária vêm de B. `montar.md` de B tira 1,5 KB do `iniciar` em toda sessão depois da primeira.

---

## 4. Problemas encontrados e corrigidos

1. **Grave (em A, chegaria a todas as operações): cartão "concluído" contado como aberto.** No Git Bash, o `tolower` do `gawk` e o `${x,,}` do bash estragam o UTF-8 (`concluído` vira `conclu\xe3\xadd o`), e a comparação com `concluído` falha. Na cópia migrada da 2_Servidor, o hook via **11 cartões abertos** (todos os fechados) e negaria qualquer cartão novo em toda operação. Os testes de A só usavam `pausado`. Correção: fechado é o status que começa por `pausad`, `conclu` ou `cancelad` (só ASCII). Teste novo com `concluído`, `Concluído` e `cancelado`. Depois da correção: 2 → só o #029; 3 e 4 → nenhum; 5, 6, 7, 8 → o cartão em execução de cada uma.
2. **Alterações não commitadas que já estavam em C** (trazidas de B antes desta tarefa):
   - usavam `COMPARTILHADO` sem definir o array: o `grep` com padrão vazio casa tudo, e **todo comando** pediria confirmação quando outra sessão tivesse cartão aberto. Array definido, com pré-filtro sem processo (`systemctl|service|docker`).
   - citavam `registro.md` nas mensagens, sem o `registro.md` existir em C. Revertido.
   - mudaram "alvo em comum" de negar para perguntar sem ajustar os testes (2 falhas). Testes ajustados; a pergunta agora só sai quando os alvos mudam (antes, todo Write do cartão perguntava de novo).
   - liam `.dono` inexistente com erro no stderr (`{ read; } < arquivo 2>/dev/null` abre o arquivo antes de redirecionar o erro). Corrigido.
   - `limite_paralelo` pegava o primeiro número da linha (`não (desde 2026-11-25)` virava 2026). Agora só o número logo depois dos dois-pontos.
3. **Custo do hook:** a versão não commitada rodava `cartoes_abertos` (um `awk`) em toda edição de `cartao.md`, mesmo no modo de um por vez. Agora só quando o cartão é novo, muda de status ou o paralelo está ligado.

---

## 5. Impacto

### Nas operações atuais (com cartões abertos e personalizações)

Positivo:
- Recebem, de uma vez, a correção de segurança de 18/11 (`proteger-mcp`, `versionar`, travas de `rm`, `..`, escrita por shell), `/operador-pausar` e `/operador-cancelar`, `sha256sum` liberado e hooks mais rápidos.
- Nada da operação muda: provado nas 7 cópias (seção 6). Os 20 `deny` da 7 continuam no `settings.json`; `rules/` próprias ficam idênticas; o `settings.local.json` nem é lido.
- Formato de cartão e quadro **não muda**: cartão antigo sem `Alvos:` e sem `.dono` continua válido; quadro com "Próximo ID" continua servindo de piso para o `novo-id.sh`; "Próximo passo" antigo na Situação não quebra nada (só deixa de ser mantido).
- O modo padrão (um cartão por vez), que antes era só texto, agora tem trava de verdade.

Negativo / atenção:
- **2_Servidor:** o #029 está em "A fazer" com `Status: análise`. Para o hook ele está aberto e **nega o próximo cartão** até ser pausado de verdade (`/operador-iniciar` → retomar o #029 → `/operador-pausar`, ou editar `Status: pausado`). A mensagem do hook cita o #029.
- 5, 6, 7 e 8 têm um cartão em `execução`: um cartão novo é negado até retomar e fechar, pausar ou cancelar esse (é a regra de sempre, agora com trava).
- `rules/parametros.md` sai das 7 (sem edição local; fica na cópia `.versoes/kit-<data>/`). O padrão `parametro.json` passa a ser lido só quando o gerente monta a operação ou liga ferramenta.
- O `settings.json` ganha `PostToolUse` (`vez.sh soltar`): mais um processo `bash` por edição (sai na hora quando não é quadro/ambiente/histórico).

### Em operações e recursos novos
- Operação nova: `instalar.cmd` → pasta → pronto; o `operador-usar` deixa de ser necessário.
- Tokens: `iniciar` de 14,7 KB (atual) para 8,9 KB; `parametros.md` fora do contexto fixo; retomada mais barata pela regra de "Execução" curta.
- Hooks: medido no Windows (média de 16 chamadas), `proteger-estrutura` editando cartão: atual ~786 ms (medição de A), A 487–496 ms, C 348–437 ms. `bloquear-comandos`: A 534 ms, C ~557 ms.
- Manutenção do kit: o instalador reconhece qualquer versão **commitada**; arquivo de kit que nunca foi commitado (como uma cópia feita do meio de um trabalho) aparece como "revisar", com cópia e diferença (seção 6, 8_InsaneIA).
- Complexidade: +1 arquivo de skill (`montar.md`); nenhuma dependência nova (bash, git, jq).

---

## 6. Testes rodados

- `bash .claude/bin/testar-hooks.sh`: **118 ok, 0 falha** (eram 104 em A; antes das correções, 2 falhas na versão não commitada). Novos: Root `/c/` × arquivo `C:/`; reserva recente conta e reserva vencida não; status `concluído`/`Concluído`/`cancelado` não contam; pausado voltando respeita o limite; alvo em comum, `*` e `postgres`/`postgresql` perguntam; alvo curto não conflita por começo; mesmos alvos não perguntam de novo, alvo novo pergunta; dona parada há mais de 30 min é assumida e quem assume vira a dona; restart pergunta com cartão de outra sessão, `systemctl status` não; secundária recebe os hooks do `settings.local.json`.
- `bash testar-instalar.sh`: **30 ok, 0 falha**.
- **Migração em cópias das 7 operações** (scratchpad, sem `parametros/`, `.env`, `settings.local.json`, `entregas/` e `backups/`): instalação sem perguntas, retrato SHA-1 de tudo fora de `CLAUDE.md`/`.claude/` antes e depois, `rules/` antes e depois, contagem de `deny`, segunda rodada.

| Operação | Novo/troca | Outros | Fora do kit igual | `rules/` própria igual | `deny` | 2ª rodada |
|---|---|---|---|---|---|---|
| 2_Servidor_Linux | 34 | sai `parametros.md` | sim | sim | 9 → 10 | nada muda |
| 3_Doc_Space | 34 | sai `parametros.md` | sim | sim | 9 → 10 | nada muda |
| 4_Worker | 34 | sai `parametros.md` | sim | sim | 9 → 10 | nada muda |
| 5_GoogleFlow | 28 | sai `parametros.md` | sim | sim | 9 → 10 | nada muda |
| 6_ContaModeloInstagram | 34 | sai `parametros.md` | sim | sim | 9 → 10 | nada muda |
| 7_Gmail | 33 | **mescla** `settings.json`; sai `parametros.md` | sim | sim | 29 → 30 (os 20 do Gmail ficam) | nada muda |
| 8_InsaneIA_Lab | 28 | sai `parametros.md` | sim | sim | 9 → 10 | ver nota |

  Nota: entre a 1ª e a 2ª rodada da 8, eu alterei o `bloquear-comandos.sh` no clone; a cópia da operação tinha uma versão que nunca foi commitada, e o instalador a tratou como edição local (trocou, guardou o antigo e escreveu `REVISAR.md`). É o comportamento seguro esperado; a rodada foi refeita do zero com o kit final (seção 6.1).
- Nas cópias migradas, chamando o hook como o app chama: 2 nega cartão novo citando o #029 e libera pausar o #029; 3 abre cartão novo; 5 libera editar o #001 e nega um segundo cartão; `testar-hooks.sh` dentro da cópia migrada da 7: "Todas as travas passaram".

### 6.1 Rodada final, em cópias novas, com o kit final
Mesmo método, cópias novas das 7 operações, kit com todas as correções (os arquivos atuais do clone contam como versão conhecida, como no commit):

| Operação | Novo/troca | Outros | Fora do kit | `rules/` própria | `deny` da operação perdidos | Arquivos em `.versoes/kit-<data>/` | 2ª rodada |
|---|---|---|---|---|---|---|---|
| 2_Servidor_Linux | 34 | sai `parametros.md` | igual | igual | 0 | 19 | nada muda |
| 3_Doc_Space | 34 | sai `parametros.md` | igual | igual | 0 | 19 | nada muda |
| 4_Worker | 34 | sai `parametros.md` | igual | igual | 0 | 19 | nada muda |
| 5_GoogleFlow | 28 | sai `parametros.md` | igual | igual | 0 | 19 | nada muda |
| 6_ContaModeloInstagram | 34 | sai `parametros.md` | igual | igual | 0 | 19 | nada muda |
| 7_Gmail | 33 | mescla `settings.json`; sai `parametros.md` | igual | igual | 0 (os 20 do Gmail ficam) | 19 | nada muda |
| 8_InsaneIA_Lab | 28 | sai `parametros.md` | igual | igual | 0 | 19 | nada muda |

Nenhuma edição local para revisar em nenhuma: todo arquivo de kit nas operações é uma versão commitada do kit, exceto o `settings.json` da 7, que foi mesclado.

---

## 7. Plano de migração das operações (não executado)

1. Revisar e mesclar `melhoria-c` (ou usar o clone `operador-c`). No clone: `bash .claude/bin/testar-hooks.sh` e `bash testar-instalar.sh`.
2. Fechar as sessões do Claude Code das operações.
3. Para cada operação: dois cliques em `instalar.cmd`, informar a pasta e o nome, conferir a lista (esperado: `novo`/`troca`, `sai .claude/rules/parametros.md`, e na 7 `mescla .claude/settings.json`) e confirmar. Sem perguntas: `bash instalar.sh <pasta> --ver` e depois sem `--ver`.
4. Rodar de novo em uma: "O kit já está atualizado. Nada muda."
5. Arrumar o estado, numa sessão normal de cada operação:
   - 2: `/operador-iniciar`, retomar o #029 e `/operador-pausar` (sem isso, nenhum cartão novo abre); tirar de `docs/operacao.md` a lição do `| sha256sum`.
   - 5 #001, 6 #003, 7 #002, 8 #008: retomar e fechar, `/operador-pausar` ou `/operador-cancelar`. Ao retomar 5 e 6, o gerente move a "Execução" antiga para `entregas/execucao-anterior.md`.
   - Opcional: tirar "Próximo passo" da "Situação" dos quadros.
   - 8: levar ao `operador-midia` os itens "Levar ao kit" (#003, #005).
6. Desfazer, se preciso: copiar de volta `operacao/.versoes/kit-<data>/`.
7. Paralelo é opcional e por operação: `- Cartões em paralelo: N` em `operacao/docs/operacao.md`.

---

## 8. Riscos que restam

- **Não testado com o modelo de verdade:** as skills (pausar, retomar com "Execução" longa, alvos), as confirmações `ask` no app, a ordem hook → checagem do Edit → gravação dentro do app (o `vez.sh` depende dela), a conta secundária.
- Sessão viva parada mais de 30 minutos sem editar o cartão perde a vez para outra sessão que o editar (a antiga é negada na próxima edição, então o conflito aparece, mas o cartão muda de dono).
- Alvos comparados por palavra: coisas que se afetam com nomes diferentes passam; o pré-filtro de serviço só conhece `systemctl`, `service` e `docker`.
- Sem `session_id` (só se o app deixar de mandar), o dono e a pergunta de alvos não funcionam; o limite continua.
- A janela do `instalar.cmd` com digitação real não foi testada (o mesmo `instalar.sh` foi provado por argumentos e no `testar-instalar.sh`).
- Uma linha acrescentada no meio de um `.md` do kit vai para `kit-migrado.md` fora do contexto; o diff completo fica no `REVISAR.md`.
- Rotinas automáticas continuam fora do kit (4_Worker).
