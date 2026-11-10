import 'package:flutter/material.dart';

/// Moldura quadrada com cantos marcados, usada como guia de enquadramento.
///
/// O modelo analisa o quadrado central da foto; por isso as fotos aparecem
/// recortadas em quadrado, com esta moldura por cima.
class MolduraEnquadramento extends StatelessWidget {
  const MolduraEnquadramento({super.key, required this.child, this.cor});

  final Widget child;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            IgnorePointer(
              child: CustomPaint(
                painter: _CantosPainter(cor ?? Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ilustração do enquadramento ideal: um tomate no centro, ocupando boa parte
/// do quadrado.
class IlustracaoEnquadramento extends StatelessWidget {
  const IlustracaoEnquadramento({super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Exemplo de enquadramento: um tomate no centro do quadrado',
      child: MolduraEnquadramento(
        cor: esquema.primary,
        child: ColoredBox(
          color: esquema.surfaceContainerHighest,
          child: const FractionallySizedBox(
            widthFactor: 0.62,
            heightFactor: 0.62,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CantosPainter extends CustomPainter {
  _CantosPainter(this.cor);

  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final margem = size.shortestSide * 0.06;
    final braco = size.shortestSide * 0.16;
    final esq = margem;
    final topo = margem;
    final dir = size.width - margem;
    final base = size.height - margem;
    final caminho = Path()
      ..moveTo(esq, topo + braco)
      ..lineTo(esq, topo)
      ..lineTo(esq + braco, topo)
      ..moveTo(dir - braco, topo)
      ..lineTo(dir, topo)
      ..lineTo(dir, topo + braco)
      ..moveTo(dir, base - braco)
      ..lineTo(dir, base)
      ..lineTo(dir - braco, base)
      ..moveTo(esq + braco, base)
      ..lineTo(esq, base)
      ..lineTo(esq, base - braco);
    canvas.drawPath(caminho, pincel);
  }

  @override
  bool shouldRepaint(_CantosPainter antigo) => antigo.cor != cor;
}
