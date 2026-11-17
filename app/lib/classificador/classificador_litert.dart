import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';

import 'classificador.dart';
import 'metadados_modelo.dart';
import 'pos_processamento.dart';
import 'pre_processamento.dart';

/// Classificador que roda o `.tflite` no aparelho com o `flutter_litert`
/// (LiteRT, antigo TensorFlow Lite), sem internet.
///
/// O modelo é o único `.tflite` em `assets/models/`. Os nomes das classes vêm
/// do `metadata.json` anexado ao `.tflite` pelo `ultralytics` ou, se ele não
/// existir, de `assets/models/labels.txt` (um nome por linha, na ordem dos
/// índices).
class ClassificadorLitert implements Classificador {
  ClassificadorLitert({AssetBundle? bundle, this.threads = 2})
      : _bundle = bundle ?? rootBundle;

  static const pastaModelos = 'assets/models/';
  static const arquivoRotulos = 'assets/models/labels.txt';

  final AssetBundle _bundle;

  /// Número de threads de CPU usadas pelo LiteRT.
  final int threads;

  Future<InfoModelo>? _carregamento;
  Interpreter? _interpretador;
  InfoModelo? _info;
  LayoutEntrada? _layout;

  @override
  Future<InfoModelo> carregar() => _carregamento ??= _carregar();

  Future<InfoModelo> _carregar() async {
    final ativos = (await AssetManifest.loadFromAssetBundle(_bundle)).listAssets();
    final caminho = _localizarModelo(ativos);
    final arquivo = caminho.substring(pastaModelos.length);

    final dados = await _bundle.load(caminho);
    final bytes = dados.buffer.asUint8List(dados.offsetInBytes, dados.lengthInBytes);
    final metadados = await _lerMetadados(bytes, arquivo, ativos);
    final classes = classesDosNomes(metadados.nomesClasses);

    final Interpreter interpretador;
    try {
      interpretador = Interpreter.fromBuffer(
        bytes,
        options: InterpreterOptions()..threads = threads,
      );
    } catch (erro) {
      throw ModeloInvalidoException('O LiteRT não conseguiu abrir $arquivo: $erro');
    }

    try {
      final entrada = interpretador.getInputTensor(0);
      final saida = interpretador.getOutputTensor(0);
      if (entrada.type != TensorType.float32) {
        throw ModeloInvalidoException(
          'A entrada do modelo é ${entrada.type.name}; o app espera float32.',
        );
      }
      final layout = layoutDaForma(entrada.shape);
      if (layout == null) {
        throw ModeloInvalidoException(
          'Forma de entrada inesperada ${entrada.shape}; o app espera uma '
          'imagem RGB, [1, 3, A, L] ou [1, A, L, 3].',
        );
      }
      final quantidadeSaida = saida.shape.fold<int>(1, (a, b) => a * b);
      if (saida.type != TensorType.float32 || quantidadeSaida != classes.length) {
        throw ModeloInvalidoException(
          'A saída do modelo (${saida.type.name} ${saida.shape}) não bate com '
          'as ${classes.length} classes dos metadados.',
        );
      }
      final dimensoes = dimensoesDaForma(entrada.shape, layout);
      final info = InfoModelo(
        arquivo: arquivo,
        hash: sha256.convert(bytes).toString().substring(0, 12),
        classesPorIndice: classes,
        larguraEntrada: dimensoes.largura,
        alturaEntrada: dimensoes.altura,
        dataExportacao: metadados.data,
        versaoUltralytics: metadados.versao,
      );
      _interpretador = interpretador;
      _layout = layout;
      _info = info;
      return info;
    } catch (_) {
      interpretador.close();
      rethrow;
    }
  }

  String _localizarModelo(List<String> ativos) {
    final modelos = ativos
        .where((a) => a.startsWith(pastaModelos) && a.toLowerCase().endsWith('.tflite'))
        .toList()
      ..sort();
    if (modelos.isEmpty) {
      throw const ModeloAusenteException(
        'Nenhum arquivo .tflite em app/assets/models/.',
      );
    }
    if (modelos.length > 1) {
      throw ModeloInvalidoException(
        'Há mais de um .tflite em app/assets/models/ (${modelos.join(', ')}). '
        'Deixe só o modelo que o app deve usar.',
      );
    }
    return modelos.single;
  }

  Future<MetadadosModelo> _lerMetadados(
    Uint8List bytes,
    String arquivo,
    List<String> ativos,
  ) async {
    try {
      final metadados = MetadadosModelo.lerDeTflite(bytes);
      if (metadados != null) return metadados;
    } on FormatException catch (erro) {
      throw ModeloInvalidoException(
        'Os metadados de $arquivo estão malformados: ${erro.message}',
      );
    }
    if (ativos.contains(arquivoRotulos)) {
      final nomes = MetadadosModelo.lerArquivoRotulos(
        await _bundle.loadString(arquivoRotulos),
      );
      if (nomes.isNotEmpty) return MetadadosModelo(nomesClasses: nomes);
    }
    throw ModeloInvalidoException(
      '$arquivo não traz os nomes das classes (metadata.json) e não existe '
      '$arquivoRotulos. Exporte o modelo com o ultralytics ou crie esse arquivo.',
    );
  }

  @override
  Future<ResultadoClassificacao> classificar(Uint8List bytesImagem) async {
    final interpretador = _interpretador;
    final info = _info;
    final layout = _layout;
    if (interpretador == null || info == null || layout == null) {
      throw StateError('Modelo não carregado: chame carregar() antes.');
    }
    final largura = info.larguraEntrada;
    final altura = info.alturaEntrada;
    final entrada = await Isolate.run(
      () => preprocessar(
        bytesImagem,
        largura: largura,
        altura: altura,
        layout: layout,
      ),
    );

    final saida = Float32List(info.classesPorIndice.length);
    final cronometro = Stopwatch()..start();
    interpretador.run(entrada, saida);
    cronometro.stop();
    return montarResultado(saida, info.classesPorIndice, cronometro.elapsed);
  }

  @override
  Future<void> fechar() async {
    _interpretador?.close();
    _interpretador = null;
    _info = null;
    _layout = null;
    _carregamento = null;
  }
}
