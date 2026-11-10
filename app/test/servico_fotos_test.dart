import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:maturacao_tomate/fotos/servico_fotos.dart';

void main() {
  img.Image fotoComExif({required int largura, required int altura, int orientacao = 1}) {
    final foto = img.Image(width: largura, height: altura);
    img.fill(foto, color: img.ColorRgb8(200, 30, 30));
    foto.exif.imageIfd.orientation = orientacao;
    foto.exif.imageIfd[0x010F] = img.IfdValueAscii('Fabricante'); // Make
    foto.exif.gpsIfd[0x0002] = img.IfdValueRational(18, 1); // GPSLatitude
    foto.exif.gpsIfd[0x0004] = img.IfdValueRational(48, 1); // GPSLongitude
    return foto;
  }

  test('a foto de entrada do teste tem GPS no EXIF', () {
    final jpeg = img.encodeJpg(fotoComExif(largura: 40, altura: 30));
    final lida = img.decodeJpg(jpeg)!;
    expect(lida.exif.gpsIfd.isEmpty, isFalse);
  });

  test('remove todo o EXIF, inclusive o GPS', () {
    final jpeg = img.encodeJpg(fotoComExif(largura: 40, altura: 30));
    final limpa = img.decodeJpg(limparFoto(jpeg))!;
    expect(limpa.exif.gpsIfd.isEmpty, isTrue);
    expect(limpa.exif.isEmpty, isTrue);
  });

  test('aplica a rotação do EXIF nos pixels', () {
    // Orientação 6: a câmera gravou deitado; a foto certa fica em pé.
    final jpeg = img.encodeJpg(fotoComExif(largura: 40, altura: 30, orientacao: 6));
    final limpa = img.decodeJpg(limparFoto(jpeg))!;
    expect((limpa.width, limpa.height), (30, 40));
  });

  test('reduz o maior lado para o limite, mantendo a proporção', () {
    final jpeg = img.encodeJpg(fotoComExif(largura: 400, altura: 200));
    final limpa = img.decodeJpg(limparFoto(jpeg, ladoMaximo: 100))!;
    expect((limpa.width, limpa.height), (100, 50));
  });

  test('bytes que não são imagem dão erro', () {
    expect(() => limparFoto(Uint8List.fromList([1, 2, 3])), throwsFormatException);
  });
}
