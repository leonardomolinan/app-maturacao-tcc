// Compara o app com o Python: classifica no aparelho as mesmas imagens que o
// notebook ml/02_limiar_e_paridade.ipynb classifica com o ultralytics.
//
// Roda no emulador ou num celular Android, com o .tflite em assets/models/.
// As imagens vão para a pasta interna do app, porque o app não lê pastas
// criadas pelo adb em Android/data. Com o app já instalado em modo debug (por
// exemplo, com flutter run):
//   COPYFILE_DISABLE=1 tar -C <pasta> -cf - . | adb exec-in run-as br.tcc.maturacao_tomate \
//     sh -c 'rm -rf files/paridade && mkdir -p files/paridade && tar -xf - -C files/paridade'
//   flutter test integration_test/paridade_test.dart --no-uninstall
//   adb exec-out run-as br.tcc.maturacao_tomate cat files/paridade_app.csv > paridade_app.csv
// Sem o --no-uninstall, o flutter test desinstala o app no fim e apaga as imagens.
// A <pasta> tem uma subpasta por classe real, com as imagens .jpg dentro.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maturacao_tomate/classificador/classificador_litert.dart';
import 'package:maturacao_tomate/fotos/servico_fotos.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'classifica as imagens de paridade pelo mesmo caminho do app',
    (tester) async {
      // Pasta interna do app: /data/user/0/br.tcc.maturacao_tomate/files.
      final base = await getApplicationSupportDirectory();
      final pasta = Directory('${base.path}/paridade');
      final arquivos = pasta
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.jpg'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      expect(arquivos, isNotEmpty, reason: 'Nenhuma imagem em ${pasta.path}');

      final classificador = ClassificadorLitert();
      final info = await classificador.carregar();
      final linhas = <String>[
        [
          'arquivo',
          'classe_prevista',
          'confianca',
          'tempo_ms',
          ...info.classesPorIndice.map((c) => c.rotulo),
        ].join(','),
      ];
      for (final arquivo in arquivos) {
        // Mesmo caminho da tela de conferência: limpa a foto e classifica.
        final bytes = limparFoto(await arquivo.readAsBytes());
        final resultado = await classificador.classificar(bytes);
        linhas.add([
          arquivo.path.substring(pasta.path.length + 1),
          resultado.classe.rotulo,
          resultado.confianca.toStringAsFixed(6),
          (resultado.tempoInferencia.inMicroseconds / 1000).toStringAsFixed(1),
          ...info.classesPorIndice
              .map((c) => resultado.probabilidades[c]!.toStringAsFixed(6)),
        ].join(','));
      }
      await classificador.fechar();
      File('${base.path}/paridade_app.csv')
          .writeAsStringSync('${linhas.join('\n')}\n');
    },
    timeout: const Timeout(Duration(minutes: 40)),
  );
}
