# Teste do app no celular (25/11/2026)

Teste dos casos da Tabela "Casos de teste funcionais" da Metodologia, num **Redmi Note 13 5G (Android 15)**, com o APK de release (versão 0.1.0, modelo `best.tflite#00f754c3c9e8`), instalado do Windows pela depuração sem fio. Os resultados estão na seção 5.3 da monografia ("Testes funcionais e de desempenho").

## Sessões

| Sessão | Gravação de tela | Rede | Quadros | Análises |
|---|---|---|---|---|
| 1 | `Screenrecorder-2026-11-25-21-06-16-919.mp4` (58 s, 48 MB) | modo avião | ~24 por segundo, sem a marcação de toques | 3, pela câmera |
| 2 | `Screenrecorder-2026-11-25-22-09-08-651.mp4` (123 s, 204 MB) | Wi-Fi ligado | 60 por segundo, com "Mostrar toques" | 10: 9 pela câmera e 1 pela galeria |

As gravações não estão no git, por causa do tamanho. Elas ficaram no celular (`DCIM/ScreenRecorder`) e no Windows. A sessão 2 foi feita com o Wi-Fi ligado por engano. Isso não muda os tempos, porque o app instalado não tem a permissão `android.permission.INTERNET`: o `dumpsys package` do celular mostrou só a `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, que é interna. As três análises em modo avião da sessão 1 deram tempos compatíveis com os da sessão 2.

## O que foi medido

`medicoes.csv` tem uma linha por análise, com estes campos:

- **Classe, confiança e `inferencia_ms`:** lidas na tela de resultado de cada análise. O tempo de inferência é o que o app mostra no rodapé, medido em `classificador_litert.dart` só em volta de `interpretador.run`.
- **`t_toque_s`:** primeiro quadro em que o círculo do "Mostrar toques" aparece sobre o botão Analisar. Só existe na sessão 2.
- **`t_registro_s`:** primeiro quadro em que o botão muda para "Analisando…".
- **`t_inicio_resultado_s`:** primeiro quadro em que a tela muda fora da faixa do botão, ou seja, o começo da transição para a tela de resultado.
- **`t_fim_transicao_s`:** primeiro quadro com o título "Resultado" assentado.
- **Tempo de resposta:** `toque_ate_inicio_ms`. Também foram registrados `toque_ate_fim_ms` e, para comparar as duas sessões, `registro_ate_inicio_ms`.

## Resultados

- **Inferência (13 análises):** mediana de 37 ms; mínimo de 31 ms e máximo de 68 ms. O máximo foi a primeira análise da sessão 2.
- **Resposta, do toque ao início do resultado (9 fotos da câmera, sessão 2):** mediana de 950 ms, entre 920 e 988 ms.
- **Resposta até o fim da transição:** mediana de 1.225 ms, entre 1.198 e 1.264 ms. A animação de troca de tela leva cerca de 276 ms.
- **Foto da galeria:** 243 ms até o início do resultado e 519 ms até o fim da transição.
- **Do "Analisando…" ao início do resultado:** 823 a 825 ms na sessão 1 (modo avião), contra uma mediana de 853 ms (822 a 907 ms) na sessão 2 (câmera).

Os casos cumpridos foram CT01, CT02, CT03, CT04, CT05, CT06 e CT10. Ficaram faltando no celular os casos CT07, CT08, CT09, CT11 e CT13.

A foto da galeria, de um tomate com podridão, saiu como **verde (70,1%)**. É um erro do modelo, relatado na monografia.

## Como refazer a medição

Os scripts em `scripts/` usam o Microsoft Edge pelo `puppeteer-core` e leem o instante de cada quadro com `requestVideoFrameCallback`.

```bash
cd scripts && npm install
node measure.mjs <gravacao.mp4> dados.json 0.5      # 1 linha por quadro: instante, cor do botão, perfil do título
node analyze.mjs dados.json <t_conferir> <t_resultado>   # acha as análises e mede os tempos
node segments.mjs dados.json <t_conferir> <t_resultado> <t_inicio>   # trechos de cada tela
node infer.mjs <gravacao.mp4> saida.png "<ini-fim,...>"    # recorta a linha "inferência em X ms"
node crops.mjs <gravacao.mp4> saida.png "<t1,t2,...>" 1000 1250   # recorta o cartão da classe
node stats.mjs ../medicoes.csv                              # medianas e quartis
```

`t_conferir` e `t_resultado` são instantes de um quadro de cada tela, usados como modelo do título. Na sessão 2, foram usados 23,1 s e 26,2 s; na sessão 1, 48,5 s e 13,6 s. O caminho do Edge está fixo nos scripts, em `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe`.
