import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'dependencias.dart';
import 'ui/tela_inicio.dart';

class AppMaturacao extends StatelessWidget {
  const AppMaturacao({super.key, required this.dependencias});

  final Dependencias dependencias;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maturação do tomate',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      ),
      home: TelaInicio(dependencias: dependencias),
    );
  }
}
