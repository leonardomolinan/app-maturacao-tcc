import 'classe_maturacao.dart';
import 'destino.dart';
import 'recomendacao.dart';

/// Limiar de confiança baixa: abaixo dele, o app pede uma nova foto.
///
/// Escolhido com as imagens de validação do dataset no notebook
/// `ml/02_limiar_e_paridade.ipynb`, para o modelo `yolo26n_cls_v1`: é o maior
/// valor, de 0,20 a 0,99, em que as imagens de validação com confiança abaixo
/// dele erram mais do que acertam (`ml/resultados/yolo26n_cls_v1/limiar.json`).
/// Se o modelo mudar, o limiar precisa ser escolhido de novo.
const double limiarConfiancaBaixa = 0.47;

/// Indica se [limiarConfiancaBaixa] ainda é provisório. Passou a `false` em
/// 16/11/2026, quando o valor veio da validação do modelo; volte para `true`
/// se trocar o modelo sem escolher o limiar de novo.
const bool limiarConfiancaAindaPendente = false;

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
  const RegraDecisao({this.limiarConfianca = limiarConfiancaBaixa})
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
