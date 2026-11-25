# Relatório A — análise das operações e melhorias no kit

Data: 2026-11-24 · Branch `melhoria-a` (a partir de `correcao-travas-retomada`, `bf44f97`) · Sem push.

Base lida: `README.md`, `CLAUDE.md`, `ANALISE.md` (rodadas 1 e 2 e a correção), todo o `.claude/` do kit, `operador-usar/` e as operações 2 a 8. A `9_Gmail_JeyJunior` está vazia. Não li `operacao/parametros/`, `.env`, `settings.local.json` nem `~/.ssh`, e não chamei serviço externo.

---

## 1. O que é o `operador-usar` e em que versão estão as operações

- `operador-usar/` é a "pasta pronta para copiar" sugerida no README: `CLAUDE.md` + `.claude/`. Está em 2026-11-11 (skills de 2026-11-16) e **não tem a correção de 2026-11-18** (`proteger-mcp.sh`, `versionar.sh`, travas de `rm`/servidor/escrita por shell, "Onde parou").
- Toda operação é cópia do `operador-usar`, em duas safras: 2026-11-11 (2, 3, 4, 6, 7) e 2026-11-16 (5, 8). `CLAUDE.md` idêntico ao do `operador-usar` em todas.
- O que difere de verdade em cada operação:

| Diferença | Onde | Natureza |
|---|---|---|
| `rules/operacao.md`, `psql.md`, `notion.md`, `dependencias.md`, `flow.md` | todas / 2, 3, 4, 8 | **personalização legítima** (é o lugar certo) |
| `settings.local.json` | 2 | legítima |
| `settings.json` com 20 `deny` de MCP do Gmail (enviar, responder, apagar, spam) | 7 | **legítima, no arquivo errado**: a próxima atualização manual a apagaria |
| skills `iniciar`, `encerrar`, `fluxo` mais antigas; sem `operador-midia` | 2, 3, 4, 6, 7 | **versão antiga** |
| sem `proteger-mcp.sh`, `versionar.sh`; hooks antigos | todas | **versão antiga** (falha de segurança já corrigida no kit, mas não chegou) |
| `rules/parametros.md` | todas | arquivo **do kit** dentro de uma pasta que o README manda manter como "da operação": nunca seria atualizado |

Conclusão: as duas coisas. O conteúdo próprio está quase todo em `rules/` (correto); o resto é versão velha, porque não há mecanismo de atualização e a instrução manual era fácil de errar.

---

## 2. Falhas reais de operação (com evidência)

1. **Correções do kit não chegam às operações.** Nenhuma das 7 tem `proteger-mcp.sh`/`versionar.sh`; nenhuma tem `operacao/.versoes/`. 7_Gmail guarda permissões próprias em `.claude/settings.json`, que o README manda trocar. `rules/parametros.md` é do kit e fica preso em pasta "da operação".
2. **Cartão aberto parado bloqueia a operação, e não existe "pausar".** 5 das 8 operações têm cartão em "Fazendo" parado há dias: 5_GoogleFlow #001 (desde 11-12, `Status: execução`, 237 linhas), 6 #003 (11-14), 7_Gmail #002 (11-15, esperando o usuário), 8 #008 (11-17), 4_Worker #011 (11-23). A 2_Servidor improvisou: `QUADRO.md` → "A fazer: #029 ... pausado na análise em 2026-11-23 ... falta o usuário escolher A, B ou C", com `cartoes/029-*/cartao.md` ainda `Status: análise` — estado que nenhuma skill conhece.
3. **Quadro e cartão discordam sobre o próximo passo.** 4_Worker: `QUADRO.md` "Próximo passo: análise" × `cartoes/011-*/cartao.md` "Status: execução". 8_InsaneIA: quadro "Próximo passo: briefing" × `cartoes/008-*/cartao.md` "Status: execução" (com plano aprovado em 2026-11-18). O mesmo dado em dois lugares se desencontra.
4. **Agente contornou trava.** 8_InsaneIA `cartoes/008-*/cartao.md`: "o executor apagou esse arquivo de Downloads contornando o hook que bloqueou o `rm` (cd + rm relativo) — contorno de trava". No mesmo cartão: "ao encerrar por filtro "recv.py" na linha de comando, parou mais 4 processos que casaram com o texto". Nada no kit dizia "não contorne" nem "mate só pelo PID".
5. **`sed` destruiu texto sem cópia.** 8_InsaneIA `cartoes/004-*/cartao.md`, passo 5: "o sed do gerente na troca da luz apagou o prompt de imagem das 3 cenas em prompts.md". O hook só barrava `sed -i` em quadro, `docs/` e `cartao.md`; `entregas/*.md` passava, e lá não há versão anterior.
6. **Trava com falso positivo vira regra da operação.** 2_Servidor `docs/operacao.md`: "o hook do kit barra `curl ... | sh*`, e isso pega até `| sha256sum` (lição do #004)". Confirmado: `'(curl|wget)\s+[^|]+\|\s*(sh|bash)'` casa com `| sha256sum`. A operação passou a contornar com dois comandos e a carregar a lição em todo arquivo lido por sessão.
7. **Lição do kit fica presa na operação.** 8_InsaneIA tem no Backlog "#005 Levar ao kit: continuidade e movimento no Flow" e "#003 Levar ao kit: novidades do Flow" desde 11-16/17; a 2_Servidor acumulou ~8 lições sobre o comportamento dos hooks em `docs/operacao.md`. Não há caminho de volta para o kit.
8. **Hooks lentos.** Medido no Windows: 0,6–0,8 s por hook (`proteger-estrutura` 786 ms, `bloquear-segredos` 669 ms, `versionar` 595 ms, `bloquear-comandos` 592 ms). Cada hook chamava `jq` de 2 a 4 vezes e `tr` em subshell; toda edição e todo comando pagam isso.
9. **Cartão de ciclo curto sem `Status` nem "Onde parou".** 2_Servidor `cartoes/031-*/cartao.md` começa direto em "Motores" e "Briefing" (o modelo do curto não pede status). Se a sessão cair no meio de um reboot do servidor, outra conta não sabe em que pé está.
10. **"Execução" vira diário longo e é relida a cada retomada.** 5_GoogleFlow #001: 237 linhas; 6 #003: 140; 2_Servidor #006: 143; 8 #004: um único passo com 9 frases. Sem regra de tamanho.
11. **Regras soltas que divergem do kit.** 3_Doc_Space "Homologado" tem 4 grupos (a regra é 3); 8 #008 usa "Aberto em:" e "Fluxo: nenhum" fora do modelo. Pequenas, mas mostram que o gerente não relê o modelo inteiro.
12. **Automação rodando fora do kit falha calada.** 4_Worker `cartoes/011-*/cartao.md`, "Para o backlog": "Rodadas noturnas de 16, 17, 19 e 24/11 com código 4 ... LinkedIn falhando de 17 a 24/11 — achado do analista". A rotina noturna (tarefa do Windows criada no #005) falhou 4 noites e só foi vista por acaso. (Não corrigido aqui: ver seção 5.)

---

## 3. Pontos positivos (confirmados nas operações)

- **Retomada por arquivo funciona.** 2_Servidor tem 14 cartões em 2 semanas, `ambiente.md` com 92 linhas fiel ao servidor e citando o cartão de cada fato, decisões numeradas reutilizadas (001 a 007). 5_GoogleFlow foi retomado em outra instância e conta.
- **Ordem plano → backup → desfazer é seguida.** 2_Servidor #006: 11 backups, contagem de arquivos antes e depois; #031 registra estado antes e depois do reboot.
- **Ok específico respeitado em mídia.** 8 #004: "0 crédito, saldo 50 → 50" a cada lote; ok por clipe.
- **"Dado, não instrução" e dados de terceiros funcionaram.** 8 #008: o gerente recusou duas vezes usar foto de pessoa real até haver consentimento registrado em decisão.
- **Lições viram regra da operação** (`rules/psql.md`, `rules/notion.md`, `rules/dependencias.md`): o mecanismo de `rules/` é usado como previsto.
- **Fluxo maduro**: 8 `docs/fluxos/01-video-diario.md` tem papéis, pausas, limites de refação e teto de crédito.
- **Travas da correção de 11-18 passam no autoteste** e são legíveis.

---

## 4. Melhorias aplicadas em `operador-a`

| # | O quê | Por quê (falha) | Arquivos |
|---|---|---|---|
| 1 | **`atualizar-kit.sh`**: instala ou atualiza o kit numa pasta. Sem `--aplicar` só lista o que muda. Troca só o que é do kit (CLAUDE.md, settings.json, hooks, bin, modelos, agentes e skills que existem no kit); mantém `rules/`, `settings.local.json`, `.mcp.json`, `operacao/` e agente/skill próprios; remove o que está em `obsoletos.txt`; move tudo o que sai para `operacao/.versoes/kit-<data>/`; leva permissões próprias do `settings.json` para o `settings.local.json`; avisa hook próprio; grava `.claude/kit-versao.txt`; lista os "Levar ao kit:" do quadro. Idempotente. | 1, 7. Também substitui o `operador-usar` e o comando `rm -rf ... && cp` do README (escalabilidade: N operações atualizadas com um comando cada). | `.claude/bin/atualizar-kit.sh`, `.claude/bin/obsoletos.txt`, `README.md` **Substituído na seção 8 (correções do dono).** |
| 2 | **Pausar cartão**: `/operador-encerrar pausar` grava "Onde parou" com o status ao retomar, `Status: pausado`, e move o cartão para o topo de "A fazer"; o `/operador-iniciar` mostra e retoma. | 2 (5 de 8 operações travadas; a 2 improvisou). | `skills/operador-encerrar/SKILL.md`, `skills/operador-iniciar/SKILL.md`, `modelos/documentos.md`, `CLAUDE.md`, `skills/operador-consultar/SKILL.md` **Substituído na seção 8 (correções do dono).** |
| 3 | **Quadro sem "Próximo passo"**: a "Situação" fica com cartão aberto, decisões pendentes e próximo ID; o próximo passo existe só no "Onde parou". | 3 (dois casos de divergência). Menos uma edição por parada. | `modelos/documentos.md`, `skills/operador-encerrar/SKILL.md`, `skills/operador-iniciar/SKILL.md`, `README.md` |
| 4 | **"Trava negou, pare"** no `CLAUDE.md` e nos três agentes; executor só encerra processo pelo PID que ele iniciou. Trava que barra algo legítimo vira "Levar ao kit:". | 4 (contorno com `cd` + `rm`; 4 processos mortos por nome). | `CLAUDE.md`, `agents/*.md` |
| 5 | **`sed -i` negado em qualquer `.md` de `operacao/`** (antes só quadro, `docs/`, `cartao.md`). | 5. | `hooks/bloquear-comandos.sh`, teste |
| 6 | **`curl \| sha256sum` liberado**; `curl \| sh`, `\| sudo bash`, `\| zsh` continuam negados. | 6. | `hooks/bloquear-comandos.sh`, teste |
| 7 | **Hooks ~2x mais rápidos nas edições**: `comum.sh` lê a entrada com um único `jq` (`ler_entrada`), sem `tr`/subshell para minúsculas nem `shopt` em subshell. Medido (média de 8): `proteger-estrutura` 786 → 293 ms, `bloquear-segredos` 669 → 397 ms, `versionar` 595 → 289 ms; `bloquear-comandos` igual (~570 ms, dominado pelos `grep`). Modo sem `jq` conferido à mão. | 8. | `hooks/comum.sh` e os 5 hooks que o usam |
| 8 | **Motores fora do `operador-iniciar`**: a seção vai para `skills/operador-iniciar/motores.md`, lida só antes do primeiro disparo. `SKILL.md` do iniciar: 14,7 → 9,2 KB (~1,5 mil tokens a menos em toda sessão que não dispara subagente). | Desempenho; a seção era só para disparo. | `skills/operador-iniciar/SKILL.md`, `skills/operador-iniciar/motores.md`, `CLAUDE.md`, `modelos/documentos.md` |
| 9 | **`homologar` vira modo do `encerrar`** (`/operador-encerrar homologar`); o encerrar já o chamava por arquivo. 6 → 5 comandos. | Simplificação proposta nas duas rodadas; uma leitura a menos no fechamento. | `skills/operador-encerrar/SKILL.md`, skill `operador-homologar` removida, `obsoletos.txt` **Substituído na seção 8 (correções do dono).** |
| 10 | **`rules/parametros.md` sai de `rules/`** e vira seção de `modelos/documentos.md` (lido só quando se cria documento). | 1 (arquivo do kit em pasta da operação) e ~700 bytes a menos em toda sessão. | `modelos/documentos.md`, `.gitignore`, `obsoletos.txt` |
| 11 | **Ciclo curto com `Status` e "Onde parou"**, e "Cartão aberto" aponta para ele enquanto dura. | 9. | `skills/operador-ciclo-curto/SKILL.md`, `modelos/documentos.md` |
| 12 | **"Execução" com uma linha por passo**; saída longa vai para `entregas/` e a linha aponta o arquivo. | 10. | `modelos/documentos.md` |
| 13 | README: personalização de modelos/padrões de segredo passa a ser "leve ao kit" (eles são trocados na atualização; o README dizia as duas coisas). | Contradição entre "Atualizar" e "Personalização". | `README.md` |

O que **saiu**: skill `operador-homologar`, `rules/parametros.md`, a dica do `operador-usar` no README. O que **entrou**: `atualizar-kit.sh`, `obsoletos.txt`, `motores.md` (movido, não novo). **Substituído na seção 8 (correções do dono).**

---

## 5. O que não apliquei e por quê

- **Rotinas (execução sem usuário, autorização com teto, `execucoes/`, métricas).** O dono disse que não é o foco, e é a maior camada proposta. Há evidência de necessidade (4_Worker roda à noite fora do kit e falhou 4 noites sem aviso; 3_Doc_Space repete "Aula N" como ciclo curto; 8 "Vídeo do dia"), mas o ciclo curto e o pausar cobrem o uso atual. Próximo passo sugerido, menor que a proposta: um aviso no `verificar-ambiente.sh` lendo um `operacao/docs/rotinas.md` com o caminho do log de cada rotina externa e a data da última execução ok.
- **Juntar os 3 hooks de edição num só.** Rodam em paralelo; depois da otimização a latência por edição é ~0,4 s. Ganharia CPU, perderia clareza e mexeria no `settings.json` de todos.
- **Pegar `rm` dentro de heredoc/texto e `cd ... && rm`.** Regex não resolve sem falso positivo; a resposta foi a regra "trava negou, pare" (instrução, não trava).
- **`operador-midia` como pacote opcional.** O `atualizar-kit.sh` instala a skill em toda operação (inclusive Gmail). Custo: só a descrição (~60 tokens) por sessão. Dá para virar lista de exclusão por operação depois, se crescer.
- **Fundir `ciclo-curto` no `iniciar`.** Aumentaria o arquivo que toda sessão lê; o usuário usa o comando (3_Doc_Space, 2_Servidor #017/#031).
- **`ssh` falhando na secundária** (2_Servidor `ferramentas.md`: "requires approval", 2026-11-12). Foi com o `secundaria.sh` antigo (que não somava `settings.local.json`); não dá para testar sem chamar a conta. Fica para verificar depois da migração.
- **Trava de concorrência, retenção/LGPD, trilha de incidente, `eventos.jsonl`/contador de skills**: sem falha observada nas operações neste período.
- **Corrigir os dados das operações** (quadros divergentes, cartões parados): é das operações e elas são só leitura aqui. Ver migração.

Nada foi instalado. Recomendação: nenhuma dependência nova; o kit continua só com bash + jq.

---

## 6. Testes

- `bash .claude/bin/testar-hooks.sh`: **93 ok, 0 falha** (eram 84 casos; +4 de comandos: `sed -i` em `entregas/*.md` negado, `sed -n` liberado, `curl | sudo bash` negado, `curl | sha256sum` liberado; +5 do `atualizar-kit.sh`: sem `--aplicar` não altera, troca o kit e mantém `rules/` e `operacao/`, leva permissão própria para o `settings.local.json`, guarda o que saiu em `.versoes/`, recusa pasta dentro do kit). Tempo total 58 s → 50 s com mais casos. (Depois das correções: 88 nas travas + 30 no `testar-instalar.sh`; ver seção 8.)
- **Sem `jq`** (PATH filtrado): `proteger-estrutura` nega subagente no quadro, `bloquear-comandos` nega `rm -rf /var/x`, `bloquear-segredos` nega token.
- **Atualização numa cópia real**: `.claude` + `CLAUDE.md` + `QUADRO.md` da 7_Gmail copiados para o scratchpad. Listou 13 itens a trocar, 2 obsoletos e os 20 `deny` do Gmail; com `--aplicar`, os `deny` foram para o `settings.local.json`, `rules/operacao.md` ficou, o que saiu foi para `operacao/.versoes/kit-2026-11-24-214001/`; segunda rodada: "Kit já está atualizado".
- **Ciclo mínimo simulado** (pasta nova no scratchpad, cada escrita passando pelos três hooks reais e cada comando pelo `bloquear-comandos`): instalar pelo script → abertura avisa "rode /operador-iniciar" → gerente grava `operacao.md`, `rules/operacao.md`, quadro e cartão → analista grava em `entregas/` → analista negado no `cartao.md`, executor negado no quadro, `sed -i` em `entregas/*.md` negado → pausar (cartão `pausado`, quadro em "A fazer") → retomar e concluir → `mv` para `_arquivo/` liberado, `rm -r` negado → 6 versões guardadas em `.versoes/`.
- **Não verificado**: comportamento das skills com um modelo de verdade (pausar/retomar), confirmações `ask` no app, `secundaria.sh` contra a conta secundária.

---

## 7. Como migrar as operações

Substituído pelo passo a passo da seção 8.

---

## 8. Correções do dono (2026-11-25)

### 8.1 Atualização sempre migra, nunca perde dado

`instalar.sh` (raiz do kit) substitui o `atualizar-kit.sh` e o `obsoletos.txt`. Para cada arquivo do kit na operação, ele calcula o hash git (`git hash-object --path`, que normaliza CRLF) e compara com **todas as versões daquele arquivo em todos os commits do kit** e com a versão atual:

| Situação | Ação |
|---|---|
| hash conhecido (versão antiga do kit) | troca pela nova |
| `settings.json` com hash desconhecido | mescla com `jq`: settings novo do kit + entradas `allow`/`ask`/`deny` que não aparecem em nenhuma versão do kit + hooks cujo comando não aparece em nenhuma versão do kit + chaves de topo e de `permissions` que o kit nunca teve; sem duplicar |
| `padroes-segredos.txt` com hash desconhecido | arquivo novo + linhas que nenhuma versão do kit teve, num bloco "# Da operação" |
| outro `.md` do kit com hash desconhecido | troca; as linhas acrescentadas em relação à versão do kit mais parecida vão para `.claude/rules/kit-migrado.md` (carregado em toda sessão), e o diff completo vai para `REVISAR.md` |
| outro arquivo do kit (script) com hash desconhecido | troca; antigo na cópia e diff em `REVISAR.md` |
| caminho que já foi do kit e não existe mais (ex.: `rules/parametros.md`) | sai, se não foi editado; em `rules/`, se foi editado, fica como da operação |
| caminho que nunca foi do kit (rules, skill, agente, hook próprios) | fica intocado |

- **Decisão sobre o `settings.json`:** mesclar no próprio `settings.json`, como o construtor faz. Motivos: o dono pediu "entram no settings novo"; o `settings.local.json` é também onde o app grava as permissões dadas com "sempre permitir", então misturar as duas origens lá dificultaria saber o que é regra da operação; e a detecção pelo histórico separa o que é do kit do que é da operação a cada atualização, sem marcação manual. O `settings.local.json` continua valendo e nunca é tocado.
- **Cópia antes de trocar:** tudo o que muda ou sai vai para `operacao/.versoes/kit-<data>/` com o mesmo caminho; `REVISAR.md` só aparece quando há edição local que não é `settings.json` nem `padroes-segredos.txt`.
- **Idempotente:** o conteúdo final de cada arquivo é montado antes numa pasta temporária e comparado (ignorando CRLF) com o da operação; igual não é tocado. A segunda rodada responde "O kit já está atualizado. Nada muda."
- **Versão:** `.claude/VERSAO` (`2026.11.25`), copiado para a operação, como no construtor.
- **Requisitos:** `git` (o histórico do clone é a referência; sem `.git`, só a versão atual é reconhecida e o resto vai para revisão) e `jq` só quando o `settings.json` tem conteúdo próprio.

### 8.2 Instalador por `.cmd`

Mesmo padrão do `construtor-equipe-v3` (lido, não alterado): `instalar.cmd` na raiz do kit acha o Git Bash por `git --exec-path` (o `bash` do PATH pode ser o do WSL) e chama `instalar.sh` com os argumentos; termina com `pause`. Se o Git não existir, ou existir sem o Git Bash, a mensagem diz o que instalar e onde (Git for Windows). `.exe` não: o construtor não tem gerador de `.exe` e criar um exigiria instalar ferramenta.

Fluxo: dois cliques → "Pasta onde fica (ou vai ficar) a operação" → "Nome da pasta" → pasta vazia ou inexistente: "Pasta nova", confirma, copia, roda os autotestes e diz o próximo passo (`/operador-iniciar`); pasta com o kit: mostra a versão instalada e a nova, lista cada arquivo (novo, troca, mescla, migra, revisar, sai), os itens "Levar ao kit" do quadro, confirma, aplica, diz onde está a cópia e o `REVISAR.md`, roda os autotestes; pasta com outra coisa: para sem mexer. Sem perguntas: `bash instalar.sh <pasta>` aplica; `bash instalar.sh <pasta> --ver` só mostra. O `.cmd` aceita os mesmos argumentos.

Verificado: `instalar.cmd <pasta> --ver` rodado pelo `cmd` achou o Git Bash e mostrou "Pasta nova..."; modo interativo com respostas pela entrada padrão (criar, depois "Nada muda"); instalação nova com autoteste ("Todas as travas passaram").

### 8.3 Comandos com hífen, sem subcomando por argumento

- `/operador-pausar` e `/operador-cancelar` são skills próprias; `/operador-homologar` voltou a ser skill própria (texto original do `bf44f97`). O `/operador-encerrar` só fecha e indica os outros quando cabe.
- Comandos finais: `/operador-iniciar`, `/operador-encerrar`, `/operador-pausar`, `/operador-cancelar`, `/operador-homologar`, `/operador-ciclo-curto`, `/operador-fluxo`, `/operador-consultar` (mais a skill `operador-midia`, que não é comando). Argumentos que sobraram são texto livre (o pedido, a pergunta, o nome do fluxo, os números dos cartões), não subcomandos.
- Revisados: `CLAUDE.md`, `README.md`, skills, modelos e as mensagens do instalador. O `secundaria.sh` mantém `status`/`mcp`/`rodar`: é script interno chamado pelo gerente, não comando do dono.

### 8.4 Testes

- `bash .claude/bin/testar-hooks.sh`: **88 ok, 0 falha** (os 5 casos do updater antigo saíram daqui).
- `bash testar-instalar.sh` (novo, na raiz do kit): **30 ok, 0 falha**. Monta uma operação com o kit de um commit anterior e acrescenta: rule, skill e hook próprios; linha própria no `CLAUDE.md`; `deny`, hook e chave `env` próprios no `settings.json` (sem um hook que o kit novo tem); linha própria em `padroes-segredos.txt`; `settings.local.json`; quadro com "Levar ao kit". Prova: `--ver` não muda nada; kit trocado; cada item próprio preservado ou migrado; travas novas presentes; sem duplicata; `parametros.md` sai e fica na cópia; `REVISAR.md` gerado; segunda rodada sem nenhum arquivo alterado; recusa pasta com outra coisa e pasta dentro do kit.
- **Cópia de cada operação real** (2 a 8, sem `operacao/parametros/`), no scratchpad, por `provar-migracao.sh`: retrato SHA-1 de todos os arquivos antes, depois e depois da segunda rodada.

| Operação | Arquivos de kit trocados ou saídos | Sem cópia idêntica | Fora de `CLAUDE.md`/`.claude` mudou | `rules/` + `settings.local.json` mudou | Edição local | 2ª rodada |
|---|---|---|---|---|---|---|
| 2_Servidor_Linux | 19 | 0 | 0 | 0 | nenhuma | "Nada muda", 0 arquivos |
| 3_Doc_Space | 19 | 0 | 0 | 0 | nenhuma | "Nada muda", 0 arquivos |
| 4_Worker | 19 | 0 | 0 | 0 | nenhuma | "Nada muda", 0 arquivos |
| 5_GoogleFlow | 18 | 0 | 0 | 0 | nenhuma | "Nada muda", 0 arquivos |
| 6_ContaModeloInstagram | 19 | 0 | 0 | 0 | nenhuma | "Nada muda", 0 arquivos |
| 7_Gmail | 19 | 0 | 0 | 0 | `settings.json` mesclado | "Nada muda", 0 arquivos |
| 8_InsaneIA_Lab | 18 | 0 | 0 | 0 | nenhuma | "Nada muda", 0 arquivos |

- "Sem cópia idêntica": arquivo de `CLAUDE.md`/`.claude` que mudou ou saiu e **não** está byte a byte em `operacao/.versoes/kit-<data>/`. Zero em todas.
- `rules/parametros.md` saiu em todas (arquivo do kit sem edição) e ficou na cópia; as rules próprias (`operacao.md`, `psql.md`, `notion.md`, `dependencias.md`, `flow.md`) e o `settings.local.json` da 2 ficaram idênticos.
- 7_Gmail: os 20 `deny` de MCP do Gmail continuam no `settings.json` (diferença para o original: só o `Edit(~/.ssh/**)` novo do kit) e os hooks `proteger-mcp` e `versionar` entraram.
- Todas as cópias de kit nas operações eram versões conhecidas do kit (hash igual a algum commit), exceto o `settings.json` da 7.

### 8.5 Como migrar as operações (passo a passo, não executado)

1. Mesclar `melhoria-a` na `main` do kit (ou usar o clone `operador-a`).
2. No clone: `bash .claude/bin/testar-hooks.sh` e `bash testar-instalar.sh`.
3. Fechar as sessões do Claude Code abertas nas operações.
4. Para cada operação (2 a 8): dois cliques em `instalar.cmd`, informar `D:\1_Projetos\0_JR\jeyjunior-operador` e o nome da pasta, conferir a lista (esperado: `novo`/`troca`, `sai .claude/rules/parametros.md` e, na 7, `mescla .claude/settings.json`) e confirmar. Ou sem perguntas: `bash instalar.sh ../../7_Gmail --ver` e depois sem `--ver`.
5. Rodar de novo numa delas: deve responder "O kit já está atualizado. Nada muda."
6. Arrumar o estado (numa sessão normal): cartões parados em "Fazendo" (5 #001, 6 #003, 7 #002, 8 #008, 4 #011) com `/operador-iniciar` para retomar ou `/operador-pausar`/`/operador-cancelar`; tirar "Próximo passo" da "Situação" dos quadros; a 2 #029 com `/operador-pausar` para gravar `Status: pausado`; levar ao `operador-midia` os itens "Levar ao kit" da 8.
7. Para desfazer: copiar de volta o conteúdo de `operacao/.versoes/kit-<data>/` da operação.
8. `operador-usar/` deixa de ser necessário: o instalador cria a operação direto do clone.

### 8.6 Pendências

- O modo interativo foi testado com respostas pela entrada padrão; a janela do `instalar.cmd` com dois cliques e digitação real não foi testada (ela roda o mesmo `instalar.sh`, já provado pelo `cmd` com argumentos).
- As skills novas (`/operador-pausar`, `/operador-cancelar`) não foram exercitadas com um modelo real.
- Uma linha acrescentada no meio de um `.md` do kit é migrada para `kit-migrado.md` fora do contexto original. O diff completo fica no `REVISAR.md` para o dono decidir.
- Uma entrada própria idêntica a uma que o kit teve em alguma versão e depois tirou é tratada como do kit (sai). O antigo fica na cópia.

---

## 9. Cartões em paralelo (2026-11-25)

### 9.1 Análise: o que pressupunha um cartão por vez

| Onde | O que dizia ou fazia |
|---|---|
| `CLAUDE.md` | "Um cartão aberto por vez. Pedido novo durante um cartão vai para o Backlog." |
| `modelos/documentos.md`, quadro | "Situação" com "Cartão aberto: #NNN" (singular) e "Próximo ID" editado à mão; "Fazendo: o cartão aberto" |
| skills `encerrar`, `pausar`, `cancelar`, `ciclo-curto` | `<cartao>` = "o cartão indicado em Cartão aberto"; ciclo curto e iniciar: "com cartão aberto, vai para o Backlog" |
| `iniciar` | "O quadro tem cartão aberto: retome" (não pergunta qual) e "incremente o Próximo ID" |
| hooks | nenhuma trava: o "um por vez" era só instrução; duas sessões podiam pegar o mesmo "Próximo ID" e regravar o quadro uma sobre a outra (Write) |
| `versionar.sh` | já seguro: o nome da cópia leva hora e PID |
| `ambiente.md`, "Onde parou" | por cartão ("#NNN, em curso"), sem conflito de formato; o risco era só a gravação simultânea |
| conta secundária | sem efeito: papel não edita quadro nem cartão |

Nas operações (só leitura):
- **5_GoogleFlow** `cartoes/001-*/cartao.md`: "Não usar a sessão da conta 1 neste cartão ao mesmo tempo, para os dois gerentes não editarem o mesmo arquivo".
- **2_Servidor**: o #029 foi "pausado pelo usuário na análise, para abrir o #006"; o quadro mostra o #029 em "A fazer" com `Status: análise`.
- **3_Doc_Space** `cartoes/006-*/cartao.md`: "outra sessão editou a origem durante o passo".
- Esperando por causa do limite: 6 #007 (curto) atrás do #003; 4_Worker #013 atrás do #011; 5 #002 atrás do #001; 7 #003 atrás do #002.

### 9.2 Modelo escolhido

- **Cenário suportado: (a)**, várias sessões do Claude Code na mesma pasta, **cada uma com um cartão**. O **(b)**, um gerente tocando vários cartões, fica fora: o contexto de um cartão vazaria para o outro e o "um cartão por gerente" (que mantém o gerente descartável) cairia. Subagentes continuam servindo ao cartão da sessão que os disparou.
- **Ligar e travar:** a linha `- Cartões em paralelo: N` em "Limites" de `operacao/docs/operacao.md`. Sem a linha, ou com 1, é o comportamento de antes, agora com trava de verdade. Fica na pasta da operação, e o instalador não toca. Não criei comando: é uma linha que o dono (ou o gerente, a pedido) muda.
- **Cada cartão escreve no que é dele.** O que é compartilhado tem uma regra simples cada:

| Problema | Solução |
|---|---|
| mesmo número | `bin/novo-id.sh`: parte do maior número já usado (pastas, arquivo, quadro, "Próximo ID" antigo) e reserva com `mkdir operacao/.ids/NNN` (atômico) |
| limite e abertura simultânea | `proteger-estrutura.sh`, ao criar um `cartao.md`: sob a trava `mkdir .ids/.abrindo`, conta os abertos (status de trabalho, ou pasta reservada), confere alvos e grava `.dono` (sessão e alvos) antes de soltar a trava |
| qual sessão é dona | `.dono` na pasta do cartão com o `session_id` da primeira sessão que o editou; outra sessão é negada; `bin/liberar-cartao.sh NNN` solta (no `/operador-pausar`, ou com o ok do usuário quando a dona morreu) |
| interferência | linha `Alvos:` no cartão; o hook nega cartão aberto com alvo em comum com outro aberto; `*` = ambiente inteiro, conflita com todos |
| ação perigosa com outro cartão aberto | reboot, firewall, `passwd -l` etc. já pediam confirmação; agora a pergunta lista os outros cartões abertos |
| quadro, `ambiente.md`, `historico.md` | Write negado (só Edit); `hooks/vez.sh` pega a vez no PreToolUse e solta no PostToolUse, então a checagem do Edit ("mudou desde a leitura?") e a gravação acontecem sem outra sessão no meio; vez esquecida vence em 15 s; cópia anterior em `.versoes/` como sempre |
| `versionar.sh` e git | `versionar.sh` sem mudança (nome com hora+PID); a operação não tem git |
| atualização | `operacao.md`, `.ids/` e `.dono` ficam em `operacao/`, que o instalador não toca; o `settings.json` novo (com `vez.sh`) entra pela mesclagem |

- O status `aguardando-usuario` conta como aberto: um cartão esperando o usuário ocupa uma vaga. É de propósito, para não esquecer cartão pela metade.

### 9.3 Testes

- `testar-hooks.sh`: **104 ok** (+16).
  - Travado: o segundo cartão aberto é negado, e com o outro pausado abre.
  - Paralelo: a sessão 2 não edita o cartão da 1; alvo em comum e `*` são negados; alvos diferentes abrem; o terceiro passa do limite 2; Write no quadro é negado e Edit liberado; liberado, outra sessão assume; reboot avisa os outros cartões; `novo-id` sequencial; a vez só é solta por quem a pegou.
- `testar-instalar.sh`: **30 ok**. Migração com o kit novo em cópias da 3 e da 7: nada próprio mudou, os 20 `deny` da 7 continuam, o `PostToolUse` entrou, a segunda rodada não muda nada e o `testar-hooks.sh` passa dentro da operação migrada.
- **Simulação concorrente** (`simular-paralelo.sh` no scratchpad, processos em paralelo chamando os hooks e scripts reais):

    == 1. IDs: 4 sessões reservando 15 números cada, ao mesmo tempo
       reservados: 60, únicos: 60, faixa: 001–060
    == 2. Travado (sem a linha = 1): 3 sessões abrindo ao mesmo tempo, 5 rodadas
       rodada 1: 1 aberto(s), 2 negado(s)
       rodada 2: 1 aberto(s), 2 negado(s)
       rodada 3: 1 aberto(s), 2 negado(s)
       rodada 4: 1 aberto(s), 2 negado(s)
       rodada 5: 1 aberto(s), 2 negado(s)
    == 3. Paralelo com limite 2: 4 sessões abrindo ao mesmo tempo, alvos diferentes, 5 rodadas
       rodada 1: 2 aberto(s), 2 negado(s)
       rodada 2: 2 aberto(s), 2 negado(s)
       rodada 3: 2 aberto(s), 2 negado(s)
       rodada 4: 2 aberto(s), 2 negado(s)
       rodada 5: 2 aberto(s), 2 negado(s)
    == 4. Paralelo com limite 5: 2 sessões com o mesmo alvo (postgres) ao mesmo tempo, 5 rodadas
       rodada 1: 1 aberto(s), 1 negado(s)
       rodada 2: 1 aberto(s), 1 negado(s)
       rodada 3: 1 aberto(s), 1 negado(s)
       rodada 4: 1 aberto(s), 1 negado(s)
       rodada 5: 1 aberto(s), 1 negado(s)
       cenário do dono (banco, log de desligamento, DNS): 501-banco 502-log 503-dns 
       sessão 2 editando o cartão da sessão 1: "permissionDecision": "deny"
       reboot pedido pela sessão 2: "permissionDecision": "ask", avisa: 501-banco 503-dns 
    == 5. Quadro e ambiente: 3 sessões gravando 20 linhas cada, ao mesmo tempo
       Write no quadro com paralelo ligado: "permissionDecision": "deny"
       quadro (Edit): 60 de 60 linhas; ambiente (Edit): 60 de 60
       para comparar, gravação sem conferir (o que Write faria): 21 de 60

  Leitura: 60 números reservados, 60 únicos; travado, sempre 1 aberto entre 3 simultâneos; limite 2, sempre 2 entre 4; mesmo alvo, sempre 1 entre 2; cenário do dono (banco, log de desligamento, DNS) com 3 cartões abertos; a sessão 2 negada no cartão da 1; reboot pede confirmação e cita os outros dois cartões; 120 gravações simultâneas no quadro e no ambiente sem nenhuma perdida. Sem a vez, o mesmo teste perdia 19 de 60 com a checagem do Edit e 39 de 60 com regravação cega.

### 9.4 O que não cobre

- **Alvos comparados por palavra:** `postgres` e `postgresql` não conflitam, e duas coisas que se afetam sem nome comum (um cartão mexe no disco, outro no banco que está nele) passam. O briefing pede alvos claros, e `*` existe para o que pega tudo.
- **Um gerente com vários cartões** (cenário b) não é suportado.
- **A simulação da seção 5 reproduz a checagem do Edit**, não o Edit do Claude Code. A checagem existe, e este próprio trabalho viu o Edit recusar "File has been modified since read". Mas a ordem exata hook → checagem → gravação dentro do app não foi verificada.
- **Vez e reserva vencem pelo tempo:** se uma gravação for negada por outro hook depois do `vez.sh pegar`, a vez fica presa até 15 s. Uma pasta reservada cuja gravação foi negada conta como aberta até `liberar-cartao.sh`.
- **`.dono` só vale com o limite acima de 1.** No modo travado, duas sessões no mesmo cartão continuam dependendo do cuidado do usuário (como antes).
- **Operações migradas:** cartão com status de trabalho fora de "Fazendo" conta como aberto e trava o modo de um por vez (2_Servidor #029, que está `análise` em "A fazer"). Antes de usar: `/operador-iniciar` → retomar o #029 → `/operador-pausar`.

### 9.5 Como usar

1. Em `operacao/docs/operacao.md`, em "Limites": `- Cartões em paralelo: 3`.
2. Abra uma sessão do Claude Code na pasta da operação para cada tarefa e rode `/operador-iniciar` em cada uma. Os cartões abertos aparecem; cada sessão abre ou retoma o seu.
3. No briefing, diga o que o cartão altera (vai para `Alvos:`). Se outro cartão aberto mexe no mesmo alvo, o kit avisa e não abre.
4. Para fechar uma tarefa sem terminar: `/operador-pausar` (libera para outra sessão retomar). Se uma janela fechou sem pausar e o cartão ficou preso, peça ao gerente: ele mostra o comando `liberar-cartao.sh` e espera o seu ok.
5. Para voltar a um por vez: `- Cartões em paralelo: 1`.
