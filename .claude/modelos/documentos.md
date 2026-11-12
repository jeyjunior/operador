# Modelos de documentos

Tudo fica em `operacao/`, sem histórico. Mantenha cada documento curto e em português.

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
- Cartão aberto: #NNN — <título> — `operacao/cartoes/NNN-titulo/` (ou "nenhum")
- Próximo passo: <ex.: aprovar o plano | execução | /operador-encerrar | /operador-iniciar num gerente novo>
- Decisões pendentes: <decisão> (ou "nenhuma")
- Próximo ID: 001

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

- **Backlog:** pode virar trabalho. **A fazer:** combinado, ainda não começou. **Fazendo:** o cartão aberto. **Feito:** executado e conferido. **Homologado:** o usuário validou no uso real.
- "Homologado" guarda os 3 grupos mais recentes; os anteriores vão para `operacao/docs/historico.md`, no mesmo formato.
- Cartão cancelado sai do quadro: a pasta vai para `cartoes/_arquivo/` e o motivo fica no `cartao.md`.

## operacao/docs/operacao.md

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

- "Motores": a tabela de modelos só existe com `Modelos: setup`; com `padrão`, vale a tabela do `/operador-iniciar`.
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

Status: briefing | análise | plano | aprovado | execução | conferência | concluído | cancelado
Aberto: AAAA-MM-DD · Fechado: AAAA-MM-DD · Fluxo: <NN-nome ou "padrão">
Motores: <conta dos subagentes; modelos padrão ou setup; MCPs que a secundária tem>

## Briefing
- O que: ...
- Pronto quando: <comportamento observável, arquivo entregue ou número com unidade>
- Fora: ...
- P: ... — R: ...

## Análise
<resumo do que o analista (ou os passos do fluxo) trouxe: situação atual, opções, riscos. Pesquisa longa: link para docs/pesquisas/>

## Plano
- [ ] 1. <ação> — altera: <o quê> — backup: <arquivo em backups/ ou "não se aplica: motivo"> — desfazer: <como>
Aprovado pelo usuário em: AAAA-MM-DD

## Execução
- <o que foi feito, desvios e problemas, com trecho da saída que prova>

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

O `Status` diz onde retomar: um gerente novo lê o cartão aberto e continua do passo indicado.
