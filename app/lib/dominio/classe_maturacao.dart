/// Classes que o modelo devolve.
///
/// O [rotulo] é o nome da pasta do dataset, que é também o nome gravado nos
/// metadados do modelo exportado. A ordem dos índices de saída NÃO é fixada
/// aqui: ela vem do próprio modelo (ver `classificador/metadados_modelo.dart`).
/// No YOLO-cls essa ordem é a alfabética das pastas, mas o app não depende disso.
enum ClasseMaturacao {
  verde('verde', 'Verde'),
  deVez('de_vez', 'De vez'),
  maduro('maduro', 'Maduro'),
  passado('passado', 'Passado'),
  outro('outro', 'Outro (sem tomate ou foto inadequada)');

  const ClasseMaturacao(this.rotulo, this.nome);

  /// Nome usado no dataset, nos metadados do modelo e no banco de dados.
  final String rotulo;

  /// Nome mostrado na interface.
  final String nome;

  /// Converte o rótulo do modelo na classe do app, ou `null` se não existir.
  static ClasseMaturacao? doRotulo(String rotulo) {
    final limpo = rotulo.trim();
    for (final classe in values) {
      if (classe.rotulo == limpo) return classe;
    }
    return null;
  }
}
