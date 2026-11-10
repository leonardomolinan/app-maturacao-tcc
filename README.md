# App de maturação do tomate (TCC)

Aplicativo móvel que, a partir de uma foto, classifica a maturação do tomate e recomenda **colher** ou **esperar**, rodando no celular e **sem internet**. É o Trabalho de Conclusão de Curso de Bacharelado em Ciência da Computação da UNITRI (2026/2).

## Decisões do projeto

| | Decisão |
|---|---|
| Modelo | Classificação de imagem com YOLO26n-cls (pacote `ultralytics`), treinado a partir de um dataset público |
| Cultura | Tomate |
| Onde roda | No celular, offline (LiteRT no Android, Core ML no iOS) |
| Resposta | Classe (verde, de vez, maduro, passado, outro), confiança e recomendação "colher" ou "esperar" |
| App | Flutter, com Android primeiro |
| Backend | Nenhum no MVP: o histórico fica em SQLite no celular |
| Extras | Comparação com um LLM na nuvem ou faixa de dias até a colheita, só se o MVP estiver pronto em 22/11 |

Contexto completo, cronograma e referências em [docs/roadmap.md](docs/roadmap.md).

## Estrutura

```
app/        aplicativo Flutter (código em lib/, testes em test/, projetos nativos em android/ e ios/)
ml/         notebooks de treino e avaliação do modelo (Google Colab)
docs/
  roadmap.md   plano do TCC: decisões, cronograma, riscos e referências
```

## App (como rodar)

O passo a passo completo está em [app/README.md](app/README.md). Em resumo, com o Flutter stable (3.47.x; o mínimo é 3.44) e o Android SDK instalados:

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter run
```

O modelo treinado (`.tflite`) vai em `app/assets/models/`; sem ele, o app abre e avisa que o modelo não foi encontrado.

## Monografia (Overleaf)

O texto em LaTeX (abnTeX2) fica fora deste repositório, na pasta `tcc-overleaf`, ao lado dele (`~/www/unitri/tcc-overleaf`). O README de lá explica como gerar o zip para o Overleaf e como compilar localmente. O histórico até 04/11/2026 está aqui em `docs/tcc/` (commit `5899781`).

## Prazos

- **28/11/2026**: texto completo
- **29/11/2026**: ENADE
- **10/12/2026**: postagem no Espaço do Aluno (limite prático; o prazo oficial é 12/12)
