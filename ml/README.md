# Treino e avaliação do modelo

| Arquivo | O que faz |
|---|---|
| `01_treino_classificador.ipynb` | Treina o YOLO26n-cls nas classes verde, de vez, maduro, passado e outro, com o dataset público fixado num commit; avalia no teste do dataset; exporta para LiteRT e Core ML |
| `protocolo-fotos-proprias.md` | Como montar o conjunto de teste com fotos próprias: quantos tomates, como marcar, rotina diária e critério das classes |
| `02_...` (a fazer) | Avalia o modelo nas fotos próprias, o teste que responde à pergunta do TCC |

## Como rodar o treino no Colab

O treino roda no Google Colab; nada é instalado no computador. O próprio notebook instala a versão fixada do `ultralytics` e baixa o dataset (uns 830 MB) dentro do Colab.

1. Abra o notebook pelo link abaixo. Como o repositório é privado, o Colab pede para autorizar o GitHub:
   https://colab.research.google.com/github/leonardomolinan/app-maturacao-tcc/blob/main/ml/01_treino_classificador.ipynb

   Outra forma: no Colab, **Arquivo → Abrir notebook → GitHub**, marque **Incluir repositórios particulares** e escolha `leonardomolinan/app-maturacao-tcc`.
2. **Ambiente de execução → Alterar o tipo de ambiente de execução → GPU T4 → Salvar.**
3. **Ambiente de execução → Executar tudo**, e autorize o Google Drive quando ele pedir.
4. Na saída da primeira célula, confira se aparece `CUDA disponível: True`. Se aparecer `False`, a GPU não foi ativada: o plano gratuito não garante GPU, então tente de novo mais tarde.
5. Se o Colab pedir para reiniciar a sessão depois da instalação, reinicie e execute tudo de novo.
6. Deixe a aba aberta até o fim. Se a sessão cair no meio do treino, use a célula de retomada (seção 6 do notebook).

## Onde ficam os resultados

Tudo vai para `MyDrive/tcc-maturacao/` no Google Drive:

- `runs/<experimento>/`: pesos (`best.pt`, `last.pt`), `results.csv`, `metricas_teste.json`, `matriz_confusao_teste.png` e `ambiente.json`
- `exports/<experimento>/`: modelo para o celular (`.tflite` e, se exportou, `.mlpackage`)

## Depois do treino

1. Copie o `.tflite` de `exports/<experimento>/` para `app/assets/models/`. Deixe só um `.tflite` na pasta.
2. Copie `results.csv`, `metricas_teste.json`, `matriz_confusao_teste.png` e `ambiente.json` para `ml/resultados/<experimento>/`. São os números que vão para a monografia, por isso ficam versionados.
3. Rode o app no emulador ou no celular e confira, com as mesmas fotos, se ele dá a mesma classe que o Python.

Datasets, pesos (`.pt`) e execuções não vão para o git. Entram no repositório só o modelo exportado que o app usa, em `app/assets/models/`, e os arquivos de métricas, em `ml/resultados/`.
