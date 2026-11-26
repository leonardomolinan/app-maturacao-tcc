# Como continuar o TCC

Guia para retomar o projeto em outro computador, ou com um Claude que não conhece o histórico. Atualizado em 17/11/2026.

Este arquivo explica **onde as coisas estão e como preparar o computador**. A lista do que falta fazer fica num lugar só: a seção **"O que falta fazer"** do [docs/roadmap.md](docs/roadmap.md). Atualize lá, e não aqui, para os dois computadores verem sempre o mesmo estado.

## O projeto em uma frase

App Flutter que fotografa um tomate, classifica a maturação no próprio celular, sem internet (YOLO26n-cls exportado para `.tflite`), e recomenda colher ou esperar. É o TCC de Ciência da Computação da UNITRI (2026/2) de Leonardo Sergi Molina, Vítor Tetsuya Kazuma e Victor José Morais de Lima. O Leonardo executa, com apoio de IA, e os colegas revisam.

## Onde está cada coisa

| O quê | Onde | Observação |
|---|---|---|
| App, notebooks, métricas e plano | GitHub privado `leonardomolinan/app-maturacao-tcc` (este repositório) | `app/`, `ml/`, `docs/roadmap.md` |
| Monografia e Projeto de TCC (LaTeX) | GitHub privado `leonardomolinan/tcc-overleaf` | Clonar **ao lado** deste repositório, na mesma pasta-mãe |
| Versão oficial do PDF | Overleaf (conta do Leonardo) | O plano gratuito não sincroniza com o git: arquivos editados aqui precisam ser reenviados |
| Pesos e exportações do treino | Google Drive, `MyDrive/tcc-maturacao/` | Os pesos não vão para o git; o `.tflite` usado pelo app está em `app/assets/models/` |
| Roadmap em Word, para leitura | Gerado de `docs/roadmap.md` por `docs/gerar-docx/` | O `.docx` é só uma cópia; a versão que vale é o `.md` |
| Manual do TCC, orientações da UNITRI e PDF do Projeto | Só no Mac, em `~/www/unitri` e `~/www/personal/unitri` | Não estão no git. Copie para o outro computador se precisar |

## Situação em 17/11/2026

- **App:** funciona com o modelo treinado. No emulador, deu a mesma classe que o Python em 97,7% das imagens de teste. Em 25/11, o APK de release rodou num celular de verdade (Redmi Note 13 5G, Android 15), com a câmera e o modo avião funcionando. **Ainda não foram testados:** os outros casos de teste (exclusão, foto sem EXIF, Android 7.0), o tempo de resposta medido e o iOS.
- **Modelo:** acurácia de 84,9% e F1 macro de 0,858 no teste do dataset. As métricas estão em `ml/resultados/yolo26n_cls_v1/`.
- **Monografia:** completa para a avaliação do professor, sem trechos em vermelho, e com as citações pela NBR 10520 de 2023 desde 17/11. O texto ainda diz que o app só rodou no emulador e que o tempo de resposta num celular não foi medido. Com o teste de 25/11 e, quando for medido, o tempo de resposta, atualize a seção 5.3, as Limitações (5.5), a Conclusão, o Resumo e o Abstract.
- **Protocolos:** o Leonardo protocolou o Projeto de TCC em 16/11 e aguarda o deferimento. Falta confirmar os protocolos do Vitor e do Victor.
- **Git:** o PR #2 (app e plano) entrou na `main` em 17/11. Desde então, os commits vão direto na `main`, nos dois repositórios.

O que fazer em seguida: seção "O que falta fazer" do [docs/roadmap.md](docs/roadmap.md).

## Preparar o computador (Windows ou Mac)

1. **Git com acesso ao GitHub.** Os dois repositórios são privados. Clone os dois na mesma pasta:

   ```bash
   git clone git@github.com:leonardomolinan/app-maturacao-tcc.git
   git clone git@github.com:leonardomolinan/tcc-overleaf.git
   ```

   Os dois ficam na `main`. Nos dias seguintes, rode `git pull` nos dois antes de começar.

2. **App:**
   - instale o Flutter stable 3.47.x (o mínimo é 3.44) e o Android SDK; o Android Studio instala o SDK e o emulador;
   - aceite as licenças com `flutter doctor --android-licenses`;
   - use um emulador ou um celular Android com a depuração USB ligada;
   - siga a seção "Como rodar" do [app/README.md](app/README.md).

   O `.tflite` já está no repositório: não precisa baixar o modelo.

3. **Monografia:** para compilar localmente, instale o [Tectonic](https://tectonic-typesetting.github.io/) e rode `tectonic --outdir build main.tex` dentro de `tcc-overleaf`. Só com o Overleaf também dá: basta reenviar os arquivos alterados. O `README.md` e o `CLAUDE.md` de lá têm os detalhes, inclusive os cuidados para não quebrar o pdfLaTeX do Overleaf.

4. **Roadmap em Word (opcional):** com o Node.js instalado, gere o arquivo assim:

   ```bash
   cd docs/gerar-docx
   npm install
   npm run gerar
   ```

   O arquivo sai em `docs/gerar-docx/Roadmap_TCC.docx`, que fica fora do git.

5. **Treino:** roda no Google Colab, então não há nada a instalar ([ml/README.md](ml/README.md)). Só é preciso treinar de novo se o modelo mudar.

No Windows, os comandos com `zip`, `rm` ou `&&` dos READMEs são de terminal Unix: rode-os no Git Bash, que vem com o Git.

## Usar com o Claude

Abra o Claude Code na pasta `app-maturacao-tcc` e acrescente `tcc-overleaf` como segunda pasta da sessão. Cada repositório tem um `CLAUDE.md` com as regras do projeto, e o Claude lê esse arquivo sozinho. Sugestão de primeira mensagem:

> Leia o CONTINUAR.md, o CLAUDE.md e a seção "O que falta fazer" do docs/roadmap.md, e também o CLAUDE.md do ../tcc-overleaf. Depois me diga em poucas linhas o estado do projeto e qual é o próximo passo, sem mudar nada ainda.

## Regras que valem sempre

O detalhe está nos dois `CLAUDE.md`. Em resumo:

- **Integridade:**
  - nunca inventar fonte: só citar o que está no `referencias.bib` e foi conferido;
  - nunca simular dado: número, tabela ou print só saem de execução real; enquanto não existirem, ficam marcados como pendentes;
  - nunca plagiar.
- **Git:** commits direto na `main`, e commit ou push só quando o Leonardo pedir.
- **Ao terminar uma tarefa:**
  - atualize a seção "O que falta fazer" e a "Situação" do `docs/roadmap.md`, e faça commit e push, para o outro computador ver;
  - se mexeu na monografia, avise quais arquivos reenviar ao Overleaf.
