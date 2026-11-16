# App Flutter: maturação do tomate

App que fotografa um tomate, classifica a maturação **no aparelho, sem internet**,
e recomenda colher ou esperar. Android primeiro; a pasta `ios/` existe, mas o
build para iPhone ainda não foi feito (precisa do Xcode).

## Situação

Verificado em 04/11/2026 num Mac com Apple silicon, usando Flutter 3.47.9
(Dart 3.13.7), Java 17 (Corretto) e Android SDK (platform 36, NDK
28.2.13676358, AGP 9.1.0, Gradle 9.3.1):

- `flutter analyze`: nenhum problema;
- `flutter test`: 58 testes passando;
- `flutter build apk --debug`: `app-debug.apk` gerado (208 MB; o primeiro
  build levou cerca de 10 min);
- emulador Android 36 (arm64): o app abre, mostra o aviso "Modelo de IA não
  encontrado" com os botões de análise desligados, e o histórico abre vazio.

Em 16/11/2026, com o modelo treinado (`assets/models/best.tflite`, experimento
`yolo26n_cls_v1`), `flutter analyze`, `flutter test` e o APK de debug passaram
de novo. No emulador, o app leu as 5 classes dos metadados do modelo e analisou
imagens de validação do dataset escolhidas pela galeria. Um tomate maduro deu
maduro (colher), um verde deu verde (esperar), e um recorte de fundo deu outro
(nova foto). São as mesmas classes que o Python deu a essas imagens no treino
(`val_batch0_pred.jpg`). O mesmo recorte de fundo, cortado de outro jeito, saiu
como verde, com 62,9% de confiança.

Ainda **não** foram testados: a câmera, um celular de verdade, o modo avião e o
iOS.

As pastas `android/` e `ios/` já foram geradas com
`flutter create --org br.tcc --project-name maturacao_tomate --platforms android,ios .`
e já têm os ajustes: nome do app no Android; nome e permissões de câmera e
galeria no iOS. Não é preciso rodar o `flutter create` de novo.
Identificadores: `br.tcc.maturacao_tomate` (Android) e
`br.tcc.maturacaoTomate` (iOS).

## Como rodar

1. **Instale o Flutter stable 3.47.x** (o mínimo é 3.44, exigido pelo `sqflite`)
   e o Android SDK, e confira com `flutter doctor`. O Xcode só é necessário
   para iPhone.

2. **Baixe os pacotes e valide o código:**

   ```bash
   cd app
   flutter pub get
   flutter analyze
   flutter test
   ```

   O teste do banco usa o `sqflite_common_ffi`; na primeira vez, o pacote
   `sqlite3` baixa a biblioteca do SQLite para o computador.

3. **Coloque o modelo:** copie o `.tflite` exportado pelo notebook de treino
   (`MyDrive/tcc-maturacao/exports/<experimento>/`) para `app/assets/models/`.
   Deixe só um `.tflite` nessa pasta. Sem ele, o app abre, mostra o aviso
   "Modelo de IA não encontrado" e não analisa fotos; o histórico continua
   funcionando.

4. **Rode no celular ou no emulador:**

   ```bash
   flutter devices
   flutter run
   ```

   O primeiro build precisa de internet: o Gradle baixa o LiteRT (usado pelo
   `flutter_litert`) e instala sozinho o que faltar no SDK (build-tools 36,
   platform 35 e CMake).

5. **APK para instalar em outros aparelhos:**

   ```bash
   flutter build apk --debug
   ```

   O arquivo sai em `build/app/outputs/flutter-apk/app-debug.apk`.

Depois de trocar o `.tflite`, rode o app de novo (`flutter run` ou
`flutter build apk`) para o novo modelo entrar no pacote.

### Android SDK sem Android Studio (como foi feito no Mac)

- Java 17 para o Gradle: `export JAVA_HOME=$(/usr/libexec/java_home -v 17)`.
- cmdline-tools (zip oficial do Google) em
  `~/Library/Android/sdk/cmdline-tools/latest`. Na versão 23, o `sdkmanager`
  virou o comando `android`, e os nomes dos pacotes usam `/`:

  ```bash
  ~/Library/Android/sdk/cmdline-tools/latest/bin/android --no-metrics sdk install platform-tools platforms/android-36 ndk/28.2.13676358 emulator system-images/android-36/google_apis/arm64-v8a
  ```

- Emulador (Pixel 7, Android 36):

  ```bash
  ~/Library/Android/sdk/cmdline-tools/latest/bin/avdmanager create avd -n tomate_api36 -k "system-images;android-36;google_apis;arm64-v8a" -d pixel_7
  ~/Library/Android/sdk/emulator/emulator -avd tomate_api36
  ```

- Para ter `adb`, `emulator` e as ferramentas no terminal, acrescente ao
  `~/.zshrc`:

  ```bash
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
  ```

- Espaço ocupado no Mac: 66 GB livres antes e 40 GB depois. Por partes:
  Android SDK 9,1 GB (imagem do emulador 4,3 GB, NDK 2,8 GB), cache do Gradle
  4,1 GB, Flutter 3,9 GB, `app/build` 2,4 GB, dados do emulador 1,7 GB e
  pacotes Dart 0,6 GB.

## Modelo

Coloque **um único** `.tflite` em `assets/models/` (ver
[assets/models/LEIA-ME.md](assets/models/LEIA-ME.md)). É o YOLO26n-cls exportado
pelo notebook `ml/01_treino_classificador.ipynb` com `format='litert'` e
`imgsz=224`.

- **Nomes das classes:** vêm do `metadata.json` que o `ultralytics` anexa ao
  `.tflite`. A ordem não é fixada no código. Se não houver metadados, o app usa
  `assets/models/labels.txt` (um nome por linha, na ordem dos índices).
- **Entrada:** o app lê a forma do tensor. Ela pode ser NCHW `[1, 3, 224, 224]`,
  como na exportação LiteRT do `ultralytics` 8.4, ou NHWC.
- **Pré-processamento:** o mesmo do `classify_transforms` do `ultralytics`:
  recorte do quadrado central, redimensionamento para 224 e RGB entre 0 e 1.
- **Versão do modelo:** cada análise grava `arquivo#sha256[0:12]`, para saber
  qual modelo gerou cada resultado.

**Inferência com `flutter_litert` (Apache-2.0).** É um plugin genérico e leve,
que deixa o pré-processamento e as probabilidades no código Dart, onde dá para
testar e descrever na Metodologia. O `ultralytics_yolo` (AGPL-3.0) foi deixado
de lado: ele traz câmera e CameraX junto e esconde esses passos. De qualquer
forma, o modelo treinado com o `ultralytics` continua sob a AGPL-3.0.

## Estrutura

```
lib/
  main.dart, app.dart        inicialização, tema e idioma (pt-BR)
  dependencias.dart          objetos compartilhados pelas telas
  dominio/                   classes, destino, recomendação e regra de decisão (Dart puro)
  classificador/             interface Classificador, implementação LiteRT,
                             leitura dos metadados, pré e pós-processamento
  dados/                     tabela analise (SQLite, sqflite) e repositório
  fotos/                     escolha da foto, remoção do EXIF/GPS e armazenamento
  ui/                        telas: início (guia de enquadramento), conferir foto,
                             resultado e histórico
assets/models/               o .tflite do modelo (best.tflite, versionado desde 16/11/2026)
test/                        testes de unidade e de tela
android/, ios/               projetos nativos gerados pelo flutter create
```

## Regra de decisão

Fica em `lib/dominio/regra_decisao.dart`:

- verde → esperar;
- de vez → colher se o destino for mercado distante; senão, esperar. O destino
  só é perguntado nesse caso;
- maduro → colher;
- passado → colher já ou descartar;
- outro, ou confiança abaixo do limiar → tirar nova foto.

O limiar de confiança baixa (`limiarConfiancaBaixa`, em
`lib/dominio/regra_decisao.dart`) é 0,47. Ele foi escolhido em 16/11/2026 com
as imagens de validação do dataset, no notebook `ml/02_limiar_e_paridade.ipynb`:
é o maior valor em que as imagens de validação com confiança abaixo dele erram
mais do que acertam. Se o modelo mudar, o limiar precisa ser escolhido de novo.

## Banco de dados (base do MER)

Uma tabela, `analise`, em `analises.db`:

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | INTEGER PK | autoincremento |
| `data_hora` | TEXT | ISO 8601 em UTC |
| `caminho_foto` | TEXT | relativo à pasta de documentos do app |
| `classe` | TEXT | `verde`, `de_vez`, `maduro`, `passado` ou `outro` |
| `confianca` | REAL | probabilidade da classe, de 0 a 1 |
| `recomendacao` | TEXT | `colher`, `esperar`, `colher_ja_ou_descartar` ou `nova_foto` |
| `destino` | TEXT, nulo | `mercado_distante` ou `perto`; só para `de_vez` |
| `versao_modelo` | TEXT | `arquivo#hash` do `.tflite` |
| `tempo_inferencia_ms` | INTEGER, nulo | tempo só do modelo, medido no aparelho |

## Privacidade

A foto é reduzida (lado máximo de 1600 px) e regravada sem EXIF, o que tira
também a localização GPS. Ela fica só na pasta do app. Nada é enviado para a
internet.

## Testes

`flutter test` cobre a regra de decisão, a leitura dos metadados do modelo
(com uma fixture gerada pelo mesmo `zipfile` do Python que o `ultralytics` usa:
`test/fixtures/gerar_tflite_com_metadados.py`), o pré e o pós-processamento,
a remoção do EXIF, o banco SQLite e as telas (modelo ausente, resultado e
pergunta do destino). Os valores fixos dos testes são só entradas de teste; os
testes não executam nenhum modelo.

`integration_test/paridade_test.dart` roda no emulador ou num celular, com o
modelo real: classifica as imagens de teste do dataset pelo mesmo caminho do app
(`limparFoto` e `ClassificadorLitert`) e grava classe e probabilidades num CSV,
que o notebook `ml/02_limiar_e_paridade.ipynb` compara com o Python. Os comandos
estão no começo do arquivo e na seção 6 do notebook.

## Pendências

- Testar o fluxo de foto e análise num celular de verdade (no emulador, já
  funciona com o modelo).
- Comparar o app com o Python em fotos grandes, que o app reduz. Em 16/11/2026,
  nas 918 imagens de teste do dataset (160 px, que o app amplia), o app deu a
  mesma classe que o Python em 897 (97,7%), depois de passar a usar a
  interpolação bilinear na ampliação; antes, eram 879 (95,8%).
- iOS: o build não foi testado. Com o `flutter_litert`, o iPhone usa o mesmo
  `.tflite`; a exportação para Core ML fica opcional.
- Guia de enquadramento: hoje há uma ilustração na tela inicial e a conferência
  do quadrado analisado depois da foto. Uma moldura sobre a câmera ao vivo
  exigiria o plugin `camera`.
