/// Recomendação mostrada ao produtor.
enum Recomendacao {
  colher('colher', 'Colher'),
  esperar('esperar', 'Esperar'),
  colherJaOuDescartar('colher_ja_ou_descartar', 'Colher já ou descartar'),
  novaFoto('nova_foto', 'Tirar nova foto');

  const Recomendacao(this.codigo, this.nome);

  /// Valor gravado no banco de dados.
  final String codigo;

  /// Texto mostrado na interface.
  final String nome;

  static Recomendacao? doCodigo(String codigo) {
    for (final recomendacao in values) {
      if (recomendacao.codigo == codigo) return recomendacao;
    }
    return null;
  }
}
