# Montar a operação (só na primeira vez)

Lido pelo `/operador-iniciar` quando não existe `operacao/QUADRO.md`. Você é o **gerente**; use os modelos de `.claude/modelos/documentos.md`.

Uma entrevista curta, em no máximo duas rodadas:

- o que esta operação cuida, para quem e por quê;
- o ambiente: onde fica, como se acessa (sem pedir senha), o que já existe;
- as ferramentas que o usuário já usa ou quer usar;
- limites: custo, o que nunca fazer, o que só ele faz;
- como ele gosta de trabalhar (formato de relatório, nível de detalhe, tom);
- se já tem um jeito fixo de trabalhar para algum tipo de pedido (vira fluxo depois, com `/operador-fluxo`).

Com as respostas:

1. Crie `operacao/docs/{fluxos,pesquisas,decisoes}/`, `operacao/cartoes/_arquivo/` e `operacao/parametros/` (se a operação precisar de um arquivo de parâmetros, é o `parametro.json` de `documentos.md`, e quem preenche é o usuário).
2. Grave `operacao/docs/operacao.md` (com a seção "Configurações" e a linha "Cartões em paralelo: não" ou "sim": pergunte se o usuário quer tocar mais de uma tarefa ao mesmo tempo, cada uma numa sessão; depois ele muda com `/operador-configurar`), `ferramentas.md` (cada ferramenta como `pendente` até ser testada), `.claude/rules/operacao.md` e `operacao/QUADRO.md`.
3. **Levantamento do ambiente.** Proponha um cartão `#001 Levantamento do ambiente`: o `operador-sub-analista` lê o estado atual (servidor, quadro do Trello, perfis) e o gerente grava `ambiente.md`. Com o ok, siga o passo 3 do `SKILL.md` com esse cartão. Se o ambiente ainda não está acessível, crie `ambiente.md` com o que o usuário contou, marcado "segundo o usuário, não verificado".
4. Ferramenta `pendente`: siga "Ferramentas" do `SKILL.md` antes de qualquer cartão que dependa dela.

