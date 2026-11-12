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
| Situação | cartão aberto, próximo passo, decisões pendentes, próximo ID |
| Backlog | pedidos e ideias |
| A fazer | combinado, ainda não começou |
| Fazendo | o cartão aberto (um por vez) |
| Feito | executado e conferido |
| Homologado | você validou no uso real |

---

## Comandos

| Comando | Para quê |
|---|---|
| `/operador-iniciar` | Entrada única. Na primeira vez, entrevista você e monta a operação. Depois, retoma o cartão aberto ou abre um novo. |
| `/operador-encerrar` | Fecha o cartão: atualiza `ambiente.md`, registra lições e move para "Feito". Com `cancelar`, arquiva sem concluir. |
| `/operador-ciclo-curto` | Trabalho pequeno, sem análise nem decisão, numa sessão só. |
| `/operador-consultar` | Pergunta sobre a operação ou o ambiente, numa sessão à parte. Só lê. |
| `/operador-fluxo` | Cria ou ajusta um fluxo (receita de trabalho). |
| `/operador-homologar` | Leva cartões de "Feito" para "Homologado". |

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

Um gerente por cartão: para o próximo trabalho, abra uma sessão nova e rode `/operador-iniciar` de novo. Se o contexto ficar pesado no meio, feche e abra outra sessão: ela continua pelo `Status` do `cartao.md`.

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
- **Segredos ficam com você**: em `operacao/parametros/`, no `~/.ssh/config`, no conector MCP. O Claude usa acesso só por referência (alias do SSH, conector autenticado) e nunca lê, pede ou imprime o valor.- **Dados de pessoas** (alunos, clientes) não saem para serviços externos sem você pedir.
- **Sem git nas operações**: nada em `operacao/` tem histórico. Por isso as travas negam apagar arquivos ali (o cancelamento arquiva). Faça backup dessa pasta por conta própria.

### Travas

| Trava | O que faz |
|---|---|
| `hooks/proteger-estrutura.sh` | Nada solto no Root; `parametros/` negado; subagente só grava em `entregas/` e `backups/` do cartão. |
| `hooks/bloquear-comandos.sh` | Comandos destrutivos (inclusive dentro de `ssh "..."`), apagar em `operacao/`, parar o SSH do servidor. |
| `hooks/bloquear-segredos.sh` | Nega edição que escreve chave, token ou senha literal. |
| `hooks/verificar-ambiente.sh` | Ao abrir a sessão: estrutura, `jq`, ferramenta pendente, `.git` copiado por engano. |
| `settings.json` | Nega ler `parametros/` e `.env`; `ssh`, `scp` e `rsync` pedem confirmação. |

Limites conhecidos: as travas pegam o óbvio, não tudo. O "só leitura" do analista e do conferente no ambiente remoto é por instrução, não por trava.

---

## Requisitos

- App Claude desktop, aba Code.
- `bash` (no Windows, o Git Bash, que vem com o Git for Windows).
- [`jq`](https://jqlang.org): recomendado. Sem ele, as travas funcionam em modo menos preciso, e o kit avisa ao abrir a sessão.

## Instalação

O kit é uma **pasta modelo**. Para cada operação:

1. Crie a pasta da operação (ex.: `servidor-linux/`).
2. Copie para dentro dela o `CLAUDE.md` e a pasta `.claude/` deste repositório. Não copie o `README.md`, o `.git` nem o `.gitignore`.
3. Abra uma sessão Code nessa pasta e rode `/operador-iniciar`. Na primeira vez ele pergunta o que é a operação, como se acessa o ambiente, que ferramentas você usa e o que nunca fazer. Depois sugere um primeiro cartão de levantamento do ambiente.

Dica: mantenha ao lado do clone uma pasta `operador-usar/` só com `CLAUDE.md` e `.claude/`, pronta para copiar. Para refazê-la depois de atualizar o kit, rode de dentro do clone:

```bash
bash .claude/bin/testar-hooks.sh && rm -rf ../operador-usar && mkdir ../operador-usar && cp -r CLAUDE.md .claude ../operador-usar/ && rm -f ../operador-usar/.claude/settings.local.json
```

O `settings.local.json` é removido porque guarda permissões dadas em sessões locais, que não devem ir para as operações.

## Ferramentas

O gerente descobre, durante a análise, se falta alguma ferramenta (MCP do Trello, acesso SSH, API de imagem). Ele pesquisa e propõe; **você liga**: faz o login do conector, coloca a chave no lugar dela e aprova a mudança em `.mcp.json`. A ferramenta fica registrada em `operacao/docs/ferramentas.md` com o status, e o kit avisa ao abrir a sessão enquanto ela estiver pendente.

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

Copie a versão nova de `CLAUDE.md` e das pastas `.claude/skills/`, `.claude/agents/`, `.claude/hooks/`, `.claude/bin/` e `.claude/modelos/`. Mantenha `.claude/rules/`, `.claude/settings.json`, `.mcp.json` e `operacao/`, que são da operação.

## Personalização

- **`.claude/settings.json`**: permissões. Uma operação de servidor pode liberar `ssh` sem confirmação.
- **`.claude/rules/`**: regras da operação (o `operacao.md` é criado pelo `/operador-iniciar`).
- **`.claude/modelos/documentos.md`**: os modelos do quadro, do cartão e dos documentos.
- **`.claude/hooks/padroes-segredos.txt`**: as expressões regulares de segredo.
- **Nomes**: skills do kit usam `operador-<comando>`; subagentes, `operador-sub-<papel>`. Isso evita conflito com skills de outros projetos.

## Testes do kit

```bash
bash .claude/bin/testar-hooks.sh
```

Testa as travas numa pasta temporária, sem tocar no kit nem numa operação real.
