import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maturacao_tomate/app.dart';
import 'package:maturacao_tomate/classificador/classificador.dart';
import 'package:maturacao_tomate/dependencias.dart';
import 'package:maturacao_tomate/dominio/classe_maturacao.dart';
import 'package:maturacao_tomate/dominio/destino.dart';
import 'package:maturacao_tomate/dominio/recomendacao.dart';
import 'package:maturacao_tomate/dominio/regra_decisao.dart';
import 'package:maturacao_tomate/fotos/servico_fotos.dart';
import 'package:maturacao_tomate/ui/tela_resultado.dart';

import 'apoio/dubles.dart';

Finder botao(String texto) => find.ancestor(
      of: find.text(texto),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );

bool habilitado(WidgetTester tester, String texto) =>
    tester.widget<ButtonStyleButton>(botao(texto)).enabled;

/// Tela de teste alta o bastante para a lista inteira ser construída (na tela
/// padrão de 800×600, o fim das listas fica fora da área visível).
void usarTelaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  late RepositorioEmMemoria repositorio;
  late Dependencias dependencias;

  setUp(() {
    repositorio = RepositorioEmMemoria();
    dependencias = Dependencias(
      classificador: ClassificadorSemModelo(),
      repositorio: repositorio,
      fotos: ServicoFotos(pastaDocumentos: Directory.systemTemp.path),
      // Limiar fixo só para os testes: não é o valor do app.
      regra: const RegraDecisao(limiarConfianca: 0.6),
    );
  });

  group('tela inicial', () {
    testWidgets('sem modelo: mostra o aviso e desliga a análise', (tester) async {
      usarTelaAlta(tester);
      await tester.pumpWidget(AppMaturacao(dependencias: dependencias));
      await tester.pumpAndSettle();

      expect(find.text('Modelo de IA não encontrado'), findsOneWidget);
      expect(find.textContaining('app/assets/models/'), findsOneWidget);
      expect(habilitado(tester, 'Tirar foto'), isFalse);
      expect(habilitado(tester, 'Escolher da galeria'), isFalse);
    });

    testWidgets('o histórico abre mesmo sem modelo', (tester) async {
      await tester.pumpWidget(AppMaturacao(dependencias: dependencias));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Histórico'));
      await tester.pumpAndSettle();
      expect(find.text('Nenhuma análise ainda.'), findsOneWidget);
    });
  });

  group('tela de resultado', () {
    // Entradas fixas de teste; não são resultados do modelo.
    const info = InfoModelo(
      arquivo: 'modelo_teste.tflite',
      hash: '000000000000',
      classesPorIndice: [ClasseMaturacao.deVez, ClasseMaturacao.maduro],
      larguraEntrada: 224,
      alturaEntrada: 224,
    );

    Future<void> abrir(WidgetTester tester, ClasseMaturacao classe, double confianca) async {
      usarTelaAlta(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: TelaResultado(
            dependencias: dependencias,
            info: info,
            resultado: ResultadoClassificacao(
              classe: classe,
              confianca: confianca,
              probabilidades: {classe: confianca},
              tempoInferencia: const Duration(milliseconds: 5),
            ),
            caminhoFoto: 'fotos/inexistente.jpg',
            dataHora: DateTime(2026, 11, 4, 10),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('maduro: recomenda colher e grava sem perguntar destino', (tester) async {
      await abrir(tester, ClasseMaturacao.maduro, 0.9);
      expect(find.text('Para onde vai este tomate?'), findsNothing);
      expect(find.text('Colher'), findsOneWidget);
      final [analise] = await repositorio.listar();
      expect(analise.recomendacao, Recomendacao.colher);
      expect(analise.destino, isNull);
      expect(analise.versaoModelo, 'modelo_teste.tflite#000000000000');
    });

    testWidgets('de vez: pergunta o destino antes de recomendar e gravar', (tester) async {
      await abrir(tester, ClasseMaturacao.deVez, 0.9);
      expect(find.text('Para onde vai este tomate?'), findsOneWidget);
      expect(find.text('Colher'), findsNothing);
      expect(find.text('Esperar'), findsNothing);
      expect(await repositorio.listar(), isEmpty);

      await tester.tap(find.text(Destino.mercadoDistante.nome));
      await tester.pumpAndSettle();
      expect(find.text('Colher'), findsOneWidget);
      var [analise] = await repositorio.listar();
      expect(analise.destino, Destino.mercadoDistante);
      expect(analise.recomendacao, Recomendacao.colher);

      await tester.tap(find.text(Destino.perto.nome));
      await tester.pumpAndSettle();
      expect(find.text('Esperar'), findsOneWidget);
      [analise] = await repositorio.listar();
      expect(analise.destino, Destino.perto);
      expect(analise.recomendacao, Recomendacao.esperar);
    });

    testWidgets('confiança baixa: pede nova foto, sem perguntar destino', (tester) async {
      await abrir(tester, ClasseMaturacao.deVez, 0.3);
      expect(find.text('Para onde vai este tomate?'), findsNothing);
      expect(find.text('Classe mais provável: ${ClasseMaturacao.deVez.nome}'), findsOneWidget);
      expect(find.text('Tirar nova foto'), findsOneWidget);
      final [analise] = await repositorio.listar();
      expect(analise.recomendacao, Recomendacao.novaFoto);
    });
  });
}
