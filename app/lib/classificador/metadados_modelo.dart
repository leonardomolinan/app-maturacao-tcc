import 'dart:convert';
import 'dart:io' show ZLibDecoder;
import 'dart:math' as math;
import 'dart:typed_data';

import '../dominio/classe_maturacao.dart';
import 'classificador.dart';

/// Metadados que o `ultralytics` grava no `.tflite` exportado.
///
/// Na exportação para LiteRT, o `ultralytics` anexa ao fim do `.tflite` um
/// arquivo zip com uma entrada `metadata.json` (ver
/// `ultralytics/utils/export/litert.py`, versão 8.4.188). Esse JSON traz,
/// entre outros campos, `names` (índice → nome da classe), `imgsz`, `date` e
/// `version`. O app lê os nomes daí, sem fixar a ordem das classes no código.
class MetadadosModelo {
  const MetadadosModelo({
    required this.nomesClasses,
    this.tarefa,
    this.imgsz,
    this.data,
    this.versao,
  });

  /// Nome de cada classe, na ordem dos índices de saída do modelo.
  final List<String> nomesClasses;

  /// Tarefa do modelo (`classify` para o YOLO-cls).
  final String? tarefa;

  /// Tamanho de imagem usado na exportação.
  final List<int>? imgsz;

  /// Data da exportação.
  final String? data;

  /// Versão do pacote `ultralytics` que exportou o modelo.
  final String? versao;

  /// Nomes de entrada aceitos para o JSON de metadados dentro do zip.
  static const nomesArquivoMetadados = {
    'metadata.json',
    'TFLITE_ULTRALYTICS_METADATA.json',
  };

  /// Lê os metadados anexados ao `.tflite`.
  ///
  /// Devolve `null` se o arquivo não tiver metadados anexados e lança
  /// [FormatException] se eles existirem mas estiverem malformados.
  static MetadadosModelo? lerDeTflite(Uint8List bytes) {
    final json = lerEntradaDoZipAnexado(bytes, nomesArquivoMetadados);
    if (json == null) return null;
    return deJson(json);
  }

  /// Interpreta o conteúdo do `metadata.json`.
  static MetadadosModelo deJson(String texto) {
    final Object? dados;
    try {
      dados = jsonDecode(texto);
    } on FormatException catch (erro) {
      throw FormatException('metadata.json não é um JSON válido: ${erro.message}');
    }
    if (dados is! Map<String, dynamic>) {
      throw const FormatException('metadata.json não é um objeto JSON');
    }
    final imgsz = dados['imgsz'];
    return MetadadosModelo(
      nomesClasses: lerNomes(dados['names']),
      tarefa: dados['task']?.toString(),
      imgsz: imgsz is List ? [for (final v in imgsz) (v as num).toInt()] : null,
      data: dados['date']?.toString(),
      versao: dados['version']?.toString(),
    );
  }

  /// Converte o campo `names` numa lista ordenada pelo índice.
  ///
  /// Aceita o formato do `ultralytics` (`{"0": "de_vez", "1": "maduro"}`) e
  /// também uma lista simples.
  static List<String> lerNomes(Object? names) {
    if (names is List) {
      return [for (final nome in names) nome.toString()];
    }
    if (names is Map) {
      final porIndice = <int, String>{};
      for (final entrada in names.entries) {
        final indice = int.tryParse(entrada.key.toString());
        if (indice == null) {
          throw FormatException('índice de classe inválido em names: ${entrada.key}');
        }
        porIndice[indice] = entrada.value.toString();
      }
      for (var i = 0; i < porIndice.length; i++) {
        if (!porIndice.containsKey(i)) {
          throw FormatException('falta o índice $i em names');
        }
      }
      return [for (var i = 0; i < porIndice.length; i++) porIndice[i]!];
    }
    throw const FormatException('metadados sem a lista de classes (names)');
  }

  /// Lê um arquivo de rótulos com um nome de classe por linha, na ordem dos
  /// índices de saída do modelo. Linhas vazias são ignoradas.
  static List<String> lerArquivoRotulos(String texto) => [
        for (final linha in const LineSplitter().convert(texto))
          if (linha.trim().isNotEmpty) linha.trim(),
      ];
}

/// Converte os nomes lidos do modelo nas classes do app.
///
/// Lança [ModeloInvalidoException] se o modelo tiver uma classe que o app não
/// conhece ou nomes repetidos. Um modelo com menos classes (por exemplo, sem
/// `outro`) é aceito.
List<ClasseMaturacao> classesDosNomes(List<String> nomes) {
  if (nomes.isEmpty) {
    throw const ModeloInvalidoException('O modelo não lista nenhuma classe.');
  }
  final classes = <ClasseMaturacao>[];
  final desconhecidos = <String>[];
  for (final nome in nomes) {
    final classe = ClasseMaturacao.doRotulo(nome);
    if (classe == null) {
      desconhecidos.add(nome);
    } else {
      classes.add(classe);
    }
  }
  if (desconhecidos.isNotEmpty) {
    final esperadas = ClasseMaturacao.values.map((c) => c.rotulo).join(', ');
    throw ModeloInvalidoException(
      'O modelo tem classes que o app não conhece: ${desconhecidos.join(', ')}. '
      'Classes esperadas: $esperadas.',
    );
  }
  if (classes.toSet().length != classes.length) {
    throw ModeloInvalidoException(
      'O modelo tem classes repetidas: ${nomes.join(', ')}.',
    );
  }
  return classes;
}

/// Procura a entrada [nomes] no zip anexado ao fim de [bytes] e devolve o
/// conteúdo como texto UTF-8, ou `null` se não houver zip ou entrada.
///
/// Usa o diretório central do zip, como o `zipfile` do Python. Os
/// deslocamentos gravados podem ser relativos ao início do arquivo ou ao
/// início do zip; a diferença é corrigida como no `zipfile`.
String? lerEntradaDoZipAnexado(Uint8List bytes, Set<String> nomes) {
  final dados = ByteData.sublistView(bytes);
  final fim = _acharFimDoDiretorioCentral(dados);
  if (fim == null) return null;

  final quantidade = dados.getUint16(fim + 10, Endian.little);
  final tamanhoDiretorio = dados.getUint32(fim + 12, Endian.little);
  final inicioDeclarado = dados.getUint32(fim + 16, Endian.little);
  final deslocamento = fim - tamanhoDiretorio - inicioDeclarado;
  if (deslocamento < 0) {
    throw const FormatException('zip anexado com diretório central inconsistente');
  }

  var pos = inicioDeclarado + deslocamento;
  for (var i = 0; i < quantidade; i++) {
    if (pos + 46 > bytes.length ||
        dados.getUint32(pos, Endian.little) != 0x02014b50) {
      throw const FormatException('entrada inválida no diretório central do zip');
    }
    final metodo = dados.getUint16(pos + 10, Endian.little);
    final tamanhoComprimido = dados.getUint32(pos + 20, Endian.little);
    final tamanhoNome = dados.getUint16(pos + 28, Endian.little);
    final tamanhoExtra = dados.getUint16(pos + 30, Endian.little);
    final tamanhoComentario = dados.getUint16(pos + 32, Endian.little);
    final inicioLocal = dados.getUint32(pos + 42, Endian.little) + deslocamento;
    if (pos + 46 + tamanhoNome > bytes.length) {
      throw const FormatException('nome de entrada fora do arquivo');
    }
    final nome = utf8.decode(bytes.sublist(pos + 46, pos + 46 + tamanhoNome));
    if (nomes.contains(nome)) {
      return _lerConteudo(bytes, dados, inicioLocal, metodo, tamanhoComprimido);
    }
    pos += 46 + tamanhoNome + tamanhoExtra + tamanhoComentario;
  }
  return null;
}

/// Acha o registro "fim do diretório central" (EOCD) procurando de trás para
/// frente. Só aceita um registro cujo comentário termina exatamente no fim do
/// arquivo, para não confundir com bytes do próprio modelo.
int? _acharFimDoDiretorioCentral(ByteData dados) {
  const assinatura = 0x06054b50;
  const tamanhoMinimo = 22;
  final ultimo = dados.lengthInBytes - tamanhoMinimo;
  if (ultimo < 0) return null;
  final primeiro = math.max(0, ultimo - 0xFFFF);
  for (var i = ultimo; i >= primeiro; i--) {
    if (dados.getUint32(i, Endian.little) == assinatura) {
      final comentario = dados.getUint16(i + 20, Endian.little);
      if (i + tamanhoMinimo + comentario == dados.lengthInBytes) return i;
    }
  }
  return null;
}

String _lerConteudo(
  Uint8List bytes,
  ByteData dados,
  int inicioLocal,
  int metodo,
  int tamanhoComprimido,
) {
  if (inicioLocal < 0 ||
      inicioLocal + 30 > bytes.length ||
      dados.getUint32(inicioLocal, Endian.little) != 0x04034b50) {
    throw const FormatException('cabeçalho local do zip inválido');
  }
  final tamanhoNome = dados.getUint16(inicioLocal + 26, Endian.little);
  final tamanhoExtra = dados.getUint16(inicioLocal + 28, Endian.little);
  final inicio = inicioLocal + 30 + tamanhoNome + tamanhoExtra;
  final fim = inicio + tamanhoComprimido;
  if (fim > bytes.length) {
    throw const FormatException('conteúdo do zip fora do arquivo');
  }
  final comprimido = bytes.sublist(inicio, fim);
  final List<int> conteudo = switch (metodo) {
    0 => comprimido,
    8 => ZLibDecoder(raw: true).convert(comprimido),
    _ => throw FormatException('método de compressão $metodo não suportado'),
  };
  return utf8.decode(conteudo);
}
