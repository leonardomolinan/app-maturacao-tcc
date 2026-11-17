import 'classificador/classificador.dart';
import 'dados/repositorio_analises.dart';
import 'dominio/regra_decisao.dart';
import 'fotos/servico_fotos.dart';

/// Objetos compartilhados pelas telas. Os testes trocam cada um por uma
/// versão de teste.
class Dependencias {
  const Dependencias({
    required this.classificador,
    required this.repositorio,
    required this.fotos,
    this.regra = const RegraDecisao(),
  });

  final Classificador classificador;
  final RepositorioAnalises repositorio;
  final ServicoFotos fotos;
  final RegraDecisao regra;
}
