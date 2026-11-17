import 'dart:typed_data';

import '../dominio/classe_maturacao.dart';

/// Classificador de maturação que roda no aparelho, sem internet.
///
/// A interface isola o resto do app da biblioteca de inferência: trocar o
/// `flutter_litert` por outro plugin (ou o YOLO por outro modelo) só mexe na
/// implementação.
abstract interface class Classificador {
  /// Carrega o modelo de `assets/models/`.
  ///
  /// Lança [ModeloAusenteException] se o arquivo não estiver no app e
  /// [ModeloInvalidoException] se ele não puder ser usado.
  Future<InfoModelo> carregar();

  /// Classifica a foto em [bytesImagem] (JPEG ou PNG).
  ///
  /// Só pode ser chamado depois de [carregar] terminar sem erro.
  Future<ResultadoClassificacao> classificar(Uint8List bytesImagem);

  /// Libera o modelo da memória.
  Future<void> fechar();
}

/// Dados do modelo carregado.
class InfoModelo {
  const InfoModelo({
    required this.arquivo,
    required this.hash,
    required this.classesPorIndice,
    required this.larguraEntrada,
    required this.alturaEntrada,
    this.dataExportacao,
    this.versaoUltralytics,
  });

  /// Nome do arquivo `.tflite` em `assets/models/`.
  final String arquivo;

  /// Início do SHA-256 do arquivo, para saber exatamente qual modelo gerou
  /// cada análise do histórico.
  final String hash;

  /// Classe correspondente a cada índice da saída do modelo, na ordem lida
  /// dos metadados do próprio modelo.
  final List<ClasseMaturacao> classesPorIndice;

  final int larguraEntrada;
  final int alturaEntrada;

  /// Data de exportação gravada nos metadados (quando existir).
  final String? dataExportacao;

  /// Versão do pacote `ultralytics` gravada nos metadados (quando existir).
  final String? versaoUltralytics;

  /// Identificação gravada em cada análise (coluna `versao_modelo`).
  String get versao => '$arquivo#$hash';
}

/// Resultado de uma classificação.
class ResultadoClassificacao {
  const ResultadoClassificacao({
    required this.classe,
    required this.confianca,
    required this.probabilidades,
    required this.tempoInferencia,
  });

  /// Classe com a maior probabilidade.
  final ClasseMaturacao classe;

  /// Probabilidade (0 a 1) da [classe].
  final double confianca;

  /// Probabilidade de cada classe, como saiu do modelo.
  final Map<ClasseMaturacao, double> probabilidades;

  /// Tempo só da execução do modelo (sem o pré-processamento da foto).
  final Duration tempoInferencia;
}

/// O arquivo do modelo não está em `assets/models/`.
class ModeloAusenteException implements Exception {
  const ModeloAusenteException(this.mensagem);
  final String mensagem;

  @override
  String toString() => 'ModeloAusenteException: $mensagem';
}

/// O arquivo do modelo existe, mas não pode ser usado pelo app.
class ModeloInvalidoException implements Exception {
  const ModeloInvalidoException(this.mensagem);
  final String mensagem;

  @override
  String toString() => 'ModeloInvalidoException: $mensagem';
}
