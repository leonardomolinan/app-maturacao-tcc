# Modelo do app

Coloque aqui **um único** `.tflite`: o YOLO26n-cls exportado pelo notebook
`ml/01_treino_classificador.ipynb` (seção 8, `export(format='litert', imgsz=224)`),
copiado de `MyDrive/tcc-maturacao/exports/<experimento>/`. O nome do arquivo
pode ser qualquer um.

- **Classes:** o app lê os nomes do `metadata.json` que o `ultralytics` anexa ao
  `.tflite`. Se o arquivo não tiver esses metadados, crie `labels.txt` aqui, com
  um nome de classe por linha, na ordem dos índices do modelo (no YOLO-cls, a
  ordem alfabética das pastas).
- **Entrada:** float32, NCHW `[1, 3, 224, 224]` (LiteRT do ultralytics 8.4) ou
  NHWC `[1, 224, 224, 3]` (exportações antigas). O app descobre sozinho.
- Sem nenhum `.tflite` aqui, o app abre e mostra o aviso "Modelo de IA não
  encontrado"; ele nunca inventa um resultado.

Depois de trocar o modelo, gere o app de novo (`flutter run` ou
`flutter build apk`).
