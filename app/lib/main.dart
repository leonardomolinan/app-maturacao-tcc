import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'classificador/classificador_litert.dart';
import 'dados/banco.dart';
import 'dados/repositorio_analises.dart';
import 'dependencias.dart';
import 'fotos/servico_fotos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documentos = await getApplicationDocumentsDirectory();
  final banco = await BancoAnalises.abrir();
  runApp(
    AppMaturacao(
      dependencias: Dependencias(
        classificador: ClassificadorLitert(),
        repositorio: RepositorioAnalisesSqlite(banco),
        fotos: ServicoFotos(pastaDocumentos: documentos.path),
      ),
    ),
  );
}
