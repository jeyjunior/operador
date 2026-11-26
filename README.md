# Operador

Kit para o [Claude Code](https://claude.com/claude-code) que conduz **operações do dia a dia**: manter um servidor, organizar aulas num Trello, criar conteúdo para redes sociais, ou qualquer rotina que você repete e que exige contexto.

O problema que ele resolve: a cada sessão nova você gasta mais tempo explicando o seu servidor, o seu quadro ou o seu estilo do que fazendo o trabalho. No Operador, cada operação tem uma pasta com **um quadro de cartões**, **o estado atual do ambiente** e **o histórico do que foi feito**. Um **gerente** lê isso ao abrir, conversa com você e dispara **subagentes** para analisar, executar e conferir.

> **Experimental:** as travas têm autoteste; o fluxo completo das skills ainda está sendo usado pela primeira vez em operações reais.

---

## Como funciona

### Uma pasta por operação

```
minhas-operacoes/
├── servidor-linux/          ← cada uma é uma cópia do kit
├── aulas-trello/
└── redes-sociais/
```

Dentro de cada operação:

```
servidor-linux/              ← abra o Claude Code sempre aqui
├── CLAUDE.md, .claude/      o kit: regras, skills, subagentes, travas
├── .mcp.json                ferramentas MCP desta operação (opcional)
└── operacao/                criada no primeiro /operador-iniciar
    ├── QUADRO.md            situação, backlog, a fazer, fazendo, feito, homologado
    ├── docs/
    │   ├── operacao.md      o que é a operação, limites, o que nunca fazer
    │   ├── ambiente.md      o estado atual do que a operação cuida
    │   ├── ferramentas.md   cada ferramenta, como conecta, status
    │   ├── fluxos/          receitas de trabalho para pedidos que se repetem
    │   ├── pesquisas/       com fonte e data
    │   └── decisoes/
    ├── cartoes/
    │   ├── 007-instalar-adguard/
    │   │   ├── cartao.md    briefing, análise, plano, execução, alterações, conferência
    │   │   ├── entregas/    o que o trabalho gerou
    │   │   └── backups/     cópia do que foi alterado, antes de alterar
    │   └── _arquivo/        cartões cancelados (nada é apagado)
    └── parametros/          seus segredos (o Claude não lê)
```

### Cartão

Um cartão é **uma tarefa inteira**, com começo, meio e fim. "Instalar o AdGuard no servidor" é um cartão só, mesmo que envolva analisar, instalar e configurar. Ele tem um número único (`#007`), e tudo o que ele gera fica em `cartoes/007-instalar-adguard/`. O número no quadro é o vínculo.

### `ambiente.md`

É a memória do especialista: o estado atual do que a operação cuida. Num servidor, isso quer dizer pacotes, serviços, portas e firewall. Num Trello de aulas, turmas, alunos e andamento. Todo cartão que muda algo atualiza esse arquivo ao fechar. É por isso que a próxima sessão começa sabendo onde parou.

### Quadro

| Lista | O que tem |
|---|---|
| Situação | decisões pendentes (o próximo passo fica só no cartão) |
| Backlog | pedidos e ideias |
| A fazer | combinado e ainda não começou, ou pausado |
| Fazendo | os cartões abertos (um por vez, ou em paralelo se a operação ligar) |
| Feito | executado; conferido ou com a conferência dispensada por você |
| Homologado | você validou no uso real |

---

## Comandos

| Comando | Para quê |
|---|---|
| `/operador-iniciar` | Entrada única. Na primeira vez, entrevista você e monta a operação. Depois, retoma o cartão aberto ou abre um novo. |
| `/operador-encerrar` | Fecha o cartão: atualiza `ambiente.md`, registra lições e move para "Feito". |
| `/operador-pausar` | Tira o cartão aberto de "Fazendo" sem fechar: volta para "A fazer" com "Onde parou" gravado. |
| `/operador-cancelar` | Desiste do cartão aberto: pergunta o que desfazer e arquiva a pasta (nada é apagado). |
| `/operador-configurar` | Mostra e muda as configurações da operação, como ligar ou desligar os cartões em paralelo. Vale para toda sessão. |
| `/operador-homologar` | Leva cartões de "Feito" para "Homologado". |
| `/operador-ciclo-curto` | Trabalho pequeno, sem análise nem decisão, numa sessão só. |
| `/operador-consultar` | Pergunta sobre a operação ou o ambiente, numa sessão à parte. Só lê. |
| `/operador-fluxo` | Cria ou ajusta um fluxo (receita de trabalho). |

### O ciclo de um cartão

```
/operador-iniciar
  ├─ briefing ............ o que você quer, como saber que ficou pronto, o que fica de fora
  ├─ análise ............. operador-sub-analista investiga o ambiente (só leitura) e traz opções
  ├─ plano ............... cada ação com backup e como desfazer  →  SEU OK
  ├─ execução ............ operador-sub-executor segue o plano e para se algo sair dele
  ├─ conferência ......... operador-sub-conferente verifica no ambiente real (opcional)
/operador-encerrar ....... ambiente.md, lições, quadro; fecha a sessão
```

Um gerente por cartão: para o próximo trabalho, abra uma sessão nova e rode `/operador-iniciar` de novo. Se o contexto ficar pesado no meio, feche e abra outra sessão: ela continua pelo "Onde parou" do `cartao.md`. Para trocar de trabalho sem terminar o cartão, `/operador-pausar`.

Exemplo de pedido rápido: "qual a versão do kernel do servidor?" não abre cartão. O próprio `/operador-iniciar` responde como consulta, ou você usa `/operador-consultar`.

### Fluxos

Quando um tipo de pedido se repete com o mesmo jeito de trabalhar, rode `/operador-fluxo` e descreva. O gerente grava a receita em `operacao/docs/fluxos/`:

```
Fluxo 01 — gerar post
1. tendências   → pesquisa o que está em alta
2. cruzamento   → cruza com o perfil e propõe 3 ideias
   ⏸ você escolhe uma
3. criação      → gera a arte com a ferramenta definida
4. aprovação    → revisa; se reprovar, volta ao 3 (máx. 2 vezes)
   ⏸ você aprova
5. texto        → legenda e hashtags
```

Cada papel vira um subagente. Nas pausas (⏸), o gerente para e fala com você. Quando um pedido combina com um fluxo, o `/operador-iniciar` o usa no lugar da análise e da execução padrão.

### Imagem e vídeo

A skill `operador-midia` (não é comando: o gerente a carrega sozinho quando o pedido envolve imagem ou vídeo) traz o conhecimento base:

- `estilos.md` e `estilos.jpg`: 15 estilos com o bloco de prompt de cada um e a folha numerada para você escolher;
- `google-flow.md`: como operar o Google Flow (gerar, baixar, animar, créditos, o que dá errado);
- `conferencia.md`: o que conferir em cada imagem e vídeo;
- `fluxo-midia.md`: modelo de fluxo que o `/operador-fluxo` adapta à operação.

É ponto de partida: o que a operação decide em `operacao/docs/` (identidade visual, estilos próprios) vale mais. A operação não edita a skill; fato novo vira pesquisa ou decisão da operação e é levado ao kit depois.

---

## Papéis

| | Gerente | Subagentes |
|---|---|---|
| Quem é | a sessão que você abre | `operador-sub-analista`, `operador-sub-executor`, `operador-sub-conferente` e os papéis dos fluxos |
| Conversa com você | sim | não: param e devolvem ao gerente |
| Edita quadro, cartão e docs | sim (o único) | não (o hook nega) |
| Altera o ambiente | não | só o executor, só o plano aprovado |
| Grava arquivos | documentos | só `entregas/` e `backups/` do cartão |

## Segurança

- **Nada muda fora da pasta sem o seu ok.** Toda alteração segue a mesma ordem: está no plano aprovado, tem backup em `backups/`, é executada e fica registrada no cartão com o jeito de desfazer. Publicar, enviar mensagem, apagar dados e gastar dinheiro pedem um ok específico, mesmo com o plano aprovado.
- **Segredos ficam com você**: em `operacao/parametros/`, no `~/.ssh/config`, no conector MCP. O Claude usa acesso só por referência (alias do SSH, conector autenticado) e nunca lê, pede ou imprime o valor.
- **Dados de pessoas** (alunos, clientes) não saem para serviços externos sem você pedir.
- **Sem git nas operações**: antes de cada edição de um `.md` em `operacao/`, o kit guarda a versão anterior em `operacao/.versoes/`. Apagar não tem volta: as travas negam apagar arquivos ali (o cancelamento arquiva). Faça backup dessa pasta por conta própria.

### Travas

| Trava | O que faz |
|---|---|
| `hooks/proteger-estrutura.sh` | Nada solto no Root; `parametros/` negado; subagente só grava em `entregas/` e `backups/` do cartão (caminho com `..` resolvido antes). Fora da operação, só o executor grava, e nunca na configuração do Claude, em `~/.ssh` ou em outra operação. |
| `hooks/bloquear-comandos.sh` | Nega comandos destrutivos (inclusive dentro de `ssh "..."`), apagar em `operacao/`, escrever no quadro, em `docs/` ou em `cartao.md` por shell, tocar em `parametros/` e agendar tarefa no Windows. Pede confirmação para o que pode trancar ou derrubar um servidor (`ufw`, `iptables`, `reboot`, `shutdown`, remover o `openssh`) ; com cartão de outra sessão aberto, nega o reboot/firewall e o restart de um alvo dela (`systemctl restart`, `docker stop`) mandando esperar; na conta secundária, nega o que pediria confirmação. |
| `hooks/proteger-mcp.sh` | Ferramenta de MCP que escreve (enviar, publicar, criar, mover, apagar): você confirma cada chamada do gerente e do executor; os outros papéis e a conta secundária não usam. |
| `hooks/versionar.sh` | Guarda a versão anterior de cada `.md` de `operacao/` em `operacao/.versoes/` antes da edição. |
| `hooks/proteger-estrutura.sh` (cartões) | Nega cartão novo (ou pausado voltando) além do limite de "Cartões em paralelo"; com o limite acima de 1, nega editar o cartão que outra sessão editou há menos de 30 minutos e Write em quadro, `ambiente.md` e `historico.md`, e nega, sem perguntar, dois cartões abertos com alvo em comum (o gerente espera ou devolve o seu). |
| `hooks/bloquear-segredos.sh` | Nega edição que escreve chave, token ou senha literal. |
| `hooks/verificar-ambiente.sh` | Ao abrir a sessão: estrutura, `jq`, ferramenta pendente, `.git` copiado por engano. |
| `settings.json` | Nega ler `parametros/` e `.env`; `ssh`, `scp` e `rsync` pedem confirmação; editar hooks, scripts, agentes e as permissões da operação também. |

Limites conhecidos: as travas pegam o óbvio, não tudo. O "só leitura" do analista e do conferente no ambiente remoto é por instrução, não por trava. Escrita por shell que não cita o caminho (`cd operacao && ...`) não é pega. O hook de MCP reconhece a ação pelo nome da ferramenta (`send`, `create`, `delete`...): nome fora do padrão passa.

---

## Requisitos

- App Claude desktop, aba Code.
- `bash` (no Windows, o Git Bash, que vem com o Git for Windows).
- [`jq`](https://jqlang.org): recomendado. Sem ele, as travas funcionam em modo menos preciso, e o kit avisa ao abrir a sessão.

## Instalação

O kit é uma **pasta modelo**. No Windows, dê dois cliques em `instalar.cmd` (abre o `instalar.sh` no Git Bash). Em qualquer sistema: `bash instalar.sh`.

O instalador pergunta a pasta onde fica (ou vai ficar) a operação e o nome dela, e segue pelo que encontrar:

| A pasta | O que ele faz |
|---|---|
| Não existe ou está vazia | Mostra que é uma operação nova, pede confirmação e copia `CLAUDE.md` e `.claude/`. |
| Já tem o kit | Mostra o que muda, pede confirmação e atualiza (veja "Atualizar o kit numa operação"). |
| Tem outra coisa | Para sem mexer. |

Depois de criar, abra o Claude Code (aba Code) na pasta e rode `/operador-iniciar`. Na primeira vez ele pergunta o que é a operação, como se acessa o ambiente, que ferramentas você usa e o que nunca fazer, e sugere um primeiro cartão de levantamento do ambiente.

Sem perguntas: `bash instalar.sh <pasta>` aplica direto; `bash instalar.sh <pasta> --ver` só mostra o que mudaria. O instalador nunca copia o `README.md`, o `.git` nem o `settings.local.json` do clone.

Se o `instalar.cmd` disser que não achou o Git: instale o Git for Windows (https://git-scm.com/download/win), que traz o Git Bash, e rode de novo. O `.cmd` procura o Git Bash pelo próprio `git` (`git --exec-path`), porque o `bash` que o Windows acha primeiro pode ser o do WSL.

## Ferramentas

O gerente descobre, durante a análise, se falta alguma ferramenta (MCP do Trello, acesso SSH, API de imagem). Ele pesquisa e propõe; **você liga**: faz o login do conector, coloca a chave no lugar dela e aprova a mudança em `.mcp.json`. A ferramenta fica registrada em `operacao/docs/ferramentas.md` com o status, e o kit avisa ao abrir a sessão enquanto ela estiver pendente.

## Cartões em paralelo (opcional)

Por padrão a operação tem **um cartão aberto por vez**: enquanto houver um em "Fazendo", nenhuma sessão abre outro. Para tocar duas ou mais tarefas ao mesmo tempo (no servidor: o banco de dados numa sessão, o log de desligamento em outra), rode `/operador-configurar` e ligue o paralelo. Ele grava em `operacao/docs/operacao.md`, na seção "Configurações":

```
- Cartões em paralelo: sim
```

`sim` = sem limite; um número = esse limite; `não` (ou sem a linha) = um por vez. A linha é da operação: vale para toda sessão e toda conta, e a atualização do kit não a toca.

Como funciona, com o limite acima de 1:

- **Uma sessão do Claude Code por cartão.** Abra outra janela ou aba na mesma pasta e rode `/operador-iniciar`. Um gerente não toca dois cartões: o contexto de um vazaria para o outro.
- **Limite:** o hook nega o cartão novo (ou o pausado que volta ao trabalho) que passa do limite, mesmo com duas sessões abrindo no mesmo instante.
- **Números:** `bash .claude/bin/novo-id.sh` reserva o próximo `#NNN` (uma pasta em `operacao/.ids/`); duas sessões nunca recebem o mesmo.
- **Dono:** o cartão é da sessão que o editou por último (`.dono` na pasta do cartão, com a hora). Outra sessão é negada nele enquanto a dona o editou há menos de 30 minutos; depois disso, quem editar assume (a sessão fechada sem pausar não prende o cartão). Para liberar antes, com o seu ok: `bash .claude/bin/liberar-cartao.sh NNN`. O `/operador-pausar` libera sozinho.
- **Alvos:** cada cartão diz em `Alvos:` o que altera (`postgres`, `journald`, `*` para o ambiente inteiro). Alvo em comum com outro cartão aberto (igual, um começando pelo outro, como `postgres` e `postgresql` ou `/etc` e `/etc/fstab`, ou `*`): o hook nega e o gerente resolve **sem te perguntar**.
- **Conflito se resolve sozinho:** quando um cartão depende de outro aberto ou atrapalha o trabalho dele, o gerente **espera** (`Status: esperando #NNN`; `esperar-cartao.sh` acorda a sessão quando o outro fecha, pausa ou é devolvido, até 120 min) ou, se o seu cartão ainda não alterou nada, **devolve** o seu ao Backlog sem registro (`Status: devolvido`, a pasta fica). Espera quando o outro está perto do fim (aprovado, execução, conferência) ou quando o seu já alterou algo; devolve quando o outro ainda está no briefing, análise, plano ou esperando você. Cartão esperando ou devolvido não trava alvo, então dois nunca esperam um pelo outro.
- **Ações que afetam tudo** (reboot, firewall, acesso) com outro cartão aberto: o hook nega e o gerente espera. Parar ou reiniciar serviço (`systemctl restart`, `service ... stop`, `docker stop`) só é negado quando o comando cita um alvo de outro cartão aberto; o resto passa.
- **Quadro, `ambiente.md` e `historico.md`:** só mudam com Edit, trecho a trecho (o hook nega Write, que regravaria o arquivo inteiro a partir da cópia lida pela sessão). O Edit troca só o trecho dele e recusa quando o arquivo mudou depois da leitura; a sessão relê e refaz. Antes de cada gravação, a versão anterior vai para `operacao/.versoes/`.

Não cobre: dois cartões que mexem em coisas que se afetam sem nome parecido em `Alvos:` (o hook compara palavras; a dependência fica a cargo do gerente, no briefing e no fim da análise); restart de um alvo de outro cartão escrito com outro nome (`postgresql@16-main` passa por `postgres`, `pg` não); cartão esperando não é protegido pelo hook contra outra sessão que o retome; uma sessão viva parada há mais de 30 minutos sem editar o cartão perde a vez para quem editar; conta secundária e subagentes continuam valendo para o cartão da sessão que os disparou.

## Conta secundária (opcional)

Se você tem uma segunda conta do Claude Code, o gerente pode rodar o analista, o conferente e os papéis de fluxo nela, pela CLI. A conta principal gasta só o pedido e o resumo; a leitura e o raciocínio pesados ficam na secundária.

**Preparar, uma vez por máquina** (PowerShell):

```powershell
$env:CLAUDE_CONFIG_DIR = "$HOME\.claude-secundaria"
claude
```

Faça login com a conta secundária e saia com `/exit`. Para usar outra pasta, defina a variável de ambiente `OPERADOR_CONTA_CLI` com o caminho dela.

**Ao abrir uma sessão**, o `/operador-iniciar`:

1. se há um setup salvo na operação, pergunta só se usa o salvo ou ajusta;
2. confere se a secundária existe e está logada;
3. **onde rodam os subagentes:** perguntar a cada um, na secundária durante todo o ciclo, ou só na principal;
4. **modelos:** o padrão do operador, ou um setup seu, com modelo e esforço por tipo de tarefa (pesquisa, análise, execução, criação, conferência);
5. oferece salvar para a operação.

**Padrão do operador:** sonnet em tudo (baixo na pesquisa e na conferência, médio no resto). Sobe para opus alto quando há risco difícil de desfazer, mais de um caminho razoável ou um alvo crítico, e diz o motivo. No seu setup, o gerente não sobe nada sozinho: pergunta antes.

**MCP na secundária:** antes de disparar um papel que precisa de MCP, o gerente roda `secundaria.sh mcp` (sem tokens). Se o MCP faltar, ele pergunta: você habilita na secundária e ele espera, o papel roda na principal, ou o passo é abortado (o cartão fica onde está). Lá, o MCP é liberado só para leitura.

A cada papel, o kit entrega à secundária as suas regras globais (`~/.claude/CLAUDE.md` e os hooks de `~/.claude/settings.json`), o `CLAUDE.md` e as rules da operação, as travas da operação e o texto do papel. Nada é gravado na pasta da secundária. Para ver o que vai em cada chamada: `bash .claude/bin/secundaria.sh regras` e `bash .claude/bin/secundaria.sh instrucoes analista`.

**O que roda onde:**

| Papel | Onde |
|---|---|
| Analista, conferente, papéis de fluxo (inclusive lendo Trello ou Notion) | secundária, se escolhida e se ela tiver o MCP |
| Executor | sempre principal (a CLI não pede confirmação no meio) |
| Papel que escreve por MCP (mover cartão, criar página) | sempre principal |

Na secundária, o papel roda com as travas da operação e só grava em `entregas/` e `backups/` do cartão. Requer `jq`.

## Atualizar o kit numa operação

Feche as sessões do Claude Code da operação e rode o instalador apontando para a pasta dela. Ele compara cada arquivo do kit na operação com **todas as versões do kit no histórico git** do clone e decide:

| O arquivo na operação | O que acontece |
|---|---|
| É uma versão do kit (atual ou antiga) | Troca pela versão nova. |
| `settings.json` com conteúdo próprio | **Mescla:** o `settings.json` novo do kit mais as permissões (`allow`, `ask`, `deny`), os hooks e as chaves que a operação acrescentou, sem duplicar. |
| `padroes-segredos.txt` com linhas próprias | Mescla: o arquivo novo mais as linhas da operação, num bloco "# Da operação". |
| Outro `.md` do kit editado na operação | Troca pela versão nova; o texto que a operação acrescentou vai para `.claude/rules/kit-migrado.md` (carregado em toda sessão) para você revisar. |
| Outro arquivo do kit editado (script) | Troca pela versão nova; a diferença fica em `REVISAR.md` na cópia. |
| Arquivo que o kit não tem mais | Sai (fica na cópia). |
| Arquivo próprio (rules, skill ou agente com outro nome, hook seu) | Fica como está. |

- **Nada se perde:** tudo o que muda ou sai é copiado antes para `operacao/.versoes/kit-<data>/`. Se houver edição local, `REVISAR.md` nessa pasta mostra a diferença para a versão do kit mais parecida.
- **Rodar de novo não muda nada.** A versão instalada fica em `.claude/VERSAO`.
- Não toca em `.claude/rules/` (só tira um arquivo do kit que saiu e não foi editado), `settings.local.json`, `.mcp.json` nem `operacao/` (só cria `.versoes/kit-<data>/`).
- Lista os itens "Levar ao kit:" do quadro da operação, para virarem melhoria aqui.
- No fim, roda os autotestes do kit na operação.
- Precisa do `git` (o reconhecimento das versões usa o histórico do clone; sem o `.git`, só a versão atual é reconhecida e o resto vai para revisão) e do `jq` quando o `settings.json` tem conteúdo próprio.

## Personalização

- **Permissões e hooks da operação**: no `.claude/settings.json` (a atualização mescla e preserva) ou no `.claude/settings.local.json` (nunca é tocado). Os dois somam às regras do kit, inclusive na conta secundária. Uma operação de servidor pode liberar `ssh` sem confirmação: `{"permissions": {"allow": ["Bash(ssh casa *)"]}}`.
- **`.claude/rules/`**: regras da operação (o `operacao.md` é criado pelo `/operador-iniciar`).
- Modelos, skills e agentes do kit: prefira mudar no clone do kit (chega a todas as operações) e, na operação, anotar "Levar ao kit: <o quê>" no Backlog. Se editar na própria operação, a atualização não perde o texto: ele vai para `.claude/rules/kit-migrado.md` e para a cópia.
- **Nomes**: skills do kit usam `operador-<comando>`; subagentes, `operador-sub-<papel>`. Isso evita conflito com skills de outros projetos.

## Testes do kit

```bash
bash .claude/bin/testar-hooks.sh   # as travas (roda também dentro de uma operação)
bash testar-instalar.sh            # o instalador (só no clone do kit)
```

Rodam numa pasta temporária, sem tocar no kit nem numa operação real.
