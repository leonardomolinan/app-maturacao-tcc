import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../dominio/classe_maturacao.dart';
import '../dominio/destino.dart';
import '../dominio/recomendacao.dart';

/// Banco SQLite local com o histórico de análises. É a base do MER da
/// monografia: hoje tem uma única tabela, `analise`.
class BancoAnalises {
  static const nomeArquivo = 'analises.db';
  static const versao = 1;

  static String _lista(Iterable<String> valores) =>
      valores.map((v) => "'$v'").join(', ');

  /// Esquema da tabela `analise`.
  static final ddlAnalise = '''
CREATE TABLE analise (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  data_hora TEXT NOT NULL,
  caminho_foto TEXT NOT NULL,
  classe TEXT NOT NULL
    CHECK (classe IN (${_lista(ClasseMaturacao.values.map((c) => c.rotulo))})),
  confianca REAL NOT NULL CHECK (confianca >= 0 AND confianca <= 1),
  recomendacao TEXT NOT NULL
    CHECK (recomendacao IN (${_lista(Recomendacao.values.map((r) => r.codigo))})),
  destino TEXT
    CHECK (destino IS NULL OR destino IN (${_lista(Destino.values.map((d) => d.codigo))})),
  versao_modelo TEXT NOT NULL,
  tempo_inferencia_ms INTEGER
)''';

  /// Abre (e cria, na primeira vez) o banco do app.
  ///
  /// [fabrica] e [caminho] existem para os testes usarem um banco em memória.
  static Future<Database> abrir({
    DatabaseFactory? fabrica,
    String? caminho,
  }) async {
    final f = fabrica ?? databaseFactory;
    final destino = caminho ?? p.join(await f.getDatabasesPath(), nomeArquivo);
    return f.openDatabase(
      destino,
      options: OpenDatabaseOptions(
        version: versao,
        onCreate: (db, _) async {
          await db.execute(ddlAnalise);
          await db.execute(
            'CREATE INDEX idx_analise_data_hora ON analise (data_hora)',
          );
        },
      ),
    );
  }
}
