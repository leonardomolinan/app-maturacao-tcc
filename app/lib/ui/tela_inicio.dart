import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../classificador/classificador.dart';
import '../dependencias.dart';
import 'apresentacao.dart';
import 'guia_enquadramento.dart';
import 'tela_confirmar_foto.dart';
import 'tela_historico.dart';

/// Tela inicial: guia de enquadramento e escolha da foto.
class TelaInicio extends StatefulWidget {
  const TelaInicio({super.key, required this.dependencias});

  final Dependencias dependencias;

  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

class _TelaInicioState extends State<TelaInicio> {
  late final Future<InfoModelo> _modelo =
      widget.dependencias.classificador.carregar();
  bool _ocupado = false;

  Future<void> _escolherFoto(ImageSource origem, InfoModelo info) async {
    setState(() => _ocupado = true);
    try {
      final foto = await widget.dependencias.fotos.escolher(origem);
      if (foto == null || !mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TelaConfirmarFoto(
            dependencias: widget.dependencias,
            info: info,
            foto: foto,
          ),
        ),
      );
    } on PlatformException catch (erro) {
      if (!mounted) return;
      final onde = origem == ImageSource.camera ? 'a câmera' : 'a galeria';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir $onde: ${erro.message ?? erro.code}')),
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  void _abrirHistorico() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TelaHistorico(dependencias: widget.dependencias),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maturação do tomate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: _abrirHistorico,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<InfoModelo>(
          future: _modelo,
          builder: (context, estado) {
            final info = estado.data;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (estado.connectionState == ConnectionState.waiting)
                  const _CartaoCarregando()
                else if (estado.hasError)
                  AvisoModelo(erro: estado.error!),
                const SizedBox(height: 8),
                Text('Como fotografar', style: tema.textTheme.titleMedium),
                const SizedBox(height: 12),
                const Center(
                  child: SizedBox(width: 220, child: IlustracaoEnquadramento()),
                ),
                const SizedBox(height: 12),
                for (final dica in dicasDeFoto)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(dica)),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: info != null && !_ocupado
                      ? () => _escolherFoto(ImageSource.camera, info)
                      : null,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Tirar foto'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: info != null && !_ocupado
                      ? () => _escolherFoto(ImageSource.gallery, info)
                      : null,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Escolher da galeria'),
                ),
                if (info != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Modelo: ${info.arquivo} · '
                    '${info.classesPorIndice.length} classes · '
                    'roda no aparelho, sem internet',
                    style: tema.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartaoCarregando extends StatelessWidget {
  const _CartaoCarregando();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        title: Text('Carregando o modelo…'),
      ),
    );
  }
}

/// Aviso mostrado quando o modelo não pôde ser carregado.
class AvisoModelo extends StatelessWidget {
  const AvisoModelo({super.key, required this.erro});

  final Object erro;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final (titulo, texto) = switch (erro) {
      ModeloAusenteException() => (
          'Modelo de IA não encontrado',
          'O app ainda não tem o arquivo do modelo (.tflite), então não é '
              'possível analisar fotos. O histórico continua disponível.\n\n'
              'Para quem desenvolve: copie o .tflite exportado pelo notebook de '
              'treino para app/assets/models/ e gere o app de novo.',
        ),
      ModeloInvalidoException(:final mensagem) => (
          'Modelo de IA inválido',
          '$mensagem\n\nSem um modelo válido, não é possível analisar fotos.',
        ),
      _ => (
          'Erro ao carregar o modelo de IA',
          '$erro\n\nSem o modelo, não é possível analisar fotos.',
        ),
    };
    return Card(
      color: esquema.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: esquema.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: esquema.onErrorContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(texto, style: TextStyle(color: esquema.onErrorContainer)),
          ],
        ),
      ),
    );
  }
}
