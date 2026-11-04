# Instruções para agentes

Este repositório é o TCC do Leonardo (Ciência da Computação, UNITRI, 2026/2): um app Flutter que classifica a maturação do tomate pela câmera, offline, e recomenda colher ou esperar. Grupo: **Leonardo Sergi Molina** (executa o projeto com apoio de IA), **Vitor Kazuma** e **Victor José** (revisam o que o Leonardo enviar, sem calendário fixo; sobrenomes ainda a confirmar). Leia [docs/roadmap.md](docs/roadmap.md) antes de qualquer tarefa grande: ele tem as decisões, o cronograma, os riscos e as referências verificadas.

Responda em português do Brasil.

## Decisões fechadas (não reabrir sem o Leonardo pedir)

- **Modelo:** classificação de imagem com **YOLO26n-cls**, sem anotar bounding boxes, treinado a partir de dataset público de tomate. Pacote `ultralytics` com versão fixada (`8.4.188`). Imagem de 224 px.
- **Classes:** `verde`, `de_vez`, `maduro`, `passado`, `outro`.
- **Regra de decisão:** verde → esperar; de vez → colher se for para mercado distante, senão esperar; maduro → colher; passado → colher já ou descartar; outro ou confiança baixa → pedir nova foto.
- **Onde roda:** no celular, offline. Exportar para LiteRT (`.tflite`, Android) e Core ML (iOS).
- **App:** Flutter, Android primeiro (minSdk 24, exigido pelo plugin `ultralytics_yolo`). Inferência pelo plugin `ultralytics_yolo` ou por `flutter_litert`.
- **Backend:** nenhum no MVP. O histórico fica em SQLite no celular.
- **Dataset:** público, com treino do nosso próprio modelo; o modelo pronto do Hugging Face serve só de comparação.
- **Login:** só depois do MVP, se sobrar tempo.
- **Fora do MVP:** a faixa de dias até a colheita e a comparação com um LLM na nuvem. Os dois só entram se o MVP estiver pronto em 22/11/2026; se entrar o LLM, a chave fica num FastAPI pequeno, nunca no app.

## Prazos

Texto completo em 28/11/2026; ENADE em 29/11; postagem até 10/12 (oficial: 12/12). Na dúvida entre escopo e prazo, corte escopo.

## Estrutura

- `app/`: aplicativo Flutter (ainda não criado).
- `ml/`: notebooks de treino e avaliação no Google Colab. Datasets, pesos e execuções não vão para o git (ver `.gitignore`); só o modelo exportado que o app usa fica em `app/assets/models/`.
- `docs/roadmap.md`: plano do TCC.
- `docs/tcc/`: monografia em LaTeX (abnTeX2), importada no Overleaf. É a fonte da verdade do texto.

## Integridade acadêmica (obrigatório)

- **Nunca invente fonte.** Só cite entradas de `docs/tcc/referencias.bib`, que foram conferidas. Para incluir uma referência nova, abra a fonte (DOI, PDF ou página oficial) antes; o que não der para confirmar fica fora do texto.
- **Nunca simule dado.** Métricas, tabelas, tempos e prints só saem de execução real do modelo ou do app. Enquanto não existirem, use `\resultado` no LaTeX ou `[RESULTADO A PREENCHER]` no resto.
- **Sem plágio:** ideia de outro autor vira paráfrase com citação; citação direta só entre aspas e com página.
- O uso de IA é declarado na seção "Declaração de uso de inteligência artificial" da Metodologia.

## Convenções do texto (manual do professor)

- Estrutura: Introdução, Referencial Teórico, Estado da Arte, Metodologia, Resultados e Discussão, Conclusão. Não usar "Desenvolvimento" como título.
- Português acadêmico, impessoal (terceira pessoa ou voz passiva). Metodologia e Resultados no passado.
- Na Introdução, no Referencial e no Estado da Arte, todo parágrafo leva citação. Na Conclusão, em regra, não.
- O Estado da Arte tem 4 a 5 trabalhos, cada um analisado em separado (problema, abordagem, achados, limitações), mais um quadro comparativo e a lacuna explícita.
- A Metodologia precisa dos 4 diagramas UML (casos de uso, classes, sequência, atividades) e do MER, cada um descrito.
- Tabelas e figuras: título acima, fonte abaixo (`\legend{Fonte: ...}`), e toda figura citada no texto.
- Termos: **classe** é o que o modelo devolve; **estádio de maturação** só no contexto agronômico (Referencial). Termos de computação ficam em inglês (dataset, label, baseline, backend, framework, transfer learning, bounding box) e vão em itálico na monografia.
- Citações: o grupo decidiu pela **NBR 10520 de 2023**, com o autor em maiúsculas e minúsculas, como "(Demo, 2014)". O modelo ainda usa `abntex2cite` (estilo `alf`), que segue a versão de 2002 e põe o autor em caixa alta: falta ajustar.
- `\pendente{...}` marca o que falta escrever ou confirmar; não pode sobrar na versão postada.
- Depois de mexer em `docs/tcc/`, compile para conferir: `cd docs/tcc && tectonic --outdir build --keep-logs main.tex`. Verifique erros, `Invalid UTF-8` e avisos do BibTeX em `build/tectonic.out`.
- No `.bib`: proteja siglas e nomes próprios do título com chaves (`{YOLOv8}`, `{Brazilian}`), porque o estilo põe o título em minúsculas. Em campos que vão para maiúsculas (autor, organização), escreva os acentos no formato do LaTeX (`{\'E}`, `{\c c}{\~a}o`). Autor composto ou entidade vai como `{\relax Nome}`. Nunca ponha comentário com `%` dentro de uma entrada.
- O Overleaf gratuito não sincroniza com o GitHub: depois de editar `docs/tcc/`, avise o Leonardo quais arquivos reenviar.

## Git

Trabalhe numa branch por tarefa. Commit e push só quando o Leonardo pedir.
