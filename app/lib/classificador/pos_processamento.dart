import 'dart:math' as math;

import '../dominio/classe_maturacao.dart';
import 'classificador.dart';

/// Converte a saída do modelo em probabilidades.
///
/// O `Classify` do `ultralytics` já aplica softmax quando o modelo é
/// exportado, então a saída normalmente já é uma distribuição de
/// probabilidade e é devolvida sem alteração. Se ela não parecer uma (por
/// exemplo, logits de outro modelo), aplica softmax.
List<double> paraProbabilidades(List<double> saida) {
  if (saida.isEmpty) {
    throw ArgumentError.value(saida, 'saida', 'está vazia');
  }
  if (saida.any((v) => v.isNaN || v.isInfinite)) {
    throw ArgumentError.value(saida, 'saida', 'tem valores inválidos');
  }
  final soma = saida.fold<double>(0, (a, b) => a + b);
  final jaEhProbabilidade =
      saida.every((v) => v >= 0 && v <= 1) && (soma - 1).abs() < 1e-3;
  if (jaEhProbabilidade) return List<double>.of(saida);

  final maximo = saida.reduce(math.max);
  final exponenciais = [for (final v in saida) math.exp(v - maximo)];
  final total = exponenciais.fold<double>(0, (a, b) => a + b);
  return [for (final v in exponenciais) v / total];
}

/// Monta o resultado a partir da saída bruta do modelo.
///
/// [classesPorIndice] é a ordem das classes lida dos metadados do modelo.
ResultadoClassificacao montarResultado(
  List<double> saida,
  List<ClasseMaturacao> classesPorIndice,
  Duration tempoInferencia,
) {
  if (saida.length != classesPorIndice.length) {
    throw ArgumentError(
      'A saída tem ${saida.length} valores, mas o modelo lista '
      '${classesPorIndice.length} classes.',
    );
  }
  final probabilidades = paraProbabilidades(saida);
  var melhor = 0;
  for (var i = 1; i < probabilidades.length; i++) {
    if (probabilidades[i] > probabilidades[melhor]) melhor = i;
  }
  return ResultadoClassificacao(
    classe: classesPorIndice[melhor],
    confianca: probabilidades[melhor].clamp(0.0, 1.0),
    probabilidades: {
      for (var i = 0; i < classesPorIndice.length; i++)
        classesPorIndice[i]: probabilidades[i],
    },
    tempoInferencia: tempoInferencia,
  );
}
