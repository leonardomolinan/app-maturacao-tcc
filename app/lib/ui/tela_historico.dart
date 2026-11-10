import 'package:flutter/material.dart';

import '../dados/analise.dart';
import '../dependencias.dart';
import 'apresentacao.dart';

/// Lista das análises guardadas no aparelho.
class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key, required this.dependencias});

  final Dependencias dependencias;

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  List<Analise>? _analises;
  Object? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final analises = await widget.dependencias.repositorio.listar();
      if (mounted) setState(() => _analises = analises);
    } catch (erro) {
      if (mounted) setState(() => _erro = erro);
    }
  }

  Future<bool> _confirmarApagar() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Apagar análise?'),
        content: const Text('A análise e a foto serão apagadas do aparelho.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    return confirmou ?? false;
  }

  Future<void> _apagar(Analise analise) async {
    setState(() => _analises?.remove(analise));
    try {
      await widget.dependencias.repositorio.apagar(analise.id!);
      await widget.dependencias.fotos.apagar(analise.caminhoFoto);
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível apagar: $erro')),
      );
      await _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: SafeArea(child: _conteudo(context)),
    );
  }

  Widget _conteudo(BuildContext context) {
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Não foi possível ler o histórico: $_erro'),
        ),
      );
    }
    final analises = _analises;
    if (analises == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (analises.isEmpty) {
      return const Center(child: Text('Nenhuma análise ainda.'));
    }
    final fotos = widget.dependencias.fotos;
    return ListView.separated(
      itemCount: analises.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, indice) {
        if (indice == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              '${analises.length} análise(s). Arraste para a esquerda para apagar.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        final analise = analises[indice - 1];
        final destino = analise.destino;
        return Dismissible(
          key: ValueKey(analise.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmarApagar(),
          onDismissed: (_) => _apagar(analise),
          background: Container(
            color: Theme.of(context).colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
          ),
          child: ListTile(
            isThreeLine: true,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(
                dimension: 56,
                child: Image.file(
                  fotos.arquivo(analise.caminhoFoto),
                  fit: BoxFit.cover,
                  cacheWidth: 168,
                  errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            title: Text(
              '${analise.classe.nome} · ${formatarPercentual(analise.confianca)}',
            ),
            subtitle: Text(
              '${analise.recomendacao.nome}'
              '${destino != null ? ' (${destino.nome})' : ''}\n'
              '${formatarDataHora(analise.dataHora)}',
            ),
          ),
        );
      },
    );
  }
}
