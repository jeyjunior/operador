# Google Flow: imagem e vídeo

Verificado em: 2026-11-13 · planos PLUS e Pro · fontes: páginas de ajuda do Google, blogs e testes medidos numa operação real.
Legenda: [OFICIAL] página do Google · [BLOG] terceiros, sem confirmação · [MEDIDO] visto na tela ou no arquivo.

O Flow muda rápido. Crédito, modelo e limite: confira na tela antes de usar e registre a data.

## O que é

- Site: flow.google.com (labs.google/flow redireciona). Estúdio de vídeo, imagem e agente. Idade mínima 18 anos. Brasil suportado. [OFICIAL] https://support.google.com/flow/answer/16353544
- Imagem: Nano Banana Pro é o padrão. Também aparece Nano Banana 2.1. [OFICIAL] https://support.google.com/flow/answer/16353334
- Vídeo: Omni Flash 1.2 e Veo 3.1 Lite. Veo 3.1 Fast/Quality e Omni Flash 1.1 em aposentadoria (até 2026-12-05). [OFICIAL] https://support.google.com/flow/answer/16526234
- **Não há API do Flow.** A API do Gemini gera imagem, mas é cobrada à parte (US$0,03 a 0,24 por imagem) e a assinatura Google AI não a cobre. [OFICIAL] https://aistudio.google.com/docs/pricing
- Termos específicos do Flow sobre automação: não encontrados (labs.google/terms dá 404). A política de IA generativa proíbe sobrecarregar o serviço e contornar proteções contra abuso. Automatizar a interface não é suportado: mantenha volume humano. [OFICIAL] https://policies.google.com/terms/generative-ai/use-policy

## Créditos

- Sem assinatura: 50 créditos/dia, não acumulam. Mensais além disso: AI Plus 200, AI Pro 1.000, Ultra 10.000 ou 25.000. Não acumulam. [OFICIAL]
- Vídeo: Veo 3.1 Lite 4/6/8 s em 720p = 10 créditos. Omni Flash 1.2: 1 crédito/s em 360p, 3/s em 720p. Veo 3.1 Quality 100. [OFICIAL] Medido: Lite 8 s 720p = 10 créditos. [MEDIDO]
- Imagem: a página oficial não lista custo. Medido 0 crédito em PLUS e Pro em 2026-11 (dezenas de imagens), mas isso pode mudar ou haver limite diário (blogs falam em 100/dia no Plus/Pro). [MEDIDO] [BLOG]
- O saldo fica no painel do Flow, com a data do reset. **Leia o saldo antes e depois de cada lote**: é o único controle confiável.

## Como opera

Pelo navegador embutido do Claude desktop (`mcp__Claude_Browser__*`), com a sessão Google que o próprio usuário abre. O Claude não digita senha, não aceita termos e não resolve CAPTCHA. Reservas: Claude in Chrome (exige extensão), app do Gemini.

### Gerar imagem
1. Abrir um projeto (reaproveitar um projeto fixo evita acúmulo; cada "Novo projeto" cria um).
2. Ícone de ajustes do agente: proporção, quantidade (x1 a x4), modelo. Salvar.
3. Digitar o prompt e enviar. Cerca de 25 s por imagem.
4. Esperar e conferir que saiu uma geração só antes de enviar a próxima: envio duplo já gerou a mesma imagem duas vezes.

### Baixar
- **Caminho recomendado:** abrir `/edit/<id>` da imagem, esperar ~5 s e ler o `src` da imagem cheia, que tem a forma `flow-content.google/image/<id>?Expires=...&Signature=...`. Baixar esse endereço com `curl` para `entregas/`. Sem cookie, HTTP 200. [MEDIDO]
- O `src` lido cedo demais vem sem `Signature`: o `curl` dá 403 e grava um XML com nome de `.jpg`. Confira o tipo e as dimensões do arquivo baixado. [MEDIDO]
- As miniaturas da grade (`/asb/`) não servem.
- O botão Download (1K original, 2K aprimorada, 4K com upgrade) grava `.tmp` com nome aleatório na pasta Downloads e às vezes duplicados com o nome do Flow. Use um caminho só. [MEDIDO]

### Vídeo
- Imagem para vídeo: menu da imagem → "Animar" (carrega a imagem no prompt) → texto do movimento. Cerca de 50 s.
- Configurações do agente têm proporção de vídeo (16:9 ou 9:16), quantidade e modelo. **Não há campo de duração:** a duração vai no texto do pedido (pedido 8 s, saiu 7,93 s). [MEDIDO]
- Duração por clipe: Veo 3.1 Lite 4, 6 ou 8 s. Omni Flash 1.2 de 3 a 10 s. Estender clipe só com Omni (desde 2026-11-05). [BLOG]
- O Flow mostra o custo e pede "Aprovar" antes de gerar vídeo. [MEDIDO]
- O MP4 vem com faixa de áudio. Baixar: menu → "Fazer o download" → 720p original (1080p aprimorado).

### Consistência e referências
- Não há preset de estilo: o estilo vai no prompt. Aceita imagem de referência de estilo (ingredients). [OFICIAL]
- Personagens: seção "Personagens" para criar e reutilizar; no prompt, `@nome` (personagem salvo) e `@me` (avatar do usuário). Quadro inicial e final para vídeo. [OFICIAL]
- Geração independente muda a pessoa. Para a mesma pessoa em vários quadros: descrição completa + `@nome`, ou editar a partir da imagem anterior ("same scene, same angle, same lighting; only change: ..."). Ver "Dicas de consistência" em `estilos.md`.

## O que dá errado (medido)

- **A configuração volta sozinha** para outro modelo, 16:9 e x2, e a tela de personagem usa outro modelo e proporção. Confira modelo, proporção e quantidade antes de cada lote.
- **A proporção pedida não é garantida:** pedido 3:4, saiu ~9:16 (768x1376). Não existe 4:5: gere 3:4 ou 9:16 e corte depois. Confira os pixels do arquivo.
- **"Sempre confirmar" foi ignorado** para imagem: o agente gerou direto.
- **Defeitos em ~20% das imagens:** cena dividida em quadros (colagem), cena girada 90°, texto escrito apesar de "no text", personagem trocando roupa ou cabelo, objeto errado. Conte com refação.
- **O login do navegador embutido cai quando o app reinicia.** Quem gera para e devolve ao usuário.
- Janela estreita (~270 px) quebra o leiaute: emule uma janela maior e volte ao normal no fim.
- Rotina sem ninguém no PC exige PC ligado, app aberto e sessão válida; login expirado ou CAPTCHA param tudo.

## Restrições e marca d'água

- Proibido: pessoas famosas, menores identificáveis. O filtro de "parece menor" pode bloquear adultos por engano. [OFICIAL] [BLOG]
- Nome de estúdio ou artista no prompt tende a ser bloqueado: descreva a técnica.
- SynthID (invisível) em tudo; a marca visível tem chave em Configurações e estava desligada. [OFICIAL] [MEDIDO]
- Instagram: o rótulo "AI info" sai por declaração ou por sinais no arquivo (C2PA, SynthID). Marcar o rótulo de IA ao publicar fica com o usuário. [BLOG]
