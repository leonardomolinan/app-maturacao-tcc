import 'package:flutter/services.dart';
import 'package:maturacao_tomate/classificador/classificador.dart';
import 'package:maturacao_tomate/dados/analise.dart';
import 'package:maturacao_tomate/dados/repositorio_analises.dart';
import 'package:maturacao_tomate/dominio/destino.dart';
import 'package:maturacao_tomate/dominio/recomendacao.dart';

/// Classificador de teste que só simula a falta do arquivo do modelo.
/// Nunca devolve classificação.
class ClassificadorSemModelo implements Classificador {
  @override
  Future<InfoModelo> carregar() async =>
      throw const ModeloAusenteException('Nenhum arquivo .tflite em app/assets/models/.');

  @override
  Future<ResultadoClassificacao> classificar(Uint8List bytesImagem) =>
      throw StateError('sem modelo');

  @override
  Future<void> fechar() async {}
}

/// Repositório em memória para os testes de tela.
class RepositorioEmMemoria implements RepositorioAnalises {
  final analises = <int, Analise>{};
  var _proximoId = 1;

  @override
  Future<int> inserir(Analise analise) async {
    final id = _proximoId++;
    analises[id] = Analise(
      id: id,
      dataHora: analise.dataHora,
      caminhoFoto: analise.caminhoFoto,
      classe: analise.classe,
      confianca: analise.confianca,
      recomendacao: analise.recomendacao,
      destino: analise.destino,
      versaoModelo: analise.versaoModelo,
      tempoInferenciaMs: analise.tempoInferenciaMs,
    );
    return id;
  }

  @override
  Future<void> atualizarDecisao(
    int id, {
    required Recomendacao recomendacao,
    Destino? destino,
  }) async {
    final a = analises[id]!;
    analises[id] = Analise(
      id: id,
      dataHora: a.dataHora,
      caminhoFoto: a.caminhoFoto,
      classe: a.classe,
      confianca: a.confianca,
      recomendacao: recomendacao,
      destino: destino,
      versaoModelo: a.versaoModelo,
      tempoInferenciaMs: a.tempoInferenciaMs,
    );
  }

  @override
  Future<List<Analise>> listar() async =>
      analises.values.toList()..sort((a, b) => b.dataHora.compareTo(a.dataHora));

  @override
  Future<void> apagar(int id) async {
    analises.remove(id);
  }
}

/// AssetBundle com arquivos em memória e o `AssetManifest.bin` gerado a
/// partir deles.
class BundleDeTeste extends CachingAssetBundle {
  BundleDeTeste(this.arquivos);

  final Map<String, Uint8List> arquivos;

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      final manifesto = {
        for (final nome in arquivos.keys)
          nome: [
            {'asset': nome},
          ],
      };
      return const StandardMessageCodec().encodeMessage(manifesto)!;
    }
    final bytes = arquivos[key];
    if (bytes == null) throw StateError('Asset ausente: $key');
    return ByteData.sublistView(bytes);
  }
}
