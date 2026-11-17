import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

/// Lado máximo, em pixels, da foto guardada no aparelho.
const ladoMaximoFoto = 1600;

/// Reduz a foto, aplica a rotação do EXIF nos pixels e devolve um JPEG sem
/// nenhum metadado EXIF (inclusive a localização GPS).
///
/// O `image_picker` no Android copia as tags de GPS ao redimensionar, por isso
/// a limpeza é feita aqui, no Dart.
Uint8List limparFoto(
  Uint8List bytes, {
  int ladoMaximo = ladoMaximoFoto,
  int qualidade = 90,
}) {
  final decodificada = img.decodeImage(bytes);
  if (decodificada == null) {
    throw const FormatException('Não foi possível ler a foto.');
  }
  var foto = img.bakeOrientation(decodificada);
  final maior = math.max(foto.width, foto.height);
  if (maior > ladoMaximo) {
    foto = img.copyResize(
      foto,
      width: foto.width >= foto.height ? ladoMaximo : null,
      height: foto.height > foto.width ? ladoMaximo : null,
      interpolation: img.Interpolation.average,
    );
  }
  foto.exif = img.ExifData();
  foto.textData = null;
  return img.encodeJpg(foto, quality: qualidade);
}

/// Foto pronta para análise: limpa e guardada na pasta do app.
class FotoPreparada {
  const FotoPreparada({required this.caminhoRelativo, required this.bytes});

  /// Caminho relativo à pasta de documentos do app.
  final String caminhoRelativo;

  /// Conteúdo JPEG, já sem EXIF.
  final Uint8List bytes;
}

/// Escolhe, limpa e guarda as fotos das análises.
class ServicoFotos {
  ServicoFotos({required this.pastaDocumentos, ImagePicker? seletor})
      : _seletor = seletor ?? ImagePicker();

  /// Pasta de documentos do app (`getApplicationDocumentsDirectory`).
  final String pastaDocumentos;
  final ImagePicker _seletor;

  static const subpasta = 'fotos';

  /// Abre a câmera ou a galeria. Devolve `null` se o usuário cancelar.
  Future<XFile?> escolher(ImageSource origem) => _seletor.pickImage(
        source: origem,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
        requestFullMetadata: false,
      );

  /// Limpa a foto (sem EXIF, no máximo [ladoMaximoFoto] px) e a guarda em
  /// `fotos/` dentro da pasta do app.
  Future<FotoPreparada> preparar(XFile origem) async {
    final bytes = await origem.readAsBytes();
    final limpos = await Isolate.run(() => limparFoto(bytes));
    final nome = 'analise_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final relativo = p.join(subpasta, nome);
    final arquivo = File(p.join(pastaDocumentos, relativo));
    await arquivo.parent.create(recursive: true);
    await arquivo.writeAsBytes(limpos, flush: true);
    return FotoPreparada(caminhoRelativo: relativo, bytes: limpos);
  }

  /// Arquivo de uma foto guardada, a partir do caminho relativo.
  File arquivo(String caminhoRelativo) =>
      File(p.join(pastaDocumentos, caminhoRelativo));

  /// Apaga a foto, se ela ainda existir.
  Future<void> apagar(String caminhoRelativo) async {
    final alvo = arquivo(caminhoRelativo);
    if (await alvo.exists()) await alvo.delete();
  }
}
