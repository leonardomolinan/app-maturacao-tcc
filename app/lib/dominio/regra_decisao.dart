import 'classe_maturacao.dart';
import 'destino.dart';
import 'recomendacao.dart';

/// PENDENTE: limiar de confiança baixa.
///
/// Este valor é PROVISÓRIO e NÃO foi medido: está aqui só para o app ter um
/// comportamento definido enquanto o modelo não é treinado e validado. Ele
/// deve ser escolhido a partir da validação do modelo (por exemplo, olhando
/// acurácia e cobertura por faixa de confiança no conjunto de fotos próprias)
/// e registrado na Metodologia. Não usar este número como resultado do TCC.
const double limiarConfiancaBaixaPendente = 0.5;

/// Indica que [limiarConfiancaBaixaPendente] ainda não foi definido por medição.
/// Mudar para `false` só quando o valor vier da validação do modelo.
const bool limiarConfiancaAindaPendente = true;

/// Regra fixa que transforma a classe do modelo em recomendação.
///
/// - verde → esperar;
/// - de vez → colher se o destino for mercado distante; senão, esperar;
/// - maduro → colher;
/// - passado → colher já ou descartar;
/// - outro, ou confiança abaixo do limiar → pedir nova foto.
///
/// A confiança é a probabilidade (0 a 1) que o modelo deu à classe escolhida.
class RegraDecisao {
  const RegraDecisao({this.limiarConfianca = limiarConfiancaBaixaPendente})
      : assert(limiarConfianca >= 0 && limiarConfianca <= 1);

  /// Confiança mínima para aceitar a classe. Abaixo dela, pede nova foto.
  final double limiarConfianca;

  /// `true` quando a confiança está abaixo do limiar.
  bool confiancaBaixa(double confianca) {
    _validarConfianca(confianca);
    return confianca < limiarConfianca;
  }

  /// `true` quando a recomendação depende do destino do tomate, ou seja,
  /// quando a classe é "de vez" e a confiança é suficiente.
  bool precisaDestino(ClasseMaturacao classe, double confianca) =>
      classe == ClasseMaturacao.deVez && !confiancaBaixa(confianca);

  /// Devolve a recomendação para a [classe] com a [confianca] dada.
  ///
  /// O [destino] só é usado (e é obrigatório) quando [precisaDestino] é
  /// verdadeiro; nos outros casos é ignorado.
  Recomendacao recomendar(
    ClasseMaturacao classe,
    double confianca, {
    Destino? destino,
  }) {
    if (confiancaBaixa(confianca)) return Recomendacao.novaFoto;
    return switch (classe) {
      ClasseMaturacao.verde => Recomendacao.esperar,
      ClasseMaturacao.deVez => _recomendarDeVez(destino),
      ClasseMaturacao.maduro => Recomendacao.colher,
      ClasseMaturacao.passado => Recomendacao.colherJaOuDescartar,
      ClasseMaturacao.outro => Recomendacao.novaFoto,
    };
  }

  static Recomendacao _recomendarDeVez(Destino? destino) {
    if (destino == null) {
      throw ArgumentError.value(
        destino,
        'destino',
        'é obrigatório quando a classe é "de vez"',
      );
    }
    return destino == Destino.mercadoDistante
        ? Recomendacao.colher
        : Recomendacao.esperar;
  }

  static void _validarConfianca(double confianca) {
    if (confianca.isNaN || confianca < 0 || confianca > 1) {
      throw ArgumentError.value(
        confianca,
        'confianca',
        'deve estar entre 0 e 1',
      );
    }
  }
}
