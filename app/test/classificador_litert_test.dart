import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:maturacao_tomate/classificador/classificador.dart';
import 'package:maturacao_tomate/classificador/classificador_litert.dart';

import 'apoio/dubles.dart';

/// Estes testes cobrem as verificações feitas antes de abrir o LiteRT; eles
/// não executam nenhum modelo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Uint8List texto(String s) => Uint8List.fromList(utf8.encode(s));

  test('sem .tflite em assets/models: modelo ausente', () async {
    final classificador = ClassificadorLitert(
      bundle: BundleDeTeste({'assets/models/LEIA-ME.md': texto('leia')}),
    );
    await expectLater(classificador.carregar(), throwsA(isA<ModeloAusenteException>()));
  });

  test('mais de um .tflite: modelo inválido', () async {
    final classificador = ClassificadorLitert(
      bundle: BundleDeTeste({
        'assets/models/a.tflite': Uint8List(10),
        'assets/models/b.tflite': Uint8List(10),
      }),
    );
    await expectLater(classificador.carregar(), throwsA(isA<ModeloInvalidoException>()));
  });

  test('.tflite sem metadados e sem labels.txt: modelo inválido', () async {
    final classificador = ClassificadorLitert(
      bundle: BundleDeTeste({'assets/models/modelo.tflite': Uint8List(100)}),
    );
    await expectLater(
      classificador.carregar(),
      throwsA(
        isA<ModeloInvalidoException>().having((e) => e.mensagem, 'mensagem', contains('labels.txt')),
      ),
    );
  });

  test('classes desconhecidas no labels.txt: modelo inválido', () async {
    final classificador = ClassificadorLitert(
      bundle: BundleDeTeste({
        'assets/models/modelo.tflite': Uint8List(100),
        'assets/models/labels.txt': texto('raw\nripe\n'),
      }),
    );
    await expectLater(classificador.carregar(), throwsA(isA<ModeloInvalidoException>()));
  });

  test('classificar antes de carregar é erro', () async {
    final classificador = ClassificadorLitert(bundle: BundleDeTeste({}));
    await expectLater(classificador.classificar(Uint8List(0)), throwsStateError);
  });
}
