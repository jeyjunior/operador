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
| 1 | **`atualizar-kit.sh`**: instala ou atualiza o kit numa pasta. Sem `--aplicar` só lista o que muda. Troca só o que é do kit (CLAUDE.md, settings.json, hooks, bin, modelos, agentes e skills que existem no kit); mantém `rules/`, `settings.local.json`, `.mcp.json`, `operacao/` e agente/skill próprios; remove o que está em `obsoletos.txt`; move tudo o que sai para `operacao/.versoes/kit-<data>/`; leva permissões próprias do `settings.json` para o `settings.local.json`; avisa hook próprio; grava `.claude/kit-versao.txt`; lista os "Levar ao kit:" do quadro. Idempotente. | 1, 7. Também substitui o `operador-usar` e o comando `rm -rf ... && cp` do README (escalabilidade: N operações atualizadas com um comando cada). | `.claude/bin/atualizar-kit.sh`, `.claude/bin/obsoletos.txt`, `README.md` |
| 2 | **Pausar cartão**: `/operador-encerrar pausar` grava "Onde parou" com o status ao retomar, `Status: pausado`, e move o cartão para o topo de "A fazer"; o `/operador-iniciar` mostra e retoma. | 2 (5 de 8 operações travadas; a 2 improvisou). | `skills/operador-encerrar/SKILL.md`, `skills/operador-iniciar/SKILL.md`, `modelos/documentos.md`, `CLAUDE.md`, `skills/operador-consultar/SKILL.md` |
| 3 | **Quadro sem "Próximo passo"**: a "Situação" fica com cartão aberto, decisões pendentes e próximo ID; o próximo passo existe só no "Onde parou". | 3 (dois casos de divergência). Menos uma edição por parada. | `modelos/documentos.md`, `skills/operador-encerrar/SKILL.md`, `skills/operador-iniciar/SKILL.md`, `README.md` |
| 4 | **"Trava negou, pare"** no `CLAUDE.md` e nos três agentes; executor só encerra processo pelo PID que ele iniciou. Trava que barra algo legítimo vira "Levar ao kit:". | 4 (contorno com `cd` + `rm`; 4 processos mortos por nome). | `CLAUDE.md`, `agents/*.md` |
| 5 | **`sed -i` negado em qualquer `.md` de `operacao/`** (antes só quadro, `docs/`, `cartao.md`). | 5. | `hooks/bloquear-comandos.sh`, teste |
| 6 | **`curl \| sha256sum` liberado**; `curl \| sh`, `\| sudo bash`, `\| zsh` continuam negados. | 6. | `hooks/bloquear-comandos.sh`, teste |
| 7 | **Hooks ~2x mais rápidos nas edições**: `comum.sh` lê a entrada com um único `jq` (`ler_entrada`), sem `tr`/subshell para minúsculas nem `shopt` em subshell. Medido (média de 8): `proteger-estrutura` 786 → 293 ms, `bloquear-segredos` 669 → 397 ms, `versionar` 595 → 289 ms; `bloquear-comandos` igual (~570 ms, dominado pelos `grep`). Modo sem `jq` conferido à mão. | 8. | `hooks/comum.sh` e os 5 hooks que o usam |
| 8 | **Motores fora do `operador-iniciar`**: a seção vai para `skills/operador-iniciar/motores.md`, lida só antes do primeiro disparo. `SKILL.md` do iniciar: 14,7 → 9,2 KB (~1,5 mil tokens a menos em toda sessão que não dispara subagente). | Desempenho; a seção era só para disparo. | `skills/operador-iniciar/SKILL.md`, `skills/operador-iniciar/motores.md`, `CLAUDE.md`, `modelos/documentos.md` |
| 9 | **`homologar` vira modo do `encerrar`** (`/operador-encerrar homologar`); o encerrar já o chamava por arquivo. 6 → 5 comandos. | Simplificação proposta nas duas rodadas; uma leitura a menos no fechamento. | `skills/operador-encerrar/SKILL.md`, skill `operador-homologar` removida, `obsoletos.txt` |
| 10 | **`rules/parametros.md` sai de `rules/`** e vira seção de `modelos/documentos.md` (lido só quando se cria documento). | 1 (arquivo do kit em pasta da operação) e ~700 bytes a menos em toda sessão. | `modelos/documentos.md`, `.gitignore`, `obsoletos.txt` |
| 11 | **Ciclo curto com `Status` e "Onde parou"**, e "Cartão aberto" aponta para ele enquanto dura. | 9. | `skills/operador-ciclo-curto/SKILL.md`, `modelos/documentos.md` |
| 12 | **"Execução" com uma linha por passo**; saída longa vai para `entregas/` e a linha aponta o arquivo. | 10. | `modelos/documentos.md` |
| 13 | README: personalização de modelos/padrões de segredo passa a ser "leve ao kit" (eles são trocados na atualização; o README dizia as duas coisas). | Contradição entre "Atualizar" e "Personalização". | `README.md` |

O que **saiu**: skill `operador-homologar`, `rules/parametros.md`, a dica do `operador-usar` no README. O que **entrou**: `atualizar-kit.sh`, `obsoletos.txt`, `motores.md` (movido, não novo).

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

- `bash .claude/bin/testar-hooks.sh`: **93 ok, 0 falha** (eram 84 casos; +4 de comandos: `sed -i` em `entregas/*.md` negado, `sed -n` liberado, `curl | sudo bash` negado, `curl | sha256sum` liberado; +5 do `atualizar-kit.sh`: sem `--aplicar` não altera, troca o kit e mantém `rules/` e `operacao/`, leva permissão própria para o `settings.local.json`, guarda o que saiu em `.versoes/`, recusa pasta dentro do kit). Tempo total 58 s → 50 s com mais casos.
- **Sem `jq`** (PATH filtrado): `proteger-estrutura` nega subagente no quadro, `bloquear-comandos` nega `rm -rf /var/x`, `bloquear-segredos` nega token.
- **Atualização numa cópia real**: `.claude` + `CLAUDE.md` + `QUADRO.md` da 7_Gmail copiados para o scratchpad. Listou 13 itens a trocar, 2 obsoletos e os 20 `deny` do Gmail; com `--aplicar`, os `deny` foram para o `settings.local.json`, `rules/operacao.md` ficou, o que saiu foi para `operacao/.versoes/kit-2026-11-24-214001/`; segunda rodada: "Kit já está atualizado".
- **Ciclo mínimo simulado** (pasta nova no scratchpad, cada escrita passando pelos três hooks reais e cada comando pelo `bloquear-comandos`): instalar pelo script → abertura avisa "rode /operador-iniciar" → gerente grava `operacao.md`, `rules/operacao.md`, quadro e cartão → analista grava em `entregas/` → analista negado no `cartao.md`, executor negado no quadro, `sed -i` em `entregas/*.md` negado → pausar (cartão `pausado`, quadro em "A fazer") → retomar e concluir → `mv` para `_arquivo/` liberado, `rm -r` negado → 6 versões guardadas em `.versoes/`.
- **Não verificado**: comportamento das skills com um modelo de verdade (pausar/retomar), confirmações `ask` no app, `secundaria.sh` contra a conta secundária.

---

## 7. Como migrar as operações (passo a passo, não executado)

Pré-requisito: mesclar `melhoria-a` (ou copiar o clone `operador-a`) e rodar o autoteste.

1. Feche todas as sessões abertas nas operações.
2. No clone do kit: `bash .claude/bin/testar-hooks.sh` (93 ok).
3. Para cada operação, primeiro só a lista:
   ```bash
   bash .claude/bin/atualizar-kit.sh ../../2_Servidor_Linux
   ```
   Confira: "muda/novo" só em itens do kit; "sai" só `operador-homologar` e `rules/parametros.md`; a linha de permissões próprias (na 7_Gmail, os 20 `deny`); "ATENÇÃO: hooks próprios" não deve aparecer (se aparecer, passe à mão para o `settings.local.json`).
4. Aplique: mesma linha com `--aplicar`. Repita para 3, 4, 5, 6, 7, 8. A 9 está vazia: dá para instalar com o mesmo comando quando for usar.
5. Em cada operação, abra uma sessão e confira a mensagem de abertura (sem aviso de estrutura) e `.claude/kit-versao.txt`.
6. Arrumar o estado de cada operação (numa sessão normal, com o gerente):
   - 4_Worker #011 e 8 #008: o quadro tem "Próximo passo" divergente; com o modelo novo, apague a linha "Próximo passo" da "Situação" e confira o "Onde parou" do cartão.
   - 2_Servidor #029: rode `/operador-iniciar`, escolha retomar o #029 e, se continuar parado, `/operador-encerrar pausar` para gravar `Status: pausado` (hoje está `análise` em "A fazer").
   - 5 #001, 6 #003, 7 #002: retomar ou `/operador-encerrar pausar` (ou `cancelar`), para liberar "Fazendo".
   - 3_Doc_Space: `/operador-encerrar homologar` move o 4º grupo de "Homologado" para `historico.md` na próxima homologação.
   - 2_Servidor `docs/operacao.md`: a lição do `| sha256sum` deixa de ser necessária; as lições sobre hooks viram itens "Levar ao kit:" se ainda incomodarem.
   - 8_InsaneIA #003 e #005 ("Levar ao kit"): aparecem na saída do script; levar para o `operador-midia` no clone do kit.
7. O `operador-usar/` deixa de ser necessário (o script instala direto). Pode ficar como está; não é atualizado.
8. Se algo der errado numa operação: o que saiu está em `operacao/.versoes/kit-<data>/`; copie de volta `CLAUDE.md` e `.claude/` de lá.

Regra para o futuro: mudança no kit → autoteste → `atualizar-kit.sh` em cada operação. O `kit-versao.txt` diz qual operação está atrás.
