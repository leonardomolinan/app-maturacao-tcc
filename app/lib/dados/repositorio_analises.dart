import 'package:sqflite/sqflite.dart';

import '../dominio/destino.dart';
import '../dominio/recomendacao.dart';
import 'analise.dart';

/// Acesso ao histórico de análises.
abstract interface class RepositorioAnalises {
  /// Grava a análise e devolve o `id` gerado.
  Future<int> inserir(Analise analise);

  /// Atualiza a recomendação e o destino (quando o produtor muda o destino
  /// de um tomate "de vez" depois de gravar).
  Future<void> atualizarDecisao(
    int id, {
    required Recomendacao recomendacao,
    Destino? destino,
  });

  /// Lista as análises, da mais recente para a mais antiga.
  Future<List<Analise>> listar();

  /// Apaga a análise (o arquivo da foto é apagado por quem chama).
  Future<void> apagar(int id);
}

class RepositorioAnalisesSqlite implements RepositorioAnalises {
  RepositorioAnalisesSqlite(this._db);

  final Database _db;

  @override
  Future<int> inserir(Analise analise) =>
      _db.insert('analise', analise.paraLinha());

  @override
  Future<void> atualizarDecisao(
    int id, {
    required Recomendacao recomendacao,
    Destino? destino,
  }) =>
      _db.update(
        'analise',
        {'recomendacao': recomendacao.codigo, 'destino': destino?.codigo},
        where: 'id = ?',
        whereArgs: [id],
      );

  @override
  Future<List<Analise>> listar() async {
    final linhas = await _db.query('analise', orderBy: 'data_hora DESC, id DESC');
    return [for (final linha in linhas) Analise.daLinha(linha)];
  }

  @override
  Future<void> apagar(int id) =>
      _db.delete('analise', where: 'id = ?', whereArgs: [id]);
}
