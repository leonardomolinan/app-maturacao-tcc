import 'package:flutter_test/flutter_test.dart';
import 'package:maturacao_tomate/dominio/classe_maturacao.dart';
import 'package:maturacao_tomate/dominio/destino.dart';
import 'package:maturacao_tomate/dominio/recomendacao.dart';
import 'package:maturacao_tomate/dominio/regra_decisao.dart';

void main() {
  // Limiar fixo só para os testes: não é o valor do app.
  const regra = RegraDecisao(limiarConfianca: 0.6);

  group('recomendação com confiança suficiente', () {
    test('verde → esperar', () {
      expect(regra.recomendar(ClasseMaturacao.verde, 0.9), Recomendacao.esperar);
    });

    test('de vez para mercado distante → colher', () {
      expect(
        regra.recomendar(ClasseMaturacao.deVez, 0.9, destino: Destino.mercadoDistante),
        Recomendacao.colher,
      );
    });

    test('de vez para perto → esperar', () {
      expect(
        regra.recomendar(ClasseMaturacao.deVez, 0.9, destino: Destino.perto),
        Recomendacao.esperar,
      );
    });

    test('maduro → colher', () {
      expect(regra.recomendar(ClasseMaturacao.maduro, 0.9), Recomendacao.colher);
    });

    test('passado → colher já ou descartar', () {
      expect(
        regra.recomendar(ClasseMaturacao.passado, 0.9),
        Recomendacao.colherJaOuDescartar,
      );
    });

    test('outro → nova foto, mesmo com confiança alta', () {
      expect(regra.recomendar(ClasseMaturacao.outro, 0.99), Recomendacao.novaFoto);
    });

    test('o destino é ignorado fora da classe de vez', () {
      expect(
        regra.recomendar(ClasseMaturacao.verde, 0.9, destino: Destino.mercadoDistante),
        Recomendacao.esperar,
      );
    });
  });

  group('confiança baixa', () {
    test('qualquer classe abaixo do limiar → nova foto', () {
      for (final classe in ClasseMaturacao.values) {
        expect(
          regra.recomendar(classe, 0.59, destino: Destino.mercadoDistante),
          Recomendacao.novaFoto,
          reason: classe.rotulo,
        );
      }
    });

    test('de vez com confiança baixa não exige destino', () {
      expect(regra.precisaDestino(ClasseMaturacao.deVez, 0.3), isFalse);
      expect(regra.recomendar(ClasseMaturacao.deVez, 0.3), Recomendacao.novaFoto);
    });

    test('confiança igual ao limiar é aceita', () {
      expect(regra.confiancaBaixa(0.6), isFalse);
      expect(regra.recomendar(ClasseMaturacao.maduro, 0.6), Recomendacao.colher);
    });
  });

  group('destino', () {
    test('só é perguntado para de vez com confiança suficiente', () {
      expect(regra.precisaDestino(ClasseMaturacao.deVez, 0.9), isTrue);
      for (final classe in ClasseMaturacao.values.where((c) => c != ClasseMaturacao.deVez)) {
        expect(regra.precisaDestino(classe, 0.9), isFalse, reason: classe.rotulo);
      }
    });

    test('de vez sem destino é erro', () {
      expect(() => regra.recomendar(ClasseMaturacao.deVez, 0.9), throwsArgumentError);
    });
  });

  group('validação da confiança', () {
    test('rejeita valores fora de 0 a 1 e NaN', () {
      for (final valor in [-0.1, 1.1, double.nan]) {
        expect(() => regra.recomendar(ClasseMaturacao.maduro, valor), throwsArgumentError);
      }
    });
  });

  test('o limiar padrão do app continua marcado como pendente', () {
    // Quando o limiar vier da validação do modelo, troque a constante para
    // false e atualize este teste.
    expect(limiarConfiancaAindaPendente, isTrue);
    expect(const RegraDecisao().limiarConfianca, limiarConfiancaBaixaPendente);
  });
}
