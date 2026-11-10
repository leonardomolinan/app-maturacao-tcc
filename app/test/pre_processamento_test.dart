import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:maturacao_tomate/classificador/pre_processamento.dart';

void main() {
  group('layout da entrada', () {
    test('reconhece NCHW (litert-torch) e NHWC (onnx2tf)', () {
      expect(layoutDaForma([1, 3, 224, 224]), LayoutEntrada.nchw);
      expect(layoutDaForma([1, 224, 224, 3]), LayoutEntrada.nhwc);
    });

    test('rejeita formas que não são uma imagem RGB', () {
      expect(layoutDaForma([1, 224, 224]), isNull);
      expect(layoutDaForma([2, 3, 224, 224]), isNull);
      expect(layoutDaForma([1, 1, 224, 224]), isNull);
    });

    test('dimensões a partir da forma', () {
      expect(dimensoesDaForma([1, 3, 120, 160], LayoutEntrada.nchw), (largura: 160, altura: 120));
      expect(dimensoesDaForma([1, 120, 160, 3], LayoutEntrada.nhwc), (largura: 160, altura: 120));
    });
  });

  group('preprocessarImagem', () {
    // Imagem 6×2: metade esquerda vermelha, centro verde, direita azul.
    img.Image imagemDeTeste() {
      final imagem = img.Image(width: 6, height: 2);
      for (var y = 0; y < 2; y++) {
        for (var x = 0; x < 6; x++) {
          final cor = x < 2
              ? img.ColorRgb8(255, 0, 0)
              : x < 4
                  ? img.ColorRgb8(0, 255, 0)
                  : img.ColorRgb8(0, 0, 255);
          imagem.setPixel(x, y, cor);
        }
      }
      return imagem;
    }

    test('recorta o quadrado central e normaliza para 0–1 (NHWC)', () {
      final tensor = preprocessarImagem(
        imagemDeTeste(),
        largura: 2,
        altura: 2,
        layout: LayoutEntrada.nhwc,
      );
      expect(tensor.length, 2 * 2 * 3);
      // O quadrado central 2×2 é todo verde.
      for (var i = 0; i < 4; i++) {
        expect(tensor[i * 3], closeTo(0, 1e-6));
        expect(tensor[i * 3 + 1], closeTo(1, 1e-6));
        expect(tensor[i * 3 + 2], closeTo(0, 1e-6));
      }
    });

    test('NCHW separa os canais em planos', () {
      final tensor = preprocessarImagem(
        imagemDeTeste(),
        largura: 2,
        altura: 2,
        layout: LayoutEntrada.nchw,
      );
      expect(tensor.sublist(0, 4), everyElement(closeTo(0, 1e-6))); // R
      expect(tensor.sublist(4, 8), everyElement(closeTo(1, 1e-6))); // G
      expect(tensor.sublist(8, 12), everyElement(closeTo(0, 1e-6))); // B
    });

    test('a posição de cada pixel é preservada', () {
      final imagem = img.Image(width: 2, height: 2);
      imagem.setPixel(0, 0, img.ColorRgb8(255, 0, 0));
      imagem.setPixel(1, 0, img.ColorRgb8(0, 255, 0));
      imagem.setPixel(0, 1, img.ColorRgb8(0, 0, 255));
      imagem.setPixel(1, 1, img.ColorRgb8(255, 255, 255));
      final tensor = preprocessarImagem(
        imagem,
        largura: 2,
        altura: 2,
        layout: LayoutEntrada.nchw,
      );
      expect(tensor.sublist(0, 4), [1, 0, 0, 1]); // R
      expect(tensor.sublist(4, 8), [0, 1, 0, 1]); // G
      expect(tensor.sublist(8, 12), [0, 0, 1, 1]); // B
    });

    test('redimensiona para o tamanho do modelo', () {
      final grande = img.Image(width: 640, height: 480);
      img.fill(grande, color: img.ColorRgb8(128, 64, 32));
      final tensor = preprocessarImagem(
        grande,
        largura: 224,
        altura: 224,
        layout: LayoutEntrada.nchw,
      );
      expect(tensor.length, 224 * 224 * 3);
      expect(tensor[0], closeTo(128 / 255, 1e-6));
      expect(tensor[224 * 224], closeTo(64 / 255, 1e-6));
      expect(tensor[2 * 224 * 224], closeTo(32 / 255, 1e-6));
    });
  });
}
