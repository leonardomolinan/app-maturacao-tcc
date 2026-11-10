import 'package:flutter/material.dart';

import '../dominio/classe_maturacao.dart';
import '../dominio/recomendacao.dart';

/// Confiança como porcentagem, no formato brasileiro (ex.: "87,3%").
String formatarPercentual(double valor) =>
    '${(valor * 100).toStringAsFixed(1).replaceAll('.', ',')}%';

/// Data e hora no formato brasileiro (ex.: "04/11/2026 15:32").
String formatarDataHora(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(data.day)}/${dois(data.month)}/${data.year} '
      '${dois(data.hour)}:${dois(data.minute)}';
}

/// Cor que representa cada classe na interface.
Color corDaClasse(ClasseMaturacao classe) => switch (classe) {
      ClasseMaturacao.verde => const Color(0xFF388E3C),
      ClasseMaturacao.deVez => const Color(0xFFF57C00),
      ClasseMaturacao.maduro => const Color(0xFFD32F2F),
      ClasseMaturacao.passado => const Color(0xFF6D4C41),
      ClasseMaturacao.outro => const Color(0xFF757575),
    };

IconData iconeDaRecomendacao(Recomendacao recomendacao) =>
    switch (recomendacao) {
      Recomendacao.colher => Icons.check_circle,
      Recomendacao.esperar => Icons.hourglass_bottom,
      Recomendacao.colherJaOuDescartar => Icons.warning_amber,
      Recomendacao.novaFoto => Icons.photo_camera,
    };

/// Dicas para uma foto que o modelo consiga analisar.
const dicasDeFoto = [
  'Um tomate por foto, no centro do quadro.',
  'Chegue perto: o tomate deve ocupar boa parte do quadrado.',
  'Prefira luz natural, sem sombra forte nem reflexo do flash.',
  'Se der, use um fundo liso atrás do tomate.',
];
