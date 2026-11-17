import '../dominio/classe_maturacao.dart';
import '../dominio/destino.dart';
import '../dominio/recomendacao.dart';

/// Uma análise de foto guardada no histórico (tabela `analise`).
class Analise {
  const Analise({
    this.id,
    required this.dataHora,
    required this.caminhoFoto,
    required this.classe,
    required this.confianca,
    required this.recomendacao,
    this.destino,
    required this.versaoModelo,
    this.tempoInferenciaMs,
  });

  /// Chave primária; `null` antes de gravar.
  final int? id;

  /// Momento da análise.
  final DateTime dataHora;

  /// Caminho da foto, relativo à pasta de documentos do app (o caminho
  /// absoluto muda no iOS quando o app é atualizado).
  final String caminhoFoto;

  final ClasseMaturacao classe;

  /// Probabilidade (0 a 1) que o modelo deu à [classe].
  final double confianca;

  final Recomendacao recomendacao;

  /// Destino informado pelo produtor; só existe quando a classe é "de vez".
  final Destino? destino;

  /// Arquivo e hash do modelo que fez a análise (ver `InfoModelo.versao`).
  final String versaoModelo;

  /// Tempo só da execução do modelo, em milissegundos, medido no aparelho.
  final int? tempoInferenciaMs;

  Map<String, Object?> paraLinha() => {
        if (id != null) 'id': id,
        // ISO 8601 em UTC com milissegundos: tamanho fixo, ordena como texto.
        'data_hora': DateTime.fromMillisecondsSinceEpoch(
          dataHora.millisecondsSinceEpoch,
          isUtc: true,
        ).toIso8601String(),
        'caminho_foto': caminhoFoto,
        'classe': classe.rotulo,
        'confianca': confianca,
        'recomendacao': recomendacao.codigo,
        'destino': destino?.codigo,
        'versao_modelo': versaoModelo,
        'tempo_inferencia_ms': tempoInferenciaMs,
      };

  static Analise daLinha(Map<String, Object?> linha) {
    final classe = ClasseMaturacao.doRotulo(linha['classe']! as String);
    final recomendacao = Recomendacao.doCodigo(linha['recomendacao']! as String);
    if (classe == null || recomendacao == null) {
      throw FormatException('Linha inválida na tabela analise: $linha');
    }
    return Analise(
      id: linha['id'] as int?,
      dataHora: DateTime.parse(linha['data_hora']! as String).toLocal(),
      caminhoFoto: linha['caminho_foto']! as String,
      classe: classe,
      confianca: (linha['confianca']! as num).toDouble(),
      recomendacao: recomendacao,
      destino: Destino.doCodigo(linha['destino'] as String?),
      versaoModelo: linha['versao_modelo']! as String,
      tempoInferenciaMs: linha['tempo_inferencia_ms'] as int?,
    );
  }
}
