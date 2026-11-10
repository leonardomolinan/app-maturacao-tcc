/// Para onde o tomate vai depois de colhido.
///
/// Só é perguntado quando a classe é "de vez": o tomate continua amadurecendo
/// depois de colhido, então para mercado distante vale colher já.
enum Destino {
  mercadoDistante('mercado_distante', 'Mercado distante'),
  perto('perto', 'Perto (feira, mercado local ou consumo próprio)');

  const Destino(this.codigo, this.nome);

  /// Valor gravado no banco de dados.
  final String codigo;

  /// Texto mostrado na interface.
  final String nome;

  static Destino? doCodigo(String? codigo) {
    for (final destino in values) {
      if (destino.codigo == codigo) return destino;
    }
    return null;
  }
}
