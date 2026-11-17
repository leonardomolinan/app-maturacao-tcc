import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Ordem dos eixos do tensor de entrada.
///
/// A exportação para LiteRT do `ultralytics` 8.4 (via `litert-torch`) mantém o
/// formato do PyTorch, NCHW `[1, 3, 224, 224]`; exportações antigas (via
/// `onnx2tf`) usam NHWC `[1, 224, 224, 3]`. O app aceita as duas e descobre
/// qual é pela forma do tensor.
enum LayoutEntrada { nhwc, nchw }

/// Descobre o layout pela forma do tensor de entrada, ou `null` se a forma
/// não for de uma imagem RGB única.
LayoutEntrada? layoutDaForma(List<int> forma) {
  if (forma.length != 4 || forma[0] != 1) return null;
  if (forma[3] == 3) return LayoutEntrada.nhwc;
  if (forma[1] == 3) return LayoutEntrada.nchw;
  return null;
}

/// Largura e altura esperadas pelo modelo, a partir da forma do tensor.
({int largura, int altura}) dimensoesDaForma(
  List<int> forma,
  LayoutEntrada layout,
) =>
    switch (layout) {
      LayoutEntrada.nhwc => (largura: forma[2], altura: forma[1]),
      LayoutEntrada.nchw => (largura: forma[3], altura: forma[2]),
    };

/// Decodifica a foto e a prepara para o modelo. Ver [preprocessarImagem].
Float32List preprocessar(
  Uint8List bytesImagem, {
  required int largura,
  required int altura,
  required LayoutEntrada layout,
}) {
  final imagem = img.decodeImage(bytesImagem);
  if (imagem == null) {
    throw const FormatException('Não foi possível ler a imagem.');
  }
  final ifd = imagem.exif.imageIfd;
  final orientada = ifd.hasOrientation && ifd.orientation != 1
      ? img.bakeOrientation(imagem)
      : imagem;
  return preprocessarImagem(
    orientada,
    largura: largura,
    altura: altura,
    layout: layout,
  );
}

/// Prepara a imagem do mesmo jeito que o `ultralytics` faz na predição de
/// classificação (`classify_transforms`):
///
/// 1. para entrada quadrada, recorta o quadrado central (equivale a
///    redimensionar o menor lado e fazer o `CenterCrop`);
/// 2. redimensiona para [largura] × [altura]. Para reduzir (o caso das fotos
///    do celular), usa a média de área, que se aproxima do redimensionamento
///    com antialias do PIL usado pelo `ultralytics`. Para ampliar (imagens
///    menores que a entrada do modelo), usa a interpolação bilinear, como o
///    PIL: nesse caso, a média de área do pacote `image` vira vizinho mais
///    próximo, e a comparação com o Python mostrou que isso muda a classe de
///    algumas imagens (notebook `ml/02_limiar_e_paridade.ipynb`);
/// 3. converte para RGB entre 0 e 1, sem subtrair média nem dividir por
///    desvio (o `ultralytics` usa média 0 e desvio 1 por padrão).
Float32List preprocessarImagem(
  img.Image imagem, {
  required int largura,
  required int altura,
  required LayoutEntrada layout,
}) {
  var rgb = imagem;
  if (rgb.hasPalette || rgb.numChannels < 3) {
    rgb = rgb.convert(numChannels: 3);
  }

  var recorte = rgb;
  if (largura == altura) {
    final lado = math.min(rgb.width, rgb.height);
    recorte = img.copyCrop(
      rgb,
      x: (rgb.width - lado) ~/ 2,
      y: (rgb.height - lado) ~/ 2,
      width: lado,
      height: lado,
    );
  }

  final redimensionada = recorte.width == largura && recorte.height == altura
      ? recorte
      : img.copyResize(
          recorte,
          width: largura,
          height: altura,
          interpolation: recorte.width < largura
              ? img.Interpolation.linear
              : img.Interpolation.average,
        );

  final plano = largura * altura;
  final tensor = Float32List(plano * 3);
  for (final pixel in redimensionada) {
    final r = pixel.rNormalized.toDouble();
    final g = pixel.gNormalized.toDouble();
    final b = pixel.bNormalized.toDouble();
    final indice = pixel.y * largura + pixel.x;
    switch (layout) {
      case LayoutEntrada.nhwc:
        tensor[indice * 3] = r;
        tensor[indice * 3 + 1] = g;
        tensor[indice * 3 + 2] = b;
      case LayoutEntrada.nchw:
        tensor[indice] = r;
        tensor[plano + indice] = g;
        tensor[2 * plano + indice] = b;
    }
  }
  return tensor;
}
