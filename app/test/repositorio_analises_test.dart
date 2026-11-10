import 'package:flutter_test/flutter_test.dart';
import 'package:maturacao_tomate/dados/analise.dart';
import 'package:maturacao_tomate/dados/banco.dart';
import 'package:maturacao_tomate/dados/repositorio_analises.dart';
import 'package:maturacao_tomate/dominio/classe_maturacao.dart';
import 'package:maturacao_tomate/dominio/destino.dart';
import 'package:maturacao_tomate/dominio/recomendacao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Database banco;
  late RepositorioAnalisesSqlite repositorio;

  setUp(() async {
    banco = await BancoAnalises.abrir(
      fabrica: databaseFactoryFfi,
      caminho: inMemoryDatabasePath,
    );
    repositorio = RepositorioAnalisesSqlite(banco);
  });

  tearDown(() => banco.close());

  // Valores fixos de teste; não são resultados do modelo.
  Analise exemplo({required DateTime quando, Destino? destino}) => Analise(
        dataHora: quando,
        caminhoFoto: 'fotos/teste.jpg',
        classe: ClasseMaturacao.deVez,
        confianca: 0.75,
        recomendacao: Recomendacao.colher,
        destino: destino,
        versaoModelo: 'modelo_teste.tflite#000000000000',
        tempoInferenciaMs: 12,
      );

  test('grava e lê todos os campos', () async {
    final quando = DateTime(2026, 11, 4, 15, 32, 10);
    final id = await repositorio.inserir(exemplo(quando: quando, destino: Destino.mercadoDistante));
    final [lida] = await repositorio.listar();
    expect(lida.id, id);
    expect(lida.dataHora, quando);
    expect(lida.caminhoFoto, 'fotos/teste.jpg');
    expect(lida.classe, ClasseMaturacao.deVez);
    expect(lida.confianca, 0.75);
    expect(lida.recomendacao, Recomendacao.colher);
    expect(lida.destino, Destino.mercadoDistante);
    expect(lida.versaoModelo, 'modelo_teste.tflite#000000000000');
    expect(lida.tempoInferenciaMs, 12);
  });

  test('lista da mais recente para a mais antiga', () async {
    await repositorio.inserir(exemplo(quando: DateTime(2026, 11, 1)));
    await repositorio.inserir(exemplo(quando: DateTime(2026, 11, 3)));
    await repositorio.inserir(exemplo(quando: DateTime(2026, 11, 2)));
    final datas = (await repositorio.listar()).map((a) => a.dataHora.day).toList();
    expect(datas, [3, 2, 1]);
  });

  test('atualiza a decisão quando o destino muda', () async {
    final id = await repositorio.inserir(exemplo(quando: DateTime(2026, 11, 4), destino: Destino.mercadoDistante));
    await repositorio.atualizarDecisao(id, recomendacao: Recomendacao.esperar, destino: Destino.perto);
    final [lida] = await repositorio.listar();
    expect(lida.recomendacao, Recomendacao.esperar);
    expect(lida.destino, Destino.perto);
  });

  test('apaga', () async {
    final id = await repositorio.inserir(exemplo(quando: DateTime(2026, 11, 4)));
    await repositorio.apagar(id);
    expect(await repositorio.listar(), isEmpty);
  });

  test('o esquema recusa classe e confiança fora do domínio', () async {
    final linha = exemplo(quando: DateTime(2026, 11, 4)).paraLinha();
    await expectLater(
      banco.insert('analise', {...linha, 'classe': 'ripe'}),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      banco.insert('analise', {...linha, 'confianca': 1.5}),
      throwsA(isA<DatabaseException>()),
    );
  });
}
