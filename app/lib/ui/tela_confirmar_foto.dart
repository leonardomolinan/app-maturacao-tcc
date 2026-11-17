import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../classificador/classificador.dart';
import '../dependencias.dart';
import '../fotos/servico_fotos.dart';
import 'guia_enquadramento.dart';
import 'tela_resultado.dart';

/// Mostra o quadrado que o modelo vai analisar antes de classificar.
class TelaConfirmarFoto extends StatefulWidget {
  const TelaConfirmarFoto({
    super.key,
    required this.dependencias,
    required this.info,
    required this.foto,
  });

  final Dependencias dependencias;
  final InfoModelo info;
  final XFile foto;

  @override
  State<TelaConfirmarFoto> createState() => _TelaConfirmarFotoState();
}

class _TelaConfirmarFotoState extends State<TelaConfirmarFoto> {
  bool _analisando = false;

  Future<void> _analisar() async {
    setState(() => _analisando = true);
    final deps = widget.dependencias;
    FotoPreparada? preparada;
    try {
      final foto = await deps.fotos.preparar(widget.foto);
      preparada = foto;
      final resultado = await deps.classificador.classificar(foto.bytes);
      final dataHora = DateTime.now();
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => TelaResultado(
            dependencias: deps,
            info: widget.info,
            resultado: resultado,
            caminhoFoto: foto.caminhoRelativo,
            dataHora: dataHora,
          ),
        ),
      );
    } catch (erro) {
      if (preparada != null) await deps.fotos.apagar(preparada.caminhoRelativo);
      if (!mounted) return;
      setState(() => _analisando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível analisar a foto: $erro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conferir enquadramento')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MolduraEnquadramento(
              child: Image.file(
                File(widget.foto.path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Center(child: Icon(Icons.broken_image, size: 48)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'O modelo analisa só este quadrado. Confira se o tomate está no '
              'centro e ocupa boa parte dele.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _analisando ? null : _analisar,
              icon: _analisando
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_analisando ? 'Analisando…' : 'Analisar'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _analisando ? null : () => Navigator.of(context).pop(),
              child: const Text('Escolher outra foto'),
            ),
          ],
        ),
      ),
    );
  }
}
