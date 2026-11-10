import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:maturacao_tomate/classificador/classificador.dart';
import 'package:maturacao_tomate/classificador/metadados_modelo.dart';
import 'package:maturacao_tomate/dominio/classe_maturacao.dart';

/// Monta um zip mínimo com uma entrada sem compressão, com os deslocamentos
/// relativos ao início do zip (o caso que não é o do Python).
Uint8List zipArmazenado(String nome, String conteudo) {
  final nomeBytes = utf8.encode(nome);
  final dados = utf8.encode(conteudo);
  final saida = BytesBuilder();
  void u16(int v) => saida.add((ByteData(2)..setUint16(0, v, Endian.little)).buffer.asUint8List());
  void u32(int v) => saida.add((ByteData(4)..setUint32(0, v, Endian.little)).buffer.asUint8List());

  // Cabeçalho local.
  u32(0x04034b50);
  u16(20); u16(0); u16(0); u16(0); u16(0);
  u32(0); u32(dados.length); u32(dados.length);
  u16(nomeBytes.length); u16(0);
  saida.add(nomeBytes);
  saida.add(dados);
  final inicioDiretorio = saida.length;
  // Diretório central.
  u32(0x02014b50);
  u16(20); u16(20); u16(0); u16(0); u16(0); u16(0);
  u32(0); u32(dados.length); u32(dados.length);
  u16(nomeBytes.length); u16(0); u16(0); u16(0); u16(0);
  u32(0); u32(0);
  saida.add(nomeBytes);
  final tamanhoDiretorio = saida.length - inicioDiretorio;
  // Fim do diretório central.
  u32(0x06054b50);
  u16(0); u16(0); u16(1); u16(1);
  u32(tamanhoDiretorio); u32(inicioDiretorio);
  u16(0);
  return saida.toBytes();
}

void main() {
  group('metadata.json anexado ao .tflite', () {
    test('lê o formato gravado pelo zipfile do Python (fixture)', () {
      final bytes = File('test/fixtures/tflite_com_metadados.bin').readAsBytesSync();
      final metadados = MetadadosModelo.lerDeTflite(bytes)!;
      expect(metadados.nomesClasses, ['de_vez', 'maduro', 'outro', 'passado', 'verde']);
      expect(metadados.tarefa, 'classify');
      expect(metadados.imgsz, [224, 224]);
      expect(metadados.versao, '8.4.188');
    });

    test('aceita deslocamentos relativos ao início do zip', () {
      final json = jsonEncode({
        'names': {'1': 'verde', '0': 'maduro'},
      });
      final bytes = Uint8List.fromList([
        ...List.filled(300, 7),
        ...zipArmazenado('metadata.json', json),
      ]);
      expect(MetadadosModelo.lerDeTflite(bytes)!.nomesClasses, ['maduro', 'verde']);
    });

    test('arquivo sem zip anexado devolve null', () {
      expect(MetadadosModelo.lerDeTflite(Uint8List.fromList(List.filled(500, 1))), isNull);
      expect(MetadadosModelo.lerDeTflite(Uint8List(0)), isNull);
    });

    test('zip sem metadata.json devolve null', () {
      final bytes = Uint8List.fromList([...List.filled(10, 0), ...zipArmazenado('outro.txt', 'x')]);
      expect(MetadadosModelo.lerDeTflite(bytes), isNull);
    });
  });

  group('names', () {
    test('ordena pelo índice, não pela ordem das chaves', () {
      expect(
        MetadadosModelo.lerNomes({'2': 'c', '0': 'a', '1': 'b'}),
        ['a', 'b', 'c'],
      );
    });

    test('aceita lista', () {
      expect(MetadadosModelo.lerNomes(['a', 'b']), ['a', 'b']);
    });

    test('índice faltando ou ausência de names é erro', () {
      expect(() => MetadadosModelo.lerNomes({'0': 'a', '2': 'c'}), throwsFormatException);
      expect(() => MetadadosModelo.lerNomes(null), throwsFormatException);
      expect(() => MetadadosModelo.deJson('{"task": "classify"}'), throwsFormatException);
    });

    test('arquivo de rótulos: um nome por linha', () {
      expect(MetadadosModelo.lerArquivoRotulos('de_vez\nmaduro\r\n\n verde \n'), ['de_vez', 'maduro', 'verde']);
    });
  });

  group('classesDosNomes', () {
    test('converte os nomes das pastas nas classes do app', () {
      expect(
        classesDosNomes(['de_vez', 'maduro', 'outro', 'passado', 'verde']),
        [
          ClasseMaturacao.deVez,
          ClasseMaturacao.maduro,
          ClasseMaturacao.outro,
          ClasseMaturacao.passado,
          ClasseMaturacao.verde,
        ],
      );
    });

    test('aceita modelo sem a classe outro', () {
      expect(classesDosNomes(['de_vez', 'maduro', 'passado', 'verde']), hasLength(4));
    });

    test('classe desconhecida, repetida ou lista vazia é modelo inválido', () {
      expect(() => classesDosNomes(['ripe', 'raw']), throwsA(isA<ModeloInvalidoException>()));
      expect(() => classesDosNomes(['verde', 'verde']), throwsA(isA<ModeloInvalidoException>()));
      expect(() => classesDosNomes([]), throwsA(isA<ModeloInvalidoException>()));
    });
  });
}
