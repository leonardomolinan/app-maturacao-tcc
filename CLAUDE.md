# Instruções para agentes

Este repositório é o TCC do Leonardo (Ciência da Computação, UNITRI, 2026/2): um app Flutter que classifica a maturação do tomate pela câmera, offline, e recomenda colher ou esperar. Grupo: **Leonardo Sergi Molina** (executa o projeto com apoio de IA), **Vítor Tetsuya Kazuma** e **Victor José Morais de Lima** (revisam o que o Leonardo enviar, sem calendário fixo). O grupo não tem orientador. Leia [docs/roadmap.md](docs/roadmap.md) antes de qualquer tarefa grande: ele tem as decisões, o cronograma, os riscos e as referências verificadas, e a seção "O que falta fazer" é a lista oficial dos próximos passos. Se estiver começando sem contexto ou num computador novo, leia antes o [CONTINUAR.md](CONTINUAR.md).

Responda em português do Brasil.

## Decisões fechadas (não reabrir sem o Leonardo pedir)

- **Modelo:** classificação de imagem com **YOLO26n-cls**, sem anotar bounding boxes, treinado a partir de dataset público de tomate. Pacote `ultralytics` com versão fixada (`8.4.188`). Imagem de 224 px.
- **Classes:** `verde`, `de_vez`, `maduro`, `passado`, `outro`.
- **Regra de decisão:** verde → esperar; de vez → colher se for para mercado distante, senão esperar; maduro → colher; passado → colher já ou descartar; outro ou confiança baixa → pedir nova foto.
- **Onde roda:** no celular, offline. O app usa o mesmo `.tflite` (LiteRT) no Android e no iOS, pelo `flutter_litert`; o Core ML não é usado.
- **App:** Flutter, Android primeiro. Inferência pelo `flutter_litert` (Apache-2.0), escolhido em 04/11/2026 no lugar do `ultralytics_yolo` (AGPL-3.0): é mais leve e deixa o pré-processamento e as probabilidades no código Dart, testável. Detalhes em `app/README.md`.
- **Backend:** nenhum no MVP. O histórico fica em SQLite no celular.
- **Dataset:** público, com treino do nosso próprio modelo; o modelo pronto do Hugging Face serve só de comparação.
- **Login:** só depois do MVP, se sobrar tempo.
- **Fora do MVP:** a faixa de dias até a colheita e a comparação com um LLM na nuvem. Os dois só entram se o MVP estiver pronto em 22/11/2026; se entrar o LLM, a chave fica num FastAPI pequeno, nunca no app.

## Prazos

Texto completo em 28/11/2026; ENADE em 29/11; protocolo pré-banca e banca nas datas que o professor marcar; protocolo pós-banca (versão final) até quinta, 10/12. Na dúvida entre escopo e prazo, corte escopo.

## Estrutura

- `app/`: aplicativo Flutter. Código em `app/lib/` (domínio e regra de decisão, classificador, SQLite, telas), testes em `app/test/`, modelo em `app/assets/models/`. Projetos nativos em `app/android/` e `app/ios/` (gerados com `flutter create`). Em 04/11/2026, com Flutter 3.47.9: `flutter analyze` sem problemas, `flutter test` passando, `flutter build apk --debug` funcionando e o app abrindo no emulador (sem modelo). Em 16/11/2026, com o modelo treinado em `app/assets/models/best.tflite`, o fluxo pela galeria funcionou no emulador. Em 25/11/2026, o APK de release rodou num Redmi Note 13 5G (Android 15), com a câmera e o modo avião funcionando. Ainda não testados: os outros casos de teste (exclusão, foto sem EXIF, Android 7.0), o tempo de resposta medido e o iOS.
- `ml/`: notebooks de treino e avaliação no Google Colab. Datasets, pesos e execuções não vão para o git (ver `.gitignore`); só o modelo exportado que o app usa fica em `app/assets/models/`.
- `docs/roadmap.md`: plano do TCC, com a situação atual e o que falta fazer.
- `docs/gerar-docx/`: gera o `Roadmap_TCC.docx` a partir do `docs/roadmap.md` (`npm install`, depois `npm run gerar`). O `.docx` é só uma cópia para leitura e fica fora do git.
- `CONTINUAR.md`: como retomar o projeto em outro computador ou sem contexto.
- A monografia (LaTeX, abnTeX2, importada no Overleaf) fica **fora deste repositório**, na pasta `../tcc-overleaf` (repositório privado `leonardomolinan/tcc-overleaf`, clonado ao lado deste), que tem o seu próprio `CLAUDE.md` com as regras do texto, do `.bib` e da compilação. O histórico dela até 04/11/2026 ficou aqui em `docs/tcc/` (commit `5899781`).

## Integridade acadêmica (obrigatório)

- **Nunca invente fonte.** Só cite entradas do `referencias.bib` da monografia, que foram conferidas. Para incluir uma referência nova, abra a fonte (DOI, PDF ou página oficial) antes; o que não der para confirmar fica fora do texto.
- **Nunca simule dado.** Métricas, tabelas, tempos e prints só saem de execução real do modelo ou do app. Enquanto não existirem, use `\resultado` no LaTeX ou `[RESULTADO A PREENCHER]` no resto.
- **Sem plágio:** ideia de outro autor vira paráfrase com citação; citação direta só entre aspas e com página.
- O uso de IA é declarado na seção "Declaração de uso de inteligência artificial" da Metodologia.

## App

- Código, nomes e textos da interface em português do Brasil.
- Nada de classificador falso: sem o `.tflite` em `app/assets/models/`, o app mostra o aviso de modelo ausente. Valores fixos só nos testes.
- Os nomes das classes vêm dos metadados do modelo, nunca de uma ordem fixa no código.
- O limiar de confiança baixa (`limiarConfiancaBaixa` em `app/lib/dominio/regra_decisao.dart`) é 0,47, escolhido em 16/11/2026 com as imagens de validação (notebook `ml/02_limiar_e_paridade.ipynb`); ele só muda com um valor vindo de uma nova validação do modelo.
- Ao mexer no app, rode `flutter analyze` e `flutter test` dentro de `app/`. Se mudar a tabela `analise`, atualize o MER e a tabela do `app/README.md`.

## Termos

**Classe** é o que o modelo devolve; **estádio de maturação** só no contexto agronômico. Termos de computação ficam em inglês (dataset, label, baseline, backend, framework, transfer learning, bounding box). As demais convenções do texto estão no `CLAUDE.md` da monografia.

## Git

Desde 17/11/2026, os commits vão direto na `main`, sem branch nem PR (decisão do Leonardo, depois do merge do PR #2). Commit e push só quando o Leonardo pedir. Ele trabalha em dois computadores (Mac e Windows), então puxe as mudanças (`git pull`) antes de começar. Ao terminar uma tarefa, atualize a "Situação" e o "O que falta fazer" do `docs/roadmap.md`, para o outro computador ver o estado certo.
