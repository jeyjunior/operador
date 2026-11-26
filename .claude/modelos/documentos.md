# Modelos de documentos

Tudo fica em `operacao/`, sem git (o hook guarda a versão anterior de cada `.md` em `operacao/.versoes/`). Mantenha cada documento curto e em português.

## .claude/rules/operacao.md

Criado pelo `/operador-iniciar` na primeira vez. Carregado em toda sessão.

```markdown
# Operação

**Nome:** <nome>
**Resumo:** <uma linha: o que esta operação cuida>
**Ambiente:** <ex.: servidor Ubuntu 24.04 em casa, acesso por `ssh casa` | quadro "Aulas" no Trello>
**Nunca:** <a regra mais importante do que não fazer, em uma linha>

Quadro: `operacao/QUADRO.md` · Operação: `operacao/docs/operacao.md` · Ambiente: `operacao/docs/ambiente.md`
```

## operacao/QUADRO.md

Só o gerente edita. Uma linha por cartão; o detalhe fica na pasta dele.

```markdown
# Quadro

## Situação
- Decisões pendentes: <decisão> (ou "nenhuma")

## Backlog
- #012 <pedido ou ideia> — <origem, AAAA-MM-DD>

## A fazer
- #011 <título> — combinado em AAAA-MM-DD

## Fazendo
- #010 <título> — desde AAAA-MM-DD — `cartoes/010-titulo/`

## Feito
- #009 <título> — AAAA-MM-DD — `cartoes/009-titulo/`
- #008 [curto] <o que foi feito> — AAAA-MM-DD — `cartoes/008-titulo/` (ou "sem pasta")

## Homologado
### AAAA-MM-DD — <onde e como foi validado>
- #007 <título> — `cartoes/007-titulo/`
```

- Os cartões abertos são os de "Fazendo" (um, ou até o limite de "Cartões em paralelo"). Número novo vem de `bash .claude/bin/novo-id.sh`; quadro antigo com "Próximo ID" continua valendo como piso e a linha pode sair.
- Com cartões em paralelo, o quadro muda só com Edit, trecho a trecho (o hook nega Write).
- O quadro não repete o próximo passo do cartão: ele fica só em "Onde parou" do `cartao.md` (duas cópias se desencontram). Quadro antigo com "Cartão aberto" ou "Próximo passo" na "Situação": apague essas linhas na próxima edição do quadro.
- **Backlog:** pode virar trabalho. **A fazer:** combinado e ainda não começou, ou pausado (`#NNN <título> — pausado em AAAA-MM-DD: <próximo passo> — cartoes/NNN-titulo/`). **Fazendo:** o cartão aberto. **Feito:** executado; conferido, ou com a conferência dispensada pelo usuário (registrado no cartão). **Homologado:** o usuário validou no uso real.
- "Homologado" guarda os 3 grupos mais recentes; os anteriores vão para `operacao/docs/historico.md`, no mesmo formato.
- Cartão cancelado sai do quadro: a pasta vai para `cartoes/_arquivo/` e o motivo fica no `cartao.md`.
- Com cartões em paralelo: cartão esperando outro fica em "Fazendo" com ` — esperando #NNN`; cartão devolvido volta ao Backlog (`#NNN <título> — devolvido: depende de #MMM — cartoes/NNN-titulo/`) e mantém a pasta.

## operacao/docs/operacao.md

"Configurações" guarda o que o usuário liga e desliga com `/operador-configurar`. "Cartões em paralelo" diz quantos cartões podem ficar abertos ao mesmo tempo, cada um numa sessão do Claude Code: `não` = um por vez (o padrão, também sem a linha), `sim` = sem limite, número = o limite. Operação antiga com a linha em "Limites" continua valendo; o `/operador-configurar` a move.

```markdown
# Operação

Atualizado: AAAA-MM-DD

## O que é
<um parágrafo: o que esta operação cuida, para quem e por quê>

## O que faz
- ...

## O que não faz / nunca fazer
- ...

## Limites
- Custo: <ex.: "só gratuito">
- Acesso: <o que o Claude pode e não pode tocar>

## Configurações
- Cartões em paralelo: não

## Como o usuário gosta de trabalhar
- <preferências que valem para todo cartão: tom, formato de relatório, horários, nível de detalhe>
```

## operacao/docs/ambiente.md

O estado atual. Cada cartão que muda o ambiente atualiza este arquivo no `/operador-encerrar`. Seções livres, conforme a operação. Exemplos:

```markdown
# Ambiente

Atualizado: AAAA-MM-DD (cartão #NNN)

## <seção>
- <item> — <estado> — cartão #NNN
```

- Servidor: sistema e versão, hardware, rede e portas, serviços, pacotes instalados fora do padrão, firewall, usuários, backups, tarefas agendadas.
- Aulas: turmas, alunos e andamento, material, estrutura do quadro do Trello (listas, etiquetas).
- Redes sociais: perfis, identidade visual (estilo, paleta, fontes), público, o que já foi publicado.

Só o que é verdade agora. O que mudou e quando fica no cartão.

## operacao/docs/ferramentas.md

```markdown
# Ferramentas

| Ferramenta | Tipo | Para quê | Segredo fica em | Status |
|---|---|---|---|---|
| ssh casa | SSH | acesso ao servidor | ~/.ssh/config e chave do usuário | ok (testado AAAA-MM-DD) |
| Trello | MCP | ler e mover cartões | conector, login do usuário | pendente: usuário autorizar no app |
```

Status é `ok (testado AAAA-MM-DD)` ou `pendente: <o que o usuário precisa fazer>`. O hook de abertura avisa os pendentes.

Seções opcionais, gravadas pelo `/operador-iniciar`:

```markdown
## Motores

Salvo em: AAAA-MM-DD
Subagentes: perguntar a cada vez | secundária no ciclo | principal
Modelos: padrão | setup

| Tipo | Modelo | Esforço |
|---|---|---|
| Pesquisa | sonnet | low |
| Análise | opus | high |
| Execução | sonnet | medium |
| Criação | sonnet | medium |
| Conferência | haiku | low |

## MCP por conta

| MCP | Prefixo na principal | Prefixo na secundária | Leitura na secundária |
|---|---|---|---|
| Trello | mcp__trello__ | mcp__claude_ai_Trello__ | mcp__claude_ai_Trello__trelloRead* |
| Notion | (conector do app) | mcp__claude_ai_Notion__ | <lista das ferramentas que só leem> |
```

- "Motores": a tabela de modelos só existe com `Modelos: setup`; com `padrão`, vale a tabela de `.claude/skills/operador-iniciar/motores.md`.
- "MCP por conta": o nome de uma ferramenta muda de uma conta para outra (conector do claude.ai vira `mcp__claude_ai_<Nome>__`). "Leitura na secundária" é o que o gerente pode liberar lá: só ferramentas que leem, confirmadas pelo usuário.

## operacao/docs/fluxos/NN-nome.md

Criado pelo `/operador-fluxo`.

```markdown
# Fluxo NN — <nome>

Atualizado: AAAA-MM-DD

**Quando usar:** <que tipo de pedido dispara este fluxo>
**Entrada:** <o que o usuário precisa dar no briefing>
**Saída:** <o que fica em entregas/ no fim>

## Passos
1. **<papel>** — tipo: <pesquisa | análise | execução | criação | conferência> — <o que faz, em 1 a 3 frases, como instrução ao subagente> — ferramentas: <...; MCP com "leitura" ou "escrita"> — entrega: <arquivo em entregas/ ou resposta>
2. ⏸ <o que o usuário decide aqui>
3. **<papel>** — ... — se reprovar: volta ao passo N, no máximo M vezes; depois disso, pausa para o usuário

## Regras do fluxo
- <o que vale em todos os passos>
```

## operacao/docs/pesquisas/NNN-tema.md

```markdown
# NNN — <tema>

Data: AAAA-MM-DD · Cartão de origem: #NNN

## Perguntas
1. ...

## Respostas
- P1: <resposta> — fonte: <link ou comando> — consultada em AAAA-MM-DD

## Opções
| Opção | Custo | Limites | Prós | Contras |
|---|---|---|---|---|

## Recomendação
<qual e por quê. Quem decide é o usuário.>

## O que não se confirmou
- ...
```

## operacao/docs/decisoes/NNN-titulo.md

```markdown
# NNN — <título>

Data: AAAA-MM-DD · Cartão de origem: #NNN · Status: aceita | substituída por NNN

## Contexto
<2 ou 3 frases>

## Decisão
<o que foi decidido>

## Alternativas consideradas
- <alternativa> — <por que não>
```

## operacao/cartoes/NNN-titulo/cartao.md

Criado pelo gerente quando o cartão vai para "Fazendo". Só o gerente edita.

```markdown
# #NNN — <título>

Status: briefing | análise | plano | aprovado | execução | aguardando-usuario | esperando #NNN | conferência | pausado | devolvido | concluído | cancelado
Aberto: AAAA-MM-DD · Fechado: AAAA-MM-DD · Fluxo: <NN-nome ou "padrão">
Motores: <conta dos subagentes; modelos padrão ou setup; MCPs que a secundária tem>
Alvos: <o que este cartão altera, separado por vírgula: postgres, journald, quadro Aulas do Trello; * = o ambiente inteiro>

## Onde parou
- Atualizado: AAAA-MM-DD HH:MM
- Último feito: <a última coisa concluída, com o número da ação>
- Próximo passo: <o que fazer agora, concreto>
- Esperando: ninguém | usuário: <o quê>
- Atenção: <o que fica fora desta pasta e precisa estar vivo: login do navegador, conector, sessão SSH> (ou "nada")

## Briefing
- O que: ...
- Pronto quando: <comportamento observável, arquivo entregue ou número com unidade>
- Fora: ...
- P: ... — R: ...

## Análise
<resumo do que o analista (ou os passos do fluxo) trouxe: situação atual, opções, riscos. Pesquisa longa: link para docs/pesquisas/>

## Plano
- [ ] 1. <ação> — altera: <o quê> — backup: <arquivo em backups/ ou "não se aplica: motivo"> — desfazer: <como>
Aprovado pelo usuário: AAAA-MM-DD (ações 1 a N) · AAAA-MM-DD (ação N+1, extensão 1)

## Execução
- AAAA-MM-DD <passo ou ação>: <resultado em uma linha> — prova: <trecho curto da saída, ou o arquivo em entregas/ que a guarda>

## Alterações
| # | O que mudou | Onde | Backup | Como desfazer |
|---|---|---|---|---|

## Conferência
- [ ] <critério de pronto> — <evidência: comando e saída, ou arquivo>

## Entregas
- `entregas/<arquivo>` — <o que é>

## Lições
- <o que se repetiu, funcionou ou atrapalhou, e o que fazer a respeito> (ou "nada")

## Para o backlog
- <o que surgiu e não cabe aqui> (ou "nada")
```

O `Status` diz em que passo o cartão está; "Onde parou" diz o que fazer agora. Um gerente novo, de qualquer conta, lê os dois e continua. `aguardando-usuario` vale enquanto o cartão espera uma resposta ou ação do usuário; com a resposta, volta ao status do passo. `pausado`: o cartão saiu de "Fazendo" por `/operador-pausar`; "Onde parou" diz o status ao retomar.

- "Execução" é lida a cada retomada: uma linha por passo ou ação. Saída longa, log e relatório vão para `entregas/` e a linha aponta para o arquivo.
- "Briefing" e "Análise" guardam o combinado **atual**: quando muda, reescreva (a versão anterior fica em `operacao/.versoes/`); rodadas de conversa, opções recusadas e tentativas não se acumulam ali. O que precisar ficar vai para `entregas/`.
- Ciclo curto usa o mesmo modelo só com `Status`, "Onde parou", "Briefing", "Execução", "Alterações" e "Entregas".

## operacao/parametros/parametro.json

Se a operação precisar de um arquivo de parâmetros, ele se chama `parametro.json`, fica em `operacao/parametros/` e tem esta forma (quem preenche é o usuário; você não lê nem grava esse arquivo):

```json
{
  "<NomeDaEmpresa>": {
    "ApiKey": "",
    "ApiSecret": ""
  },
  "Banco": {
    "Senha": ""
  }
}
```

- Um objeto por empresa ou serviço externo, com o nome dela (ex.: `GatewayPagamento`, `ServicoEmail`). `ApiKey` e `ApiSecret` são os nomes padrão; outras propriedades do mesmo serviço entram no mesmo objeto (ex.: `Passphrase`).
- `Banco` guarda a senha do banco; outras informações de conexão entram no mesmo objeto.
