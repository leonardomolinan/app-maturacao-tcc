# Treino e avaliação do modelo

| Notebook | O que faz |
|---|---|
| `01_treino_classificador.ipynb` | Treina o YOLO26n-cls nas classes verde, de vez, maduro, passado e outro, com o dataset público fixado num commit; avalia no teste do dataset; exporta para LiteRT e Core ML |
| `02_...` (a fazer) | Avalia o modelo nas fotos próprias de campo, o teste que responde à pergunta do TCC |

## Como abrir no Colab

O repositório é privado, então escolha uma destas formas:

- No Colab: **Arquivo → Abrir notebook → GitHub**, marque **Incluir repositórios particulares**, autorize e escolha `leonardomolinan/app-maturacao-tcc`.
- Ou envie o `.ipynb` direto: **Arquivo → Fazer upload de notebook**.

Depois: **Ambiente de execução → Alterar o tipo de ambiente → GPU T4** e **Executar tudo**.

## Onde ficam os resultados

Tudo vai para `MyDrive/tcc-maturacao/` no Google Drive:

- `runs/<experimento>/`: pesos (`best.pt`, `last.pt`), `metricas_teste.json`, `matriz_confusao_teste.png` e `ambiente.json`
- `exports/<experimento>/`: modelo para o celular (`.tflite` e, se exportou, `.mlpackage`)

Datasets, pesos e execuções não vão para o git. Só o modelo exportado que o app usa entra no repositório, em `app/assets/models/`.
