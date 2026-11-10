import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:maturacao_tomate/classificador/pos_processamento.dart';
import 'package:maturacao_tomate/dominio/classe_maturacao.dart';

void main() {
  // Ordem alfabética das pastas, como o YOLO-cls faria; aqui é só entrada fixa.
  const classes = [
    ClasseMaturacao.deVez,
    ClasseMaturacao.maduro,
    ClasseMaturacao.outro,
    ClasseMaturacao.passado,
    ClasseMaturacao.verde,
  ];

  test('saída já em probabilidades é mantida', () {
    final saida = [0.1, 0.6, 0.05, 0.05, 0.2];
    expect(paraProbabilidades(saida), saida);
  });

  test('logits passam por softmax', () {
    final probs = paraProbabilidades([2.0, 1.0, 0.0]);
    final soma = probs.fold<double>(0, (a, b) => a + b);
    expect(soma, closeTo(1, 1e-9));
    final esperado0 = math.exp(2) / (math.exp(2) + math.exp(1) + 1);
    expect(probs[0], closeTo(esperado0, 1e-9));
  });

  test('a classe vem do índice de maior probabilidade, na ordem do modelo', () {
    final r = montarResultado([0.1, 0.6, 0.05, 0.05, 0.2], classes, Duration.zero);
    expect(r.classe, ClasseMaturacao.maduro);
    expect(r.confianca, closeTo(0.6, 1e-9));
    expect(r.probabilidades[ClasseMaturacao.verde], closeTo(0.2, 1e-9));
  });

  test('outra ordem de classes muda a classe escolhida', () {
    final invertida = classes.reversed.toList();
    final r = montarResultado([0.1, 0.6, 0.05, 0.05, 0.2], invertida, Duration.zero);
    expect(r.classe, ClasseMaturacao.passado);
  });

  test('tamanho da saída diferente do número de classes é erro', () {
    expect(() => montarResultado([0.5, 0.5], classes, Duration.zero), throwsArgumentError);
  });

  test('saída vazia ou com NaN é erro', () {
    expect(() => paraProbabilidades([]), throwsArgumentError);
    expect(() => paraProbabilidades([0.5, double.nan]), throwsArgumentError);
  });
}
