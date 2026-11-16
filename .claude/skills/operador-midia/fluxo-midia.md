# Fluxo NN — Geração de imagem e vídeo

Atualizado: AAAA-MM-DD

Modelo do kit. O `/operador-fluxo` adapta à operação (ferramenta, identidade visual, personagens, proporção do destino, teto de créditos, tamanho do lote) e grava em `operacao/docs/fluxos/`. Sem vídeo, tire os passos 7 e 8. Caminho da skill: `.claude/skills/operador-midia/`.

**Quando usar:** gerar uma ou mais imagens, ou vídeos a partir delas, com IA.
**Entrada:** quantidade, uso e destino (proporção), assunto de cada imagem, se aparece pessoa real, teto de créditos.
**Saída:** `entregas/prompts.md` (ID → arquivo, prompt, modelo, proporção, data, créditos) e os arquivos aprovados em `entregas/<lote>/NN-slug.jpg` (e `.mp4`).

## Passos
1. ⏸ **Estilo.** Se existe decisão de identidade visual em `docs/decisoes/`, ela vale sem perguntar. Se não, o gerente mostra `estilos.jpg` e o usuário escolhe pelo número. Estilo que vai se repetir vira decisão, com o bloco copiado inteiro.
2. **Roteirista** — tipo: criação (sobe para opus alto se o conteúdo é factual com risco) — Monta um prompt por imagem com a fórmula [CENA] + [BLOCO DE ESTILO] + [REGRAS FIXAS] de `SKILL.md`, mesma ordem e língua em todos. Personagem recorrente vai por extenso, mais `@nome`. Conteúdo factual com risco: pesquise com fonte antes. — ferramentas: leitura de arquivos, pesquisa web — entrega: `entregas/prompts.md`
3. ⏸ **Aprovar prompts e gasto:** o usuário vê os prompts, a estimativa de créditos e o teto. É o ok específico de gastar.
4. **Gerador** — tipo: execução — **sempre na principal**. Opera o gerador conforme `google-flow.md`, em lotes (padrão 5). Antes de cada lote: confere modelo, proporção e quantidade, e lê o saldo. Depois: lê o saldo, baixa pelo caminho recomendado e grava `entregas/<lote>/NN-slug.jpg`, anotando no `prompts.md`. Para e devolve se aparecer login, CAPTCHA, custo acima do teto, envio duplicado ou ajuste fora do plano. — ferramentas: navegador embutido (escrita), `curl` — entrega: arquivos e saldo antes/depois
5. **Conferente visual** — tipo: conferência — Confere cada imagem pelo checklist de `conferencia.md` e monta a prancha numerada. — ferramentas: leitura de arquivos — entrega: um item por linha, ok ou falhou
6. ⏸ **O usuário escolhe ou manda refazer.** Refazer volta ao passo 4 só para as imagens reprovadas, no máximo 2 vezes; depois disso, pausa para o usuário decidir (aceitar, mudar o prompt ou desistir).
7. **Gerador (vídeo)** — tipo: execução — **sempre na principal**. Só a partir de imagem aprovada ("Animar"). ⏸ antes de cada clipe, com o custo mostrado pelo Flow. — entrega: `entregas/<lote>/NN-slug.mp4`
8. ⏸ **O usuário assiste e ouve cada clipe** e aprova ou manda refazer (volta ao passo 7, no máximo 2 vezes).
