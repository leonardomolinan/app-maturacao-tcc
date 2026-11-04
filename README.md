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
app/        aplicativo Flutter (ainda não criado)
ml/         notebooks de treino e avaliação do modelo (Google Colab)
docs/
  roadmap.md   plano do TCC: decisões, cronograma, riscos e referências
  tcc/         monografia em LaTeX (abnTeX2), importada no Overleaf
```

## Monografia (Overleaf)

O texto fica em `docs/tcc/` e é a fonte da verdade. Para importar no Overleaf:

1. Gerar o zip: `cd docs/tcc && zip -r ../tcc-overleaf.zip main.tex referencias.bib pretextuais capitulos apendices`
2. No Overleaf: **New Project → Upload Project** e escolher o `tcc-overleaf.zip`.
3. Compilar com pdfLaTeX (padrão do Overleaf).

Para compilar localmente (macOS), use o Tectonic: `brew install tectonic`, depois `cd docs/tcc && tectonic --outdir build main.tex`. O PDF sai em `docs/tcc/build/main.pdf`, que não vai para o git. Na primeira vez ele baixa os pacotes do LaTeX. O Tectonic usa XeTeX e o Overleaf usa pdfLaTeX; o resultado é praticamente o mesmo, mas a versão oficial é a do Overleaf.

O plano gratuito do Overleaf não sincroniza com o GitHub. Depois de editar aqui, reenvie os arquivos alterados; se editar no Overleaf, traga as mudanças de volta para o repositório.

Trechos em vermelho no PDF (`\pendente{...}` e `\resultado`) ainda precisam ser escritos ou medidos e não podem sobrar na versão final.

## Prazos

- **28/11/2026**: texto completo
- **29/11/2026**: ENADE
- **10/12/2026**: postagem no Espaço do Aluno (limite prático; o prazo oficial é 12/12)
