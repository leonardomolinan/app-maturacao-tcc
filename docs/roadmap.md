## 1. Resumo executivo

### Onde estamos

Vamos fazer um aplicativo em que o produtor rural fotografa o tomate na hora da colheita e recebe a **classe de maturação** e a recomendação **colher** ou **esperar**, sem precisar de internet. Até 03/11, um integrante tinha tentado treinar um YOLO de detecção sem sucesso, e a escrita não tinha começado.

**Situação em 10/11:**
- **App:** pronto e validado (compila, passa nos 58 testes e abre no emulador); só falta o modelo.
- **Notebook de treino:** conferido com os arquivos do dataset e pronto para rodar no Colab.
- **Fotos próprias de teste:** começam nesta semana, seguindo `ml/protocolo-fotos-proprias.md`.
- **Monografia:** em 10/11 foram escritos os rascunhos do Referencial Teórico, do Estado da Arte e da Metodologia, com os 4 diagramas UML e o MER; falta a revisão do Leonardo. Resultados, Conclusão e Resumo dependem do modelo.
- **Gargalo:** o modelo. Sem ele não há Resultados, por isso o treino e as fotos vêm antes de tudo.

### O que precisa ser entregue

- **O TCC inteiro sai neste semestre.** A disciplina N587 é única na matriz atual (não existe TCC I e II).
- **Postagem no Espaço do Aluno até sábado, 12/12/2026**, segundo o calendário oficial. Entregar no prazo é requisito de aprovação (MIA, seção 23).
- As notas de V2 e VT fecham em 10/12, então o professor pode querer o trabalho antes. **Meta interna: texto completo em 28/11.**
- **ENADE em 29/11 (domingo)**: obrigatório para a colação de cada integrante.
- **Formato confirmado:** monografia; grupo de 3 aceito; citações pela NBR 10520 de 2023.

### Decisões tomadas

| # | Decisão | Escolha |
|---|---|---|
| **D1** | Como a IA reconhece | Classificação de imagem com o YOLO26n-cls (sem anotar bounding boxes), treinado a partir de um dataset público |
| **D2** | Cultura | Tomate |
| **D3** | Onde roda | No celular, offline |
| **D4** | O que o app responde | "Colher" ou "esperar", junto com a classe e a confiança. A faixa de dias saiu do MVP por falta de base científica sólida |
| **D5** | Contribuição | App funcionando primeiro. A comparação com um LLM na nuvem só entra se sobrar tempo (decisão em 22/11) |
| **D6** | Stack do app | Flutter, com Android primeiro; o modelo roda no aparelho pelo plugin `flutter_litert` (Apache-2.0) |
| **D7** | Backend | Nenhum no MVP: o histórico fica em SQLite no celular. Um FastAPI pequeno só entra junto com o LLM |
| **D8** | Quem faz | O Leonardo Sergi Molina executa tudo (código, modelo e texto), com apoio de IA declarado; Vitor Kazuma e Victor José revisam o que ele enviar, sem calendário fixo |
| **D9** | Normas | Citações pela NBR 10520 de 2023 |
| **D10** | Depois do MVP | Login pode entrar se sobrar tempo |

### Datas-chave

| Data | O quê |
|---|---|
| **03 a 08/11** | Perguntas ao professor; dataset escolhido; primeiro modelo treinado; repositório e Overleaf criados |
| **09 a 14/11** | Semana de Extensão da Unitri |
| **15/11 e 20/11** | Feriados |
| **22/11** | MVP completo. **Ponto de decisão:** se o MVP estiver pronto e testado, escolhemos um extra; se não, o escopo congela |
| **28/11** | **Texto completo (versão 1)** |
| **29/11** | **ENADE** (todos os integrantes) |
| **30/11 a 05/12** | V2 das outras disciplinas: semana só de revisão do TCC |
| **10/12** | Fechamento das notas de V2 e VT: **limite prático para postar** |
| **12/12 (sábado)** | **Postagem oficial do TCC**; também vencem o relatório de estágio e a aprovação das atividades complementares |
| **23/12** | Fim do semestre |

### O que fazer nesta semana (09 a 15/11)

Já feito:

- **04/11, base do projeto:**
  - dataset escolhido (Unified Tomato Dataset, que já traz os recortes por classe) e classes mapeadas no notebook;
  - repositório leonardomolinan/app-maturacao-tcc criado, com README e instruções para agentes (CLAUDE.md);
  - projeto abnTeX2 pronto para importar no Overleaf, com a Introdução em rascunho. Ele fica numa pasta própria, fora do repositório (`~/www/unitri/tcc-overleaf`);
  - notebook de treino pronto para o Colab.
- **04/11, app:** Flutter 3.47.9 e Android SDK instalados no Mac. O app foi validado: `flutter analyze` sem problemas, 58 testes passando, APK de debug gerado e app abrindo no emulador (sem modelo).
- **09/11:**
  - notebook conferido com os arquivos do dataset (pastas e classes dos dois zips);
  - protocolo das fotos próprias escrito (`ml/protocolo-fotos-proprias.md`);
  - app enviado ao GitHub, na branch `mvp/app-flutter`.

Falta nesta semana:

- [ ] Rodar o notebook no Colab e trazer o `.tflite` e as métricas (`metricas_teste.json`, `matriz_confusao_teste.png`, `ambiente.json` e `results.csv`). O passo a passo está em `ml/README.md`.
- [ ] Comprar uns 20 tomates em estádios variados e fotografar todo dia até 22/11, seguindo o protocolo.
- [ ] Colocar o `.tflite` no app e testar no emulador e num celular. Conferir se o app dá a mesma classe que o Python nas mesmas fotos.
- [ ] Levar ao professor as 2 perguntas que restam (Anexo D).
- [ ] Importar o projeto no Overleaf.
- [ ] Revisar os rascunhos da monografia escritos em 10/11.

## 2. Entregáveis e prazos da disciplina (2026/2)

O Manual de TCC não traz datas nem entregas parciais. A busca nos documentos oficiais da Unitri ([calendário 2026/2](https://unitri.edu.br/wp-content/uploads/2026/09/2026-2-l-UNITRI-l-Calendario-Letivo-l-21_08_2026-OFICIAL.pdf), [MIA 2026.1](https://unitri.edu.br/wp-content/uploads/2025/12/UNITRI-l-MIA-l-2026.1-l-17112025.pdf) e [matriz 102AN](http://gradecurricular.unitri.edu.br/12_102AN.pdf)) encontrou o seguinte:

| Item | O que encontramos | Status |
|---|---|---|
| **Disciplina** | N587 · Trabalho de Conclusão de Curso em Ciência da Computação: 80 h/a, 8º período, sem pré-requisito. Não é dividida em TCC I e II na matriz 102AN (a matriz antiga, 102DS, tinha Trabalho de Graduação I e II). | Confirmado |
| **Entregável principal** | O TCC (monografia, artigo ou projeto, conforme o PPC), enviado pelo Espaço do Aluno para avaliação do professor. Entregar no prazo é requisito de aprovação. | Confirmado (MIA, seção 23) |
| **Prazo de postagem** | Sábado, 12/12/2026. O calendário não informa até que horas o sistema aceita. | Confirmado (calendário de 21/08/2026) |
| **Prazo interno** | Provavelmente antes: as notas de V2 e VT fecham em 10/12. | Inferido |
| **Grupo e formato** | Grupo de 3 aceito; formato monografia. | Confirmado pelo professor |
| **Banca, apresentação, páginas, critério de nota** | Nada publicado. Pelo MIA, cada colegiado divulga as regras de avaliação no início do semestre, e o plano de ensino fica no Espaço do Aluno. | Não encontrado |
| **Formato e normas** | Overleaf, ABNT (NBR 14724, 10520 de 2023 e 6023), 4 diagramas UML e o MER (seção 3). | Confirmado (manual; a versão de 2023 da NBR 10520 foi decidida pelo grupo) |
| **Publicação** | O TCC vai para o repositório interno do Espaço do Aluno e do Professor; não há repositório público. | Confirmado (MIA, seção 22) |
| **Ética** | O manual diz que não há comitê de ética. Seguimos o manual: nada de pesquisa envolvendo pessoas. | Decidido |
| **Formatura (individual)** | Aprovação em tudo (TCC, estágio, atividades complementares) e situação regular no ENADE. Vale para cada integrante, mesmo com TCC em grupo. | Confirmado (MIA, seções 20, 21 e 25) |

> [!warn] **Ainda sem resposta: perguntar ao professor nesta semana**
>
> Há entregas parciais ou nota de V1 ou V2 ligada ao TCC? Haverá banca? O que postar além do PDF? Cada integrante posta, ou só um? A lista está no Anexo D.

**Não planejem com “TCC II no semestre que vem”.** Na matriz atual, isso só aconteceria com reprovação e nova matrícula, o que atrasaria a formatura em cerca de 6 meses.

## 3. O que o Manual de TCC exige

Resumo prático do **Manual de Elaboração do Trabalho de Conclusão de Curso** enviado pelo professor. Usem como checklist de revisão antes de cada entrega.

| Item | O que o manual pede | Como aplicar no nosso TCC |
|---|---|---|
| **Tipo de trabalho** | Teórico (só individual) ou Prático (pode ser em grupo). | Prático (aplicativo com IA). É o tipo que permite o trio. |
| **Ferramenta de escrita** | Overleaf; as referências saem automaticamente das citações. | Projeto no Overleaf com modelo ABNT (abnTeX2) e um arquivo .bib único. |
| **Estrutura** | Pré-textuais (capa, folha de rosto, resumo, sumário), textuais e pós-textuais (referências, apêndices). | 1 Introdução, 2 Referencial Teórico, 3 Estado da Arte, 4 Metodologia, 5 Resultados e Discussão, 6 Conclusão, Referências. |
| **Introdução** | Escrita por último: contexto, problema, justificativa, objetivos, metodologia breve, hipóteses, estrutura do trabalho. Todos os parágrafos referenciados. | Rascunhar na semana 1 para alinhar o grupo; reescrever no final. |
| **Referencial Teórico** | Livros, artigos e teses; nada de apostilas, notas de aula, Wikipédia ou blogs. Fichamento antes de escrever. Citações pela NBR 10520. Diálogo entre autores. | Maturação de frutos, visão computacional, CNN, YOLO e/ou LLMs multimodais, métricas, computação móvel. **Decidido:** NBR 10520 de 2023, que cita “(Demo, 2014)” em vez de “(DEMO, 2014)”, a forma de 2002 usada nos exemplos do manual. O modelo LaTeX ainda segue 2002 e precisa de ajuste. |
| **Estado da Arte** | 4 a 5 trabalhos dos últimos 5 a 10 anos; análise individual (problema, abordagem, achados, falhas); comparação; tabela comparativa; como o TCC se diferencia. | Usar as referências verificadas do Anexo C; o Leonardo ficha os trabalhos, e os colegas conferem quando ele enviar. |
| **Metodologia (prático)** | Ferramentas usadas, critérios de escolha e por que não outras. 4 diagramas UML (Caso de Uso, Classes, Sequência, Atividades) e MER se houver banco, cada um descrito. Questionário opcional. Texto no passado e na voz passiva. Definir o público-alvo. | Justificar cada escolha (modelo de IA, framework do app, backend, banco). |
| **Ética** | Segundo o manual, a universidade não tem comitê de ética, então devem-se evitar pesquisas que envolvam o bem-estar de seres humanos. | Seguimos o manual: nenhuma pesquisa envolvendo pessoas; no máximo um questionário de usabilidade simples e anônimo. |
| **Resultados e Discussão** | Não usar “Desenvolvimento” como título. Apresentar o software com prints. Tabelas com título acima e fonte abaixo; toda figura citada no texto e com fonte. Comparar com o Estado da Arte. Ser honesto sobre dificuldades. | Métricas do modelo, prints de todas as telas, tempo de resposta, resultado do questionário. |
| **Conclusão** | Responder ao problema; dizer se os objetivos e hipóteses foram atingidos; contribuições, limitações e trabalhos futuros. Sem dados novos e, em regra, sem citações. | Fechar em sintonia com o que a Introdução prometeu. |
| **Referências** | NBR 6023:2018; só o que foi citado; ordem alfabética. | Gerenciar no Zotero e exportar BibTeX para o Overleaf. |

> [!alert] **Frase do manual para não esquecer**
>
> “Se o código funciona mas a documentação (diagramas) está errada, o trabalho pode ser reprovado.” Reservem tempo de verdade para UML, MER e revisão cruzada.

> [!info] **O que o manual NÃO diz**
>
> O manual não traz datas, entregas parciais nem regras de banca. Isso foi pesquisado à parte (seção 2); o que falta está no Anexo D.

## 4. YOLO e alternativas: o que a pesquisa mostrou

### 4.1 O que é o YOLO

YOLO (_You Only Look Once_, pronuncia-se “iôlo”) é uma família de modelos de visão computacional para **detecção de objetos**. O modelo olha a imagem uma vez e devolve, ao mesmo tempo, uma caixa (bounding box) em volta de cada objeto e a classe de cada um (REDMON et al., 2016). Hoje é uma linhagem com vários autores. A mais usada é a da empresa Ultralytics, que mantém o pacote Python `ultralytics` com o YOLOv8, o YOLO11 e o **YOLO26**: lançado em janeiro de 2026, é o que a documentação indica para projetos novos. O mesmo pacote também faz **classificação de imagens**, segmentação e outras tarefas.

### 4.2 Por que classificação e não detecção

É a técnica mais usada na literatura sobre maturação de frutos: há trabalhos com café, morango e tomate, com mAP entre cerca de 77% e 99%. Gera métricas fáceis de defender e roda sem internet no celular. O que costuma travar estudantes é a **detecção**: é preciso anotar milhares de bounding boxes (cerca de 35 s por caixa, ou ~29 h só para 3.000 caixas), e o modelo erra quando as fotos de uso são diferentes das do treino.

> [!tip] **O que muda na prática**
>
> - Com **um fruto enquadrado** na foto, basta **classificar** a imagem. Rotular é só separar fotos em pastas por classe, e o treino leva minutos.
>
> - Começar de **dataset público** e de pesos pré-treinados (transfer learning). Anotar do zero não cabe no prazo.
>
> - Classes finas (6) são difíceis até para os melhores modelos; 4 ou 5 classes funcionam bem melhor. Um YOLO26s-cls público de tomate, por exemplo, teve 88,7% de acurácia em 3 classes e 80,8% em 4.
>
> - Nenhum modelo de visão prevê **tempo**: por isso o MVP responde só "colher" ou "esperar" (seção 4.6).

### 4.3 Comparativo das opções

Esforço em pessoas-semana (40 h), sem contar a escrita. As estimativas são da pesquisa e servem para comparar, não como promessa.

| Caminho | Treino? | Sem internet? | Esforço | Custo | Avaliação para o TCC |
|---|---|---|---|---|---|
| **YOLO detectando com anotação própria** (caminho anterior) | Sim, com caixas | Sim | Alto (7 a 10) | Zero | Valor alto, mas é o maior risco para 12/12. |
| **YOLO26n-cls em dataset público de tomate** (escolhido) | Sim, leve (pastas) | Sim | Médio (2,5 a 3,5) | Zero | Melhor equilíbrio: métricas claras, roda offline e aproveita o que já se aprendeu de YOLO. |
| **YOLO detectando em dataset público já no formato YOLO** | Sim, sem anotar | Sim | Médio (3,5 a 5) | Zero | Bom se quiséssemos contar frutos na foto; as classes intermediárias são as mais difíceis. |
| **LLM multimodal na nuvem** (Gemini, Claude, GPT) via backend | Não | Não | Baixo (dias) | Menos de US$ 1 por 1.000 fotos nos modelos mais baratos | Extra opcional (decisão em 22/11) e plano B de emergência. Cerca de 80% em frutas comuns com boa foto; pior em campo. |
| **Modelo pronto** (Hugging Face, Roboflow Universe) | Não | Sim, baixando os pesos | Baixo | Zero | Baseline. Os modelos públicos de tomate foram treinados com fotos de esteira. |
| **Visão clássica por cor** (% de vermelho em HSV ou Lab) | Não (só calibrar) | Sim | Baixo a médio | Zero | Baseline explicável, ligado a PDI; sensível à luz e ao fundo. |
| **Teachable Machine** (Google) | Sim, no navegador | Sim (exporta TFLite) | Muito baixo (1 dia) | Zero | Prova de conceito, não contribuição. |
| **IA multimodal no próprio celular** (Gemma 4, Gemini Nano, Apple) | Não | Sim | Alto (APIs em alfa) | Zero | Trabalho futuro. |

### 4.4 Decisão

O MVP tem três partes, nesta ordem de prioridade:

1. **Núcleo offline:** app Flutter com YOLO26n-cls (classes verde, de vez, maduro, passado e outro), treinado a partir de dataset público de tomate, exportado para LiteRT (.tflite) e lido no app pelo plugin `flutter_litert` (Apache-2.0), o mesmo arquivo no Android e no iPhone.
2. **Regra de decisão:** cada classe vira "colher" ou "esperar" por uma regra fixa (seção 5.1), com aviso quando a confiança for baixa.
3. **Avaliação:** conjunto de teste com fotos próprias de tomates fotografados dia a dia. Medir acurácia, F1 por classe, matriz de confusão, tempo de resposta no celular e funcionamento em modo avião.

> [!info] **Extras: ponto de decisão em 22/11**
>
> Se o MVP estiver pronto e testado em 22/11, escolhemos **um** extra: (a) comparar o modelo do celular com um LLM multimodal na nuvem no mesmo conjunto de teste, o que exige uma API pequena em FastAPI para proteger a chave; ou (b) estimar uma faixa de dias até a colheita com a tabela do Anexo B. Se o MVP não estiver pronto, os dois viram trabalhos futuros.

### 4.5 Como destravar o treino (passo a passo)

Tudo isto já está no notebook `ml/01_treino_classificador.ipynb` do repositório; os passos abaixo explicam o que ele faz.

1. Fixar a versão do pacote no Colab: `pip install ultralytics==8.4.188` (versão usada nos modelos oficiais do plugin Flutter). Registrar a versão na Metodologia.
2. Montar o dataset de classificação: pastas `train/`, `val/` e `test/`, com uma subpasta por classe (`verde/`, `de_vez/`, `maduro/`, `passado/`, `outro/`). O dataset público já traz os recortes de 160×160 (`tomato_ripeness_crops.zip`) separados assim; a classe `outro` sai de recortes de fundo das imagens de detecção.
3. Treinar a partir dos pesos pré-treinados: `YOLO('yolo26n-cls.pt').train(data='caminho/do/dataset', epochs=50, imgsz=224)`.
4. Salvar no Google Drive com `save_period`. Se o Colab cair (as sessões gratuitas duram no máximo 12 h), retomar com `resume=True` a partir do `last.pt`.
5. Validar com `val()` e olhar a matriz de confusão. Separar treino e teste por fruto ou lote, nunca por foto, para não vazar informação.
6. Exportar com `export(format='litert')` (Android) e `export(format='coreml')` (iPhone), usando o mesmo tamanho de imagem do treino.
7. Testar cedo com fotos próprias: o maior risco é a diferença entre as fotos do dataset (estufa, esteira) e as de campo.

> [!warn] **Erros que mais travam quem treina YOLO pela primeira vez**
>
> Caminhos errados nas pastas; classe intermediária com poucas fotos; versões de bibliotecas misturadas; tamanho de imagem diferente entre treino, exportação e app; falta de memória (reduzir `batch` ou `imgsz`); treino que trava ao iniciar (usar `workers=0`).

Atalhos: o [Unified Tomato Dataset](https://huggingface.co/datasets/ParsaVictor/tomato-ripeness-detection) (8.497 imagens, licença CC BY 4.0, classes raw, half_ripe, ripe e rotten, que se mapeiam para verde, de vez, maduro e passado) e um [modelo YOLO26 de tomate já treinado](https://huggingface.co/ParsaVictor/tomato-ripeness-yolo26) (AGPL-3.0), que serve de baseline no primeiro dia. Muitas dessas fotos são de esteira, por isso o teste com fotos próprias é obrigatório.

### 4.6 Por que o MVP não estima dias

Nenhum modelo de visão prevê tempo. Uma estimativa de dias dependeria de uma tabela agronômica, e os dados encontrados (CIPTANINGTYAS et al., 2022) são de cultivares japonesas amadurecendo **depois de colhidas**, em temperatura controlada. Isso não basta para defender um número para o fruto no pé, no calor do Triângulo. Por isso o MVP responde só "colher" ou "esperar". A faixa de dias fica como extra possível ou trabalho futuro (Anexo B).

## 5. Escopo do MVP, problema e objetivos

### 5.1 Escopo

| Item | Proposta |
|---|---|
| **Cultura** | Tomate de mesa. As outras culturas ficam como trabalhos futuros. |
| **Classes do modelo** | Verde · de vez · maduro · passado, mais “outro / foto inadequada”. |
| **Regra de decisão** | Verde → **esperar**. De vez → **colher** se for para mercado distante (o tomate continua amadurecendo depois de colhido); senão, **esperar**. Maduro → **colher**. Passado → **colher já ou descartar**. Outro ou confiança baixa → pedir nova foto. |
| **Plataforma** | Flutter, Android primeiro: o Android tem 73,8% do tráfego web móvel no Brasil (StatCounter, out/2026). iPhone, se der tempo. |
| **Funcionamento** | Offline: tudo roda no celular. |
| **Saída** | Classe, confiança e a recomendação "colher" ou "esperar". |
| **Público-alvo** | Produtores de tomate, sobretudo pequenos e familiares: 82,2% dos estabelecimentos de tomate estaqueado são de agricultura familiar (IBGE, Censo Agro 2017). |
| **Fora do escopo** | Contagem de frutos, várias culturas, sincronização na nuvem, backend e previsão de dias (extra possível). Login pode entrar depois do MVP, se sobrar tempo. |

### 5.2 Funcionalidades

| Prioridade | Funcionalidade |
|---|---|
| **MVP** | Tirar ou escolher foto, com guia de enquadramento |
| **MVP** | Classificar a foto no aparelho, sem internet |
| **MVP** | Mostrar a classe, a confiança e a recomendação "colher" ou "esperar" |
| **MVP** | Avisar quando a foto estiver ruim ou a confiança for baixa |
| **MVP** | Guardar o histórico das análises no aparelho (SQLite) |
| **Extra (22/11)** | Comparação com um LLM multimodal na nuvem, via FastAPI |
| **Extra (22/11)** | Faixa estimada de dias até a colheita |
| **Depois do MVP** | Login, se sobrar tempo |

### 5.3 Problema, objetivos e hipótese (rascunho)

**Pergunta de pesquisa:** em que medida um classificador leve, executado no próprio celular e sem conexão com a internet, consegue indicar se o tomate está no ponto de colheita a partir de uma foto tirada no campo? O manual pede uma pergunta que não se responda só com sim ou não.

**Objetivo geral:** desenvolver um aplicativo móvel que, a partir de uma foto, classifique a maturação do tomate e recomende colher ou esperar, funcionando sem conexão com a internet.

**Objetivos específicos:**

1. Definir as classes de maturação a partir de escalas de cor de referência (USDA, Portaria 553/1995 e PBMH/CEAGESP).
2. Treinar e avaliar um classificador leve (YOLO26n-cls) com dataset público e fotos próprias de teste.
3. Desenvolver o aplicativo em Flutter com inferência no aparelho, regra de decisão e histórico.
4. Avaliar o desempenho no celular: acurácia, F1 por classe, tempo de resposta e funcionamento offline.

**Hipótese:** o classificador embarcado atinge acurácia de pelo menos **[META A DEFINIR COM O PROFESSOR]** no conjunto de teste com fotos próprias, responde em poucos segundos e funciona sem internet.

**O que nos diferencia:** o antecedente mais próximo é o trabalho da UFU com café: um artigo com o modelo (MobileNet, 93% de acurácia na decisão "colher" ou "não colher") e uma dissertação do mesmo grupo com protótipos de app Android com TensorFlow Lite. Nosso trabalho se diferencia pela cultura (tomate), pelo modelo recente (YOLO26), pela avaliação com fotos próprias de campo e pelo app em Flutter (Android e iOS). Se um dos extras de 22/11 entrar, ele reforça a contribuição.

> [!info] Rascunho para validar com o professor. O manual pede a Introdução escrita por último, então este texto vai mudar.

## 6. Arquitetura (MVP sem backend)

| Componente | Tecnologia | Por quê |
|---|---|---|
| **App móvel** | Flutter (Dart), Android primeiro | Um código para Android e iOS, sem código nativo. |
| **Modelo no aparelho** | YOLO26n-cls exportado para LiteRT (.tflite) e Core ML | 2,8 milhões de parâmetros; roda offline; mesma API do treino. |
| **Inferência** | `flutter_litert` (Apache-2.0), escolhido em 04/11 | Plugin leve: o pré-processamento e as probabilidades ficam no código Dart, onde dá para testar e descrever na Metodologia. Os nomes das classes vêm dos metadados do modelo. O `ultralytics_yolo` (AGPL-3.0) foi deixado de lado porque traz a câmera junto e esconde esses passos. |
| **Regra de decisão** | Tabela classe → recomendação, em código Dart com testes unitários | Funciona offline e é fácil de descrever no texto. |
| **Histórico** | SQLite no aparelho | Funciona offline e gera o MER. |
| **Treino e avaliação** | Google Colab, com notebooks versionados no GitHub | GPU grátis e experimento reprodutível. |

### 6.1 Fluxo principal

1. O produtor abre o app e fotografa o tomate (ou escolhe da galeria).
2. O app reduz a foto e remove os dados de localização (EXIF).
3. O classificador local devolve a classe e a confiança.
4. Se a confiança for baixa ou a classe for "outro", o app pede nova foto com dicas de luz, distância e fundo.
5. A regra de decisão transforma a classe em "colher" ou "esperar".
6. O app mostra o resultado e salva no histórico.

### 6.2 O que vira diagrama (exigência do manual)

| Diagrama | Conteúdo sugerido |
|---|---|
| **Casos de uso** | Fotografar fruto; analisar maturação; ver recomendação; consultar histórico. Ator: produtor. |
| **Classes** | Analise, Cultura, ClasseMaturacao, RegraDecisao, ClassificadorLocal, RepositorioAnalises. |
| **Sequência** | Foto → pré-processamento → classificador → regra de decisão → tela de resultado → histórico. |
| **Atividades** | Fluxo com decisões: a foto está boa? a confiança é suficiente? a recomendação é colher ou esperar? |
| **MER** | Cultura 1:N ClasseMaturacao 1:1 RegraDecisao. Cada Analise aponta para uma ClasseMaturacao e guarda data, caminho da foto no aparelho, confiança e versão do modelo. |

### 6.3 Se sobrar tempo (extra)

Uma API pequena em Python + FastAPI, só para chamar um LLM multimodal (ex.: Gemini Flash-Lite ou Claude Haiku) sem expor a chave no app, com saída JSON restrita às classes do modelo. Hospedagem gratuita no Render, que “dorme” após 15 min sem uso. Em cada experimento, registrar o ID exato do modelo e a data.

## 7. Divisão de papéis

**O Leonardo executa** o projeto (código, modelo e texto), com apoio de IA de uso declarado. **Vitor Kazuma e Victor José revisam** o que ele enviar, quando ele achar pertinente; não há calendário fixo de revisão. Os três precisam dominar o conteúdo para a apresentação.

| Quem | O quê |
|---|---|
| **Leonardo Sergi Molina** (com apoio de IA) | Dataset, treino e avaliação do modelo; app Flutter; requisitos, UML e MER; escrita de todos os capítulos; dono do projeto no Overleaf; cronograma. |
| **Vitor Kazuma** | Revisa os trechos e versões que o Leonardo enviar; testa o APK no próprio celular. |
| **Victor José** | Revisa os trechos e versões que o Leonardo enviar; testa o APK no próprio celular. |

## 8. Cronograma semana a semana

Considera a postagem oficial em 12/12 e a meta interna de texto completo em 28/11. Cada semana termina num marco. Se um marco atrasar, corta-se escopo, nunca a escrita. Os colegas revisam quando o Leonardo enviar algo, sem data fixa.

| Semana | Marco no fim da semana | Código e modelo | Texto (Overleaf) |
|---|---|---|---|
| **S1** · 03 a 08/11 | Escopo fechado; app validado; Overleaf criado | Dataset escolhido e classes mapeadas (feito); notebook pronto (feito); app compilado, com 58 testes passando e aberto no emulador (feito em 04/11). O 1º treino passou para a S2 | Projeto abnTeX2 (feito; falta importar); Introdução em rascunho (feito); requisitos (feito) |
| **S2** · 09 a 15/11 (Semana de Extensão; feriado em 15/11) | 1º modelo treinado e rodando no app | Treino no Colab; exportar para LiteRT; integrar no app; testar no emulador e num celular; conferir se o app e o Python dão a mesma classe; fotos diárias de teste a partir de 09/11 | Rascunhos do Referencial Teórico, do Estado da Arte e da Metodologia, com os diagramas UML e o MER; revisão do Leonardo |
| **S3** · 16 a 22/11 (feriado em 20/11) | MVP completo; **ponto de decisão dos extras** | Notebook 02 (avaliação nas fotos próprias); limiar de confiança baixa definido na validação; testes em 2 ou 3 celulares e em modo avião; APK para os colegas | Metodologia final, com os dados reais do treino e os diagramas conferidos com o código; Justificativa da Introdução |
| **S4** · 23 a 29/11 | **Texto completo em 28/11**; **ENADE em 29/11** | Revisão de design do app (alto contraste e botões grandes, RNF05) entre 23 e 25/11; prints depois dela; métricas finais e matriz de confusão; o extra só se aprovado em 22/11 | Resultados e Discussão; Conclusão; Introdução final; Resumo e Abstract |
| **S5** · 30/11 a 06/12 (V2 das outras disciplinas) | Versão revisada pelo professor e pelos colegas | Ajustes só se necessário; vídeo de demonstração | Revisão ABNT (citações, figuras, tabelas e referências); README do repositório |
| **S6** · 07 a 12/12 | **Postagem até 10/12** (oficial: sábado, 12/12) | Congelar modelo, código e APK | PDF final; postagem no Espaço do Aluno |

> [!tip] **Regra de ouro do cronograma**
>
> Toda parte implementada gera, na mesma semana, o trecho de texto correspondente. Assim, em 28/11 o texto está completo sem uma maratona de escrita no fim. A exceção são os prints das telas: o design do app fica para o fim, então os prints saem depois da revisão de design (23 a 25/11), para não precisarem ser refeitos.

## 9. Backlog inicial por frente

Lista generalista. Vale transformar cada item em cartão no quadro Kanban e quebrar em tarefas menores quando a frente começar.

### Escrita (Overleaf)

- [x] Criar o projeto abnTeX2 com um arquivo por capítulo e o .bib compartilhado.
- [ ] Uma página com título provisório, problema, objetivos e hipótese; validar com o professor.
- [ ] Fichar 4 a 5 trabalhos correlatos e montar a tabela comparativa (rascunho em 10/11, com os números conferidos nos textos completos; falta revisar).
- [ ] Referencial Teórico, seções 2.1 a 2.7 (rascunho em 10/11; falta revisar).
- [ ] Metodologia: ferramentas e justificativas, dados, requisitos, UML, MER, plano de testes e a nota de uso de IA (rascunho em 10/11, com os diagramas em TikZ; faltam os dados do treino e das fotos próprias).
- [ ] Resultados e Discussão: métricas, prints, testes e comparação com os correlatos.
- [ ] Conclusão, Introdução final, Resumo e Abstract.
- [ ] Revisão ABNT: citações, figuras, tabelas e referências.

### Design e UX

Fica para o fim, quando o app estiver funcionando (23 a 25/11), e antes dos prints da monografia. O requisito RNF05 (interface legível sob sol forte, com alto contraste e botões grandes) sai daqui.

- [x] Fluxo: abrir o app → tirar a foto → conferir o recorte → resultado → histórico (já implementado).
- [ ] Revisão visual das telas (início, conferência da foto, resultado, histórico).
- [ ] Uso no campo: alto contraste para sol forte, botões grandes, pouco texto, ícones claros.

### App (Flutter)

Validado em 04/11 com Flutter 3.47.9: `flutter analyze` sem problemas, 58 testes passando, APK de debug gerado e app abrindo no emulador. Falta o modelo. Dos erros, já estão tratadas a classe "outro" e a confiança baixa; a foto escura ou tremida ficou fora por enquanto.

- [x] Criar o projeto Flutter (Android primeiro), navegação e tema.
- [x] Câmera e galeria, com guia de enquadramento: ilustração na tela inicial e conferência do quadrado analisado. Uma moldura sobre a câmera ao vivo exigiria o plugin `camera`.
- [ ] Integração com o modelo no aparelho (plugin `flutter_litert`): código pronto e testado sem modelo; falta o `.tflite`.
- [x] Tela de resultado: classe, confiança e recomendação, com a pergunta do destino para a classe "de vez".
- [x] Regra de decisão (código Dart com testes) e histórico em SQLite.
- [ ] Erros tratados: classe "outro" e confiança baixa (feito); foto escura ou tremida (fora por enquanto).
- [ ] Gerar o APK para os testes: o de debug já sai; falta gerar com o modelo dentro.

### IA e Dados

- [x] Escolher o dataset público de tomate (Anexo C), mapear as classes e conferir a licença (CC BY 4.0). O download é feito pelo notebook, no Colab.
- [ ] Montar o conjunto de teste próprio seguindo `ml/protocolo-fotos-proprias.md`: uns 20 tomates em estádios variados e numerados, 2 fotos por tomate por dia até 22/11, e o rótulo anotado antes de ver a resposta do modelo.
- [ ] Ter um baseline na semana 1 (modelo pronto do Hugging Face) para já ter números.
- [ ] Treinar o YOLO26n-cls (versão do `ultralytics` fixada) e guardar a configuração no repositório.
- [ ] Avaliar: acurácia, precisão, recall, F1 por classe, matriz de confusão e tempo de inferência.
- [ ] Exportar para o celular (LiteRT e Core ML).
- [ ] Registrar cada passo; vira a seção de dados e treinamento da Metodologia.

### Testes e avaliação

- [ ] Casos de teste derivados dos requisitos.
- [ ] Testes no aparelho (um Android intermediário) e em modo avião.
- [ ] Medir o tempo de resposta em 2 ou 3 celulares.
- [ ] Questionário de usabilidade simples e anônimo (opcional, permitido pelo manual).

### Extras (só se aprovados em 22/11)

- [ ] Comparação com LLM: API em FastAPI, prompt com saída JSON restrita às classes, mesmo conjunto de teste, respostas brutas salvas.
- [ ] Faixa de dias: tabela do Anexo B dentro do app, sempre mostrada como faixa e com a ressalva.
- [ ] Login, só depois do MVP pronto e se sobrar tempo.

### Apresentação

- [ ] Slides: problema, solução, demonstração, resultados, conclusão.
- [ ] Vídeo curto da demonstração (reserva caso a demo ao vivo falhe).
- [ ] Ensaio cronometrado com os três.

## 10. Estrutura sugerida do texto

Esqueleto de capítulos já adaptado ao projeto, seguindo a ordem do manual (NBR 14724). Os números de seção são só sugestão.

| Capítulo | Seções sugeridas |
|---|---|
| **Pré-textuais** | Capa, folha de rosto, resumo e palavras-chave, abstract, listas de figuras, tabelas e siglas, sumário. |
| **1 Introdução** | 1.1 Contexto: agricultura brasileira, perdas pós-colheita, importância do ponto de colheita · 1.2 Problema de pesquisa · 1.3 Justificativa · 1.4 Objetivo geral e específicos · 1.5 Metodologia (resumo) · 1.6 Hipótese · 1.7 Estrutura do trabalho |
| **2 Referencial Teórico** | 2.1 Maturação do tomate (estádios de maturação, frutos climatéricos, escalas de cor, ponto de colheita) · 2.2 Processamento digital de imagens e visão computacional · 2.3 Deep learning e redes neurais convolucionais · 2.4 Classificação de imagens e a família YOLO · 2.5 Transfer learning · 2.6 Métricas de avaliação · 2.7 Computação móvel e inferência no aparelho |
| **3 Estado da Arte** | 3.1 a 3.5: um trabalho correlato por seção (problema, abordagem, resultados, limitações) · 3.6 Quadro comparativo · 3.7 Posicionamento deste trabalho |
| **4 Metodologia** | 4.1 Classificação da pesquisa (aplicada, quantitativa, experimental) · 4.2 Público-alvo · 4.3 Etapas (fluxograma) · 4.4 Ferramentas e justificativas · 4.5 Dataset e classes · 4.6 Treinamento do modelo · 4.7 Requisitos funcionais e não funcionais · 4.8 Diagramas UML · 4.9 MER · 4.10 Plano de testes e de avaliação · 4.11 Declaração de uso de IA |
| **5 Resultados e Discussão** | 5.1 Desempenho do modelo (tabelas, matriz de confusão) · 5.2 O aplicativo, tela a tela · 5.3 Testes funcionais e de desempenho (tempo de resposta, uso sem internet) · 5.4 Comparação com os trabalhos correlatos · 5.5 Dificuldades e limitações |
| **6 Conclusão** | Resposta ao problema, objetivos e hipótese, contribuições, limitações e trabalhos futuros (faixa de dias, comparação com LLM e outras culturas, se não entrarem). |
| **Pós-textuais** | Referências (NBR 6023) · Apêndices: regra de decisão usada pelo app, link do repositório. |

### Convenção de termos

- Citações pela **NBR 10520 de 2023** (decidido em 04/11).
- **Classe** é o que o modelo devolve (verde, de vez, maduro, passado, outro). **Estádio de maturação** é o termo técnico da agronomia (Embrapa) e só aparece no Referencial Teórico, quando o assunto é a fisiologia do fruto.
- Termos de computação ficam em inglês quando esse é o uso na área, em itálico na monografia: dataset, label, baseline, backend, endpoint, deploy, fine-tuning, transfer learning, framework, prompt, bounding box.

## 11. Ferramentas e organização do grupo

| Necessidade | Ferramenta | Observação |
|---|---|---|
| **Escrita** | Overleaf + modelo abnTeX2 | Exigido pelo manual. O Leonardo é o dono do projeto; os arquivos .tex e o .bib ficam na pasta tcc-overleaf, fora do repositório do app, compilam localmente com o Tectonic e são reenviados ao Overleaf. O plano gratuito aceita só 1 colaborador: os revisores leem o PDF, ou um deles entra como colaborador. |
| **Referências** | Zotero (com extensão do navegador e Better BibTeX) | Exporta o .bib para o Overleaf; evita referência errada. |
| **Código** | GitHub: leonardomolinan/app-maturacao-tcc (privado), com pastas app/, ml/ e docs/ | README e instruções para agentes (CLAUDE.md); o link vai para o apêndice. |
| **Tarefas** | GitHub Projects (Kanban) | Colunas: A fazer / Fazendo / Em revisão / Feito. |
| **Design** | Figma ou rascunho no papel | Wireframes simples; os prints do app entram no TCC. |
| **UML** | draw.io (diagrams.net) ou PlantUML | Os 4 diagramas obrigatórios. |
| **MER** | brModelo ou dbdiagram.io | Tabelas do SQLite do app. |
| **IA** | Google Colab ou Kaggle Notebooks | Classificação com pastas por classe, sem anotar caixas; notebook versionado, com sementes e versões fixadas. |
| **Comunicação** | Grupo de mensagens | Avisar cada envio para revisão e o prazo de devolução. |

### Combinados do grupo

- **Definição de pronto:** uma tarefa só está feita quando o código está no GitHub, o trecho de texto correspondente está no Overleaf e o print ou figura está salvo em docs/.
- **Revisão pelos colegas** quando o Leonardo enviar algo, sem calendário fixo.
- **Escopo congelado em 22/11:** ideia nova vira “trabalhos futuros”.
- **Escrever junto com o código:** cada funcionalidade gera um parágrafo e um print na hora.

### Uso de IA

- **Declarar o uso** de IA na monografia, numa nota curta na Metodologia. Segundo um colega, o professor Igor disse que pode usar IA para auxiliar no TCC.
- **Sem plágio:** toda ideia de outro autor vira paráfrase com citação; citação direta só entre aspas e com página.
- **Sem fonte inventada:** só se cita o que foi aberto e conferido (DOI, PDF ou página oficial).
- **Sem dado simulado:** toda métrica, tabela ou print sai de execução real. Enquanto o resultado não existir, o texto leva o marcador **[RESULTADO A PREENCHER]**.

## 12. Riscos e plano B

| Risco | Chance | Impacto | O que fazer |
|---|---|---|---|
| **O treino do modelo não fica bom ou atrasa** | Média | Alto | Começar por dataset público e por um baseline pronto; se o YOLO26n-cls travar, trocar por YOLO11n-cls ou MobileNet com as mesmas pastas. Em último caso, LLM na nuvem como plano B. |
| **Fotos do dataset diferentes das fotos de campo** | Alta | Médio | Testar com fotos próprias (`ml/protocolo-fotos-proprias.md`); usar data augmentation; relatar como limitação. |
| **Fotos próprias incompletas no prazo** (o tomate verde leva de 10 a 15 dias para ficar vermelho a 25 °C; Anexo B) | Média | Alto | Comprar tomates em vários estádios no primeiro dia, para ter todas as classes logo; fotografar até 22/11; se faltar alguma classe, relatar o que houver como limitação. |
| **Recomendação errada em casos limítrofes** (classe “de vez”) | Média | Médio | Mostrar a confiança; mensagem condicional ao destino da venda; pedir nova foto quando a confiança for baixa. |
| **Prazo curto (postagem em 12/12)** | Alta | Alto | Cronograma semanal com marcos; escrita em paralelo desde a semana 1; escopo congelado em 22/11; versão completa em 28/11. |
| **Uma pessoa executando tudo** | Alta | Alto | Apoio de IA; escopo enxuto; o Leonardo envia partes para os colegas revisarem, para eles acompanharem e dominarem o conteúdo. |
| **ENADE (29/11), V2 de outras disciplinas (30/11 a 05/12) e estágio competindo por tempo** | Alta | Médio | Texto completo antes do ENADE; a semana da V2 fica só para revisão. |
| **UML ou MER inconsistentes com o código** | Média | Alto | Diagramas atualizados junto com o código; revisão pelos colegas. |
| **Licença AGPL-3.0 do Ultralytics** | Média | Baixo | O app usa o `flutter_litert` (Apache-2.0), mas o modelo treinado com o `ultralytics` continua sob a AGPL-3.0. Para o TCC basta publicar o código no GitHub. Para virar produto fechado no futuro, trocar por MobileNet ou EfficientNet com LiteRT (licenças permissivas). |
| **Fotos e localização dos usuários (LGPD)** | Baixa | Médio | No MVP as fotos ficam só no celular e o EXIF/GPS é removido; nada vai para servidor. |
| **Limite de colaboradores do Overleaf** | Alta | Baixo | O Leonardo é o dono; os revisores leem o PDF. |
| **Questões éticas** | Baixa | Médio | Seguir o manual: nenhuma pesquisa envolvendo pessoas; questionário só se for simples e anônimo. |

## Anexo A · Números úteis para a Introdução e a Justificativa

Todos conferidos na fonte em 03/11/2026. Citem a fonte original; as referências completas estão no Anexo C.

| Dado | Valor | Fonte |
|---|---|---|
| **Agricultura familiar no Brasil** | 3.897.408 estabelecimentos (76,8% do total) e 67,0% do pessoal ocupado | IBGE, Censo Agropecuário 2017 |
| **Agricultura familiar em MG e em Uberlândia** | 72,7% e 63,0% dos estabelecimentos | IBGE, Censo Agropecuário 2017 |
| **Tomate estaqueado** | 82,2% dos estabelecimentos são familiares; MG produz 24,0% do total nacional; Triângulo e Alto Paranaíba respondem por 27,1% de MG | IBGE, Censo Agropecuário 2017 |
| **Produção de tomate em 2025** | Brasil: 4,66 milhões de t; MG: 585 mil t; Triângulo: 99,4 mil t | IBGE, PAM 2025 |
| **Perdas de alimentos** | 13,8% dos alimentos se perderam entre a fazenda e o varejo (2016). Na colheita de frutas, entre as causas mais citadas estão o estádio de maturação e o momento da colheita. | FAO, SOFA 2019 |
| **Adoção digital no campo** | 84% dos produtores usam ao menos uma tecnologia digital (enquete on-line com 504 produtores; tende a superestimar) | Embrapa, Sebrae e INPE (2020); Bolfe et al. (2020) |
| **Rede móvel nos domicílios** | Funciona em 68,0% dos domicílios rurais e em 96,1% dos urbanos | IBGE, PNAD Contínua TIC 2025 |
| **Internet e celular no campo** | 81% dos domicílios rurais têm internet; 83% dos usuários rurais só acessam pelo celular; para 46% dos moradores rurais com celular, o pacote de dados acabou ao menos uma vez em 3 meses | Cetic.br, TIC Domicílios 2025 |
| **Sistemas dos celulares** | Android: 73,76% do tráfego web móvel no Brasil (out/2026) | StatCounter |

> [!warn] **Cuidados**
>
> Dado de domicílio não é dado de lavoura: no talhão, o sinal tende a ser pior. Os 40 a 50% de perda em frutas e hortaliças que circulam em páginas da Embrapa vêm de fonte secundária; usem com ressalva ou prefiram a FAO.

## Anexo B · Classes do modelo e escala de cor do tomate

### Classes, escalas de referência e recomendação

| Classe do modelo | Portaria MAPA 553/1995 | USDA (7 CFR §51.1860) | Superfície vermelha | Recomendação |
|---|---|---|---|---|
| **Verde** | Todo verde (imaturo) e verde maduro | Green e Breakers | Até 10% | Esperar |
| **De vez** | Pintado e rosado | Turning e Pink | De 10% a 60% | Colher se for para mercado distante; senão, esperar |
| **Maduro** | Vermelho e vermelho maduro | Light red e Red | Mais de 60% | Colher |
| **Passado** | Defeito grave | n/a | n/a | Colher já ou descartar |
| **Outro** | n/a | n/a | n/a | Pedir nova foto |

A Portaria 553/1995 foi revogada pela IN MAPA 33/2018, que não tem subgrupos de cor: citem como escala histórica e de mercado, junto com a norma voluntária PBMH/CEAGESP (2003) e a escala do USDA. O “mature green” dos artigos em inglês equivale ao “imaturo” da Portaria; não misturem os dois nos labels. Ajustem os limites às classes do dataset escolhido. A norma PBMH traz um texto da Embrapa Hortaliças que recomenda colher no início da maturação, porque o processo continua depois da colheita, mas não fala em distância do mercado (conferido no PDF em 10/11). A regra da classe “de vez” (colher se for para mercado distante) é, portanto, uma decisão do grupo apoiada nesse ponto, e é assim que aparece no Apêndice A da monografia.

### Referência para trabalho futuro: dias até o vermelho

Só se o extra da faixa de dias for aprovado em 22/11. Dias até o vermelho (mais de 90% da superfície), calculados da Tabela 2 de Ciptaningtyas et al. (2022):

| Estádio (Portaria) | ≈ USDA | 15 °C | 20 °C | 25 °C | 30 °C |
|---|---|---|---|---|---|
| **Todo verde (se fisiologicamente maduro)** | Green | 21 a 22 | 12 a 18 | 10 a 15 | 7 a 24 |
| **Verde maduro** | Breakers | 7 a 9 | 6 | 6 a 7 | 3 a 14 |
| **Pintado** | Turning | 6 a 7 | 5 | 5 a 6 | 2 a 13 |
| **Rosado** | Pink | 4 a 5 | 3 | 3 a 5 | 1 a 10 |
| **Vermelho** | Light red | 3 | 1 a 2 | 2 a 4 | 1 a 7 |
| **Vermelho maduro** | Red | 0 | 0 | 0 | 0 |

> [!warn] **Por que isso ficou fora do MVP**
>
> São três cultivares japonesas, colhidas verdes maduras e amadurecidas **depois da colheita**, em temperatura constante. Para o fruto no pé, servem só como aproximação. **A 30 °C o amadurecimento ficou mais lento** em uma das cultivares (até 24 dias), o que importa no calor do Triângulo. Se entrar, a faixa deve ser sempre mostrada como estimativa, nunca como número exato.

## Anexo C · Referências iniciais verificadas

> [!info] Todas as referências abaixo foram abertas e conferidas (DOI, Crossref, arXiv ou página oficial) em 03/11/2026. Mesmo assim, leiam cada trabalho antes de citar e confiram os números no PDF; vários artigos estão disponíveis pelo Portal de Periódicos da CAPES. Preprints (arXiv) devem aparecer como preprint: confirmem com o professor se podem ser usados.

### C.1 Estado da Arte: sugestão de 5 trabalhos e alternativas

Os 5 marcados como “Sugerido” cobrem os lados do TCC: app brasileiro, YOLO em campo, tomate e app offline no celular. Monte a tabela comparativa com estas colunas: cultura, tarefa, modelo, dados (origem, tamanho, foto de celular?), métrica, onde roda (offline ou servidor), idioma e público, saída para o produtor (estádio, colher/aguardar, dias).

MUNDIM FILHO, A. C.; ALVARENGA, C.; CARNEIRO, M. G. Colher ou não colher? Uma rede neural convolucional para apoiar cafeicultores na decisão da colheita. In: WORKSHOP DE INICIAÇÃO CIENTÍFICA EM SISTEMAS DE INFORMAÇÃO – SIMPÓSIO BRASILEIRO DE SISTEMAS DE INFORMAÇÃO (SBSI), 17., 2021, On-line. **Anais Estendidos** [...]. Porto Alegre: Sociedade Brasileira de Computação, 2021. p. 57-60. DOI: 10.5753/sbsi.2021.15356.

_→ Sugerido. Antecedente mais próximo (UFU): MobileNet com transfer learning do ImageNet, decisão colher/não colher do café, 93% de acurácia e 92% de F1 em 150 imagens de teste. O artigo não tem app: levar o modelo para um app aparece como próximo passo (conferido no PDF em 10/11). O TCC precisa se diferenciar dele._

SANTOS, D. M. **Redes neurais convolucionais para classificar a maturação de frutos de café**. 2022. 63 f. Dissertação (Mestrado em Agricultura e Informações Geoespaciais) – Universidade Federal de Uberlândia, Monte Carmelo, 2022. Disponível em: https://repositorio.ufu.br/handle/123456789/36614. Acesso em: 3 nov. 2026.

_→ Complementa o anterior (mesmo grupo): dois protótipos de app Android com TensorFlow Lite; 92% de acurácia na decisão binária e precisão média de 63% nos 5 estádios (conferido no PDF em 10/11)._

BAZAME, H. C. et al. Detection of coffee fruits on tree branches using computer vision. **Scientia Agricola**, Piracicaba, v. 80, e20220064, 2023. DOI: 10.1590/1678-992X-2022-0064.

_→ Sugerido. 387 fotos de celular em Patos de Minas-MG; YOLOv4 com mAP de 81% a 800 px, com queda forte em entrada pequena._

ALVINO, D. da S. et al. OlivesApp: aplicativo de classificação do índice de maturação de azeitonas através do YOLOv8. In: WORKSHOP DE FERRAMENTAS E APLICAÇÕES – SIMPÓSIO BRASILEIRO DE SISTEMAS MULTIMÍDIA E WEB (WEBMEDIA), 30., 2024, Juiz de Fora. **Anais Estendidos** [...]. Porto Alegre: Sociedade Brasileira de Computação, 2024. p. 103-106. DOI: 10.5753/webmedia_estendido.2024.244038.

_→ Sugerido. App brasileiro (Flutter + API Flask + YOLOv8), sem métricas e dependente de servidor._

DONG, Y. et al. GPC-YOLO: an improved lightweight YOLOv8n network for the detection of tomato maturity in unstructured natural environments. **Sensors**, Basel, v. 25, n. 5, 1502, 2025. DOI: 10.3390/s25051502.

_→ Sugerido. Tomate, 3 classes, mAP50 de 99,2% com modelo de 2,7 MB; não testado em celular._

SHINODA, R. et al. AgroBench: vision-language model benchmark in agriculture. In: IEEE/CVF INTERNATIONAL CONFERENCE ON COMPUTER VISION (ICCV), 2025, Honolulu. **Proceedings** [...]. [S. l.]: IEEE; CVF, 2025. p. 7634-7644.

_→ Alternativa, se o extra com LLM entrar: benchmark de modelos multimodais na agricultura._

LEE, U. et al. An automated, clip-type, small Internet of Things camera-based tomato flower and fruit monitoring and harvest prediction system. **Sensors**, Basel, v. 22, n. 7, 2456, 2022. DOI: 10.3390/s22072456.

_→ Alternativa: previsão da data de colheita do tomate com erro de ±2,03 dias, mas com câmera fixa e acompanhamento contínuo._

ZHENG, H. et al. An android-smartphone application for rice panicle detection and rice growth stage recognition using a lightweight YOLO network. **Frontiers in Plant Science**, Lausanne, v. 16, 1561632, 2025. DOI: 10.3389/fpls.2025.1561632.

_→ Sugerido. Melhor modelo de metodologia para testes no celular (NCNN, offline, ~64 ms)._

LI, P. et al. Tomato maturity detection and counting model based on MHSA-YOLOv8. **Sensors**, Basel, v. 23, n. 15, 6701, 2023. DOI: 10.3390/s23156701.

_→ Alternativa: mostra que semimaduro e maduro se confundem._

MINAGAWA, D.; KIM, J. Prediction of harvest time of tomato using Mask R-CNN. **AgriEngineering**, Basel, v. 4, n. 2, p. 356-366, 2022. DOI: 10.3390/agriengineering4020024.

_→ Alternativa: previsão do momento de colheita por índices de cor._

ARSHAD, M. A. et al. Leveraging vision language models for specialized agricultural tasks. In: IEEE/CVF WINTER CONFERENCE ON APPLICATIONS OF COMPUTER VISION (WACV), 2025, Tucson. **Proceedings** [...]. [S. l.]: IEEE; CVF, 2025. p. 6320-6329.

_→ AgEval: o F1 do GPT-4o sobe de 46% para 73% com 8 exemplos._

RIZZO, M. et al. Fruit ripeness classification: a survey. **Artificial Intelligence in Agriculture**, [S. l.], v. 7, p. 44-57, 2023. DOI: 10.1016/j.aiia.2023.02.004.

_→ Revisão sobre classificação de maturação: bom ponto de partida._

JAIN, R. et al. Privacy preserving ordinal-meta learning with VLMs for fine-grained fruit quality prediction. arXiv, 2025. Preprint arXiv:2511.01449.

_→ Preprint: Gemini com 83,33% sem exemplos, em 10 frutas e 5 classes._

RANARIO, E.; EARLES, M. J. Are vision-language models ready to zero-shot replace supervised classification models in agriculture? arXiv, 2025. Preprint arXiv:2512.15977, v3.

_→ Preprint: um YOLO11 supervisionado supera todos os modelos multimodais testados._

### C.2 Referencial Teórico

REDMON, J. et al. You only look once: unified, real-time object detection. In: IEEE CONFERENCE ON COMPUTER VISION AND PATTERN RECOGNITION (CVPR), 2016, Las Vegas. **Proceedings** [...]. Piscataway: IEEE, 2016. p. 779-788. DOI: 10.1109/CVPR.2016.91.

TERVEN, J.; CÓRDOVA-ESPARZA, D.-M.; ROMERO-GONZÁLEZ, J.-A. A comprehensive review of YOLO architectures in computer vision: from YOLOv1 to YOLOv8 and YOLO-NAS. **Machine Learning and Knowledge Extraction**, Basel, v. 5, n. 4, p. 1680-1716, 2023. DOI: 10.3390/make5040083.

BADGUJAR, C. M.; POULOSE, A.; GAN, H. Agricultural object detection with You Only Look Once (YOLO) algorithm: a bibliometric and systematic literature review. **Computers and Electronics in Agriculture**, Amsterdam, v. 223, 109090, 2024. DOI: 10.1016/j.compag.2024.109090.

JOCHER, G. et al. Ultralytics YOLO26: unified real-time end-to-end vision models. arXiv, 2026. Preprint arXiv:2606.03748.

LECUN, Y.; BENGIO, Y.; HINTON, G. Deep learning. **Nature**, London, v. 521, n. 7553, p. 436-444, 2015. DOI: 10.1038/nature14539.

GOODFELLOW, I.; BENGIO, Y.; COURVILLE, A. **Deep learning**. Cambridge, MA: MIT Press, 2016.

PAN, S. J.; YANG, Q. A survey on transfer learning. **IEEE Transactions on Knowledge and Data Engineering**, [S. l.], v. 22, n. 10, p. 1345-1359, 2010. DOI: 10.1109/TKDE.2009.191.

HOWARD, A. G. et al. MobileNets: efficient convolutional neural networks for mobile vision applications. arXiv, 2017. Preprint arXiv:1704.04861.

TAN, M.; LE, Q. EfficientNet: rethinking model scaling for convolutional neural networks. In: INTERNATIONAL CONFERENCE ON MACHINE LEARNING (ICML), 36., 2019, Long Beach. **Proceedings** [...]. [S. l.]: PMLR, 2019. p. 6105-6114.

SOKOLOVA, M.; LAPALME, G. A systematic analysis of performance measures for classification tasks. **Information Processing & Management**, [S. l.], v. 45, n. 4, p. 427-437, 2009. DOI: 10.1016/j.ipm.2009.03.002.

EVERINGHAM, M. et al. The Pascal Visual Object Classes (VOC) challenge. **International Journal of Computer Vision**, [S. l.], v. 88, n. 2, p. 303-338, 2010. DOI: 10.1007/s11263-009-0275-4.

SEYMOUR, G. B. et al. Fruit development and ripening. **Annual Review of Plant Biology**, Palo Alto, v. 64, p. 219-241, 2013. DOI: 10.1146/annurev-arplant-050312-120057.

CIPTANINGTYAS, D. et al. Modeling the metachronous ripening pattern of mature green tomato as affected by cultivar and storage temperature. **Scientific Reports**, [S. l.], v. 12, 8241, 2022. DOI: 10.1038/s41598-022-12219-z.

UNITED STATES. Department of Agriculture. Agricultural Marketing Service. **United States standards for grades of fresh tomatoes**. Washington, DC: USDA, 1991. Reimpressão de jan. 1997.

BRASIL. Ministério da Agricultura, do Abastecimento e da Reforma Agrária. Portaria nº 553, de 30 de agosto de 1995. Aprova a norma de identidade, qualidade, acondicionamento e embalagem do tomate. **Diário Oficial da União**, Brasília, DF, 19 set. 1995. (Revogada pela Instrução Normativa MAPA nº 33/2018.)

PROGRAMA BRASILEIRO PARA A MODERNIZAÇÃO DA HORTICULTURA. **Normas de classificação do tomate**. São Paulo: CEAGESP/CQH, 2003. (CQH. Documentos, 26).

OLIVEIRA, W. et al. Analyzing the resource usage overhead of mobile app development frameworks. In: INTERNATIONAL CONFERENCE ON EVALUATION AND ASSESSMENT IN SOFTWARE ENGINEERING (EASE), 27., 2023, Oulu. **Proceedings** [...]. New York: ACM, 2023. p. 152-161. DOI: 10.1145/3593434.3593487.

### C.3 Contexto e justificativa

IBGE. **Censo Agropecuário 2017**: resultados definitivos. Rio de Janeiro: IBGE, 2019. Disponível em: https://sidra.ibge.gov.br/pesquisa/censo-agropecuario/censo-agropecuario-2017. Acesso em: 3 nov. 2026.

IBGE. **Produção Agrícola Municipal 2025**. Rio de Janeiro: IBGE, 2026. Disponível em: https://sidra.ibge.gov.br/pesquisa/pam/tabelas. Acesso em: 3 nov. 2026.

IBGE. **Pesquisa Nacional por Amostra de Domicílios Contínua**: acesso à Internet e à televisão e posse de telefone móvel celular para uso pessoal 2025. Rio de Janeiro: IBGE, 2026. (Informativo).

NÚCLEO DE INFORMAÇÃO E COORDENAÇÃO DO PONTO BR. **TIC Domicílios 2025**: pesquisa sobre o uso das tecnologias de informação e comunicação nos domicílios brasileiros. São Paulo: NIC.br, 2025. Disponível em: https://cetic.br/pt/tics/domicilios/2025/domicilios/A4/. Acesso em: 3 nov. 2026.

BOLFE, É. L. et al. Precision and digital agriculture: adoption of technologies and perception of Brazilian farmers. **Agriculture**, Basel, v. 10, n. 12, 653, 2020. DOI: 10.3390/agriculture10120653.

FAO. **The State of Food and Agriculture 2019**: moving forward on food loss and waste reduction. Rome: FAO, 2019.

### C.4 Dados, modelos e ferramentas

KARKOOTI, P. **Unified Tomato Detection and Ripeness Dataset**. [S. l.]: Hugging Face, 2026. Disponível em: https://huggingface.co/datasets/ParsaVictor/tomato-ripeness-detection. Acesso em: 3 nov. 2026.

_→ 8.497 imagens no formato YOLO; CC BY 4.0; muitas fotos de esteira._

LABORO.AI. **Laboro Tomato**: instance segmentation dataset. [S. l.]: Laboro.AI, 2020. Disponível em: https://github.com/laboroai/LaboroTomato. Acesso em: 3 nov. 2026.

_→ 804 imagens de estufa; 3 classes de maturação × 2 tamanhos; CC BY-NC-SA 4.0 (uso não comercial)._

TSIRONIS, V.; BOUROU, S.; STENTOUMIS, C. TomatOD: evaluation of object detection algorithms on a new real-world tomato dataset. **The International Archives of the Photogrammetry, Remote Sensing and Spatial Information Sciences**, v. XLIII-B3-2020, p. 1077-1084, 2020. DOI: 10.5194/isprs-archives-XLIII-B3-2020-1077-2020.

_→ 277 imagens e 2.418 frutos em 3 classes de maturação; CC BY-NC-SA 4.0._

KARKOOTI, P. **Tomato Ripeness Detection & Counting**: complete pipeline (YOLO26s). [S. l.]: Hugging Face, 2026. Disponível em: https://huggingface.co/ParsaVictor/tomato-ripeness-yolo26. Acesso em: 3 nov. 2026.

_→ Modelo pronto (AGPL-3.0) para baseline: 88,7% em 3 classes._

ULTRALYTICS. **ultralytics_yolo**: versão 0.7.1. [S. l.]: pub.dev, 2026. Disponível em: https://pub.dev/packages/ultralytics_yolo. Acesso em: 3 nov. 2026.

_→ Plugin Flutter oficial: Android 7.0+ (LiteRT) e iOS (Core ML), offline._

## Anexo D · Perguntas para levar ao professor

1. Há prazo interno ou entrega parcial antes de 12/12? A nota do TCC entra como V1, VT ou V2, ou é dada por banca?
2. O que deve ser postado: só o PDF, ou também código, APK, vídeo e link do GitHub? Cada integrante posta, ou só um?

> [!info] **Já respondidas**
>
> Grupo de 3: aceito. Formato: monografia. Ética: seguimos o manual (sem pesquisa envolvendo pessoas). Uso de IA: liberado como auxílio, segundo o professor Igor (relato de um colega); vamos declarar o uso na monografia. NBR 10520: a de 2023. Dataset: público, com treino do nosso próprio modelo; o modelo pronto do Hugging Face serve só de comparação.

### Checklist individual de cada integrante

- [ ] ENADE: inscrição como concluinte confirmada, local de prova consultado e Questionário do Estudante preenchido até as 13h de 29/11.
- [ ] Nenhuma disciplina pendente na matriz (conferir no Espaço do Aluno).
