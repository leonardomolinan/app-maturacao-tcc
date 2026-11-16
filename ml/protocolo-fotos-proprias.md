# Protocolo das fotos próprias (conjunto de teste)

> **Situação em 16/11/2026:** as fotos não foram tiradas. A avaliação com fotos próprias virou trabalho futuro na monografia, e este protocolo fica como proposta para quem continuar o trabalho.

Este conjunto testa o modelo com fotos parecidas com as que o produtor vai tirar no celular. Ele **não entra no treino**: serve só para avaliar. As métricas que respondem à pergunta do TCC saem daqui (notebook `02`, a fazer).

## Por que fazer

O teste do dataset público usa fotos da mesma origem do treino (muitas de esteira e de estufa), por isso tende a ser otimista. As fotos próprias medem o que acontece na prática. Sem elas, o TCC só consegue relatar o desempenho no dataset público, e isso vira uma limitação importante.

## O que comprar (09/11/2026)

Uns 20 tomates de um tipo comum (salada ou italiano), em estádios diferentes:

| Quantos | Como escolher | Para quê |
|---|---|---|
| 10 a 12 verdes | Tamanho de tomate adulto, verde-claro e brilhante. Evite os muito pequenos: tomate colhido verde antes da hora pode não amadurecer direito. | Acompanhar cada um, dia a dia, do verde ao maduro |
| 4 de vez | Começando a avermelhar (pintados ou rosados) | Ter fotos de "de vez" já no primeiro dia |
| 4 maduros | Vermelhos | Ter fotos de "maduro" já no primeiro dia; deixe 2 passarem do ponto para virar "passado" |
| 2 passados, se achar | Moles, enrugados ou com manchas | Ter fotos de "passado" |

Comprar estádios variados garante um conjunto completo já no primeiro dia. Os verdes vão amadurecendo e completam as classes intermediárias nos dias seguintes.

Guarde os tomates fora da geladeira, em temperatura ambiente e longe do sol direto. Separe os passados dos outros e jogue fora os que mofarem.

## Como marcar

Numere cada tomate (1 a 20) com caneta permanente, em letra pequena, na base (o lado oposto ao cabinho). O número diz de qual fruto é cada foto: várias fotos do mesmo tomate não são independentes, e a avaliação precisa saber disso.

Fotografe sempre de lado, sem o número aparecer.

## Rotina diária (uns 10 minutos)

Todo dia, mais ou menos no mesmo horário, **até 22/11** (ou até os verdes ficarem vermelhos):

1. Para cada tomate, na ordem 1, 2, 3...:
   - tire 1 foto de um papel com o número dele em letra grande. É o separador, que diz de qual tomate são as fotos seguintes; ele não entra na avaliação;
   - tire 2 fotos do tomate: uma com luz natural (perto da janela, ou na sombra do lado de fora) e outra mudando alguma coisa (sol direto, luz da casa, outro fundo, o tomate na mão ou outro celular).
2. Anote na planilha uma linha por tomate: data, número, classe que você vê (critério abaixo) e observação. **Anote antes de ver a resposta do modelo.**
3. Suba as fotos do dia para `Meu Drive/tcc-maturacao/fotos-proprias/AAAA-MM-DD/`, uma pasta por dia (por exemplo, `2026-11-09`).

Como fotografar:

- um tomate por foto, no centro, ocupando uns 2/3 do quadro: o app analisa só o quadrado do meio;
- de 20 a 30 cm de distância, sem zoom e sem flash, com o foco no tomate;
- câmera normal do celular, na resolução padrão.

## Critério da classe

É o mesmo da tabela do Apêndice A da monografia. Olhe o tomate inteiro, girando:

- **verde:** até 10% da superfície vermelha, rosada ou amarelada;
- **de vez:** de 10% a 60%;
- **maduro:** mais de 60%;
- **passado:** mole, enrugado, com mancha escura, mofo ou rachadura.

Na dúvida entre duas classes, escolha a mais provável e anote a dúvida na observação.

## Fotos "outro" (uma vez só)

De 20 a 30 fotos sem tomate: mesa vazia, folhas, mão, chão, e coisas que podem confundir o modelo (pimentão vermelho, maçã, laranja, caqui). Elas vão na pasta `fotos-proprias/outro/`.

## Planilha

Um arquivo `fotos-proprias/rotulos` (Planilhas Google ou CSV) com estas colunas:

| data | tomate | classe | observacao |
|---|---|---|---|
| 2026-11-09 | 1 | verde | |
| 2026-11-09 | 2 | verde | dúvida entre verde e de vez |

Use os nomes de classe do app: `verde`, `de_vez`, `maduro`, `passado`.

## Se der para envolver o grupo

- Um colega pode rotular as mesmas fotos sem ver a planilha. A concordância entre os dois rótulos mostra o quanto a classe "de vez" é subjetiva, o que é um bom dado para a discussão.
- Fotos tiradas com outros celulares deixam o teste mais próximo do uso real.
