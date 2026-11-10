import 'package:flutter/material.dart';

import '../classificador/classificador.dart';
import '../dados/analise.dart';
import '../dependencias.dart';
import '../dominio/classe_maturacao.dart';
import '../dominio/destino.dart';
import '../dominio/recomendacao.dart';
import '../dominio/regra_decisao.dart';
import 'apresentacao.dart';
import 'guia_enquadramento.dart';
import 'tela_historico.dart';

/// Mostra a classe, a confiança e a recomendação, e grava no histórico.
///
/// O destino do tomate só é perguntado quando a classe é "de vez"; nesse caso
/// a análise é gravada quando o produtor responde.
class TelaResultado extends StatefulWidget {
  const TelaResultado({
    super.key,
    required this.dependencias,
    required this.info,
    required this.resultado,
    required this.caminhoFoto,
    required this.dataHora,
  });

  final Dependencias dependencias;
  final InfoModelo info;
  final ResultadoClassificacao resultado;

  /// Caminho da foto, relativo à pasta de documentos do app.
  final String caminhoFoto;
  final DateTime dataHora;

  @override
  State<TelaResultado> createState() => _TelaResultadoState();
}

class _TelaResultadoState extends State<TelaResultado> {
  Destino? _destino;
  int? _idSalvo;
  String? _erroAoSalvar;

  /// Encadeia as gravações para não inserir duas vezes a mesma análise.
  Future<void> _gravacao = Future.value();

  RegraDecisao get _regra => widget.dependencias.regra;
  ResultadoClassificacao get _resultado => widget.resultado;

  bool get _confiancaBaixa => _regra.confiancaBaixa(_resultado.confianca);

  bool get _precisaDestino =>
      _regra.precisaDestino(_resultado.classe, _resultado.confianca);

  Recomendacao? get _recomendacao => _precisaDestino && _destino == null
      ? null
      : _regra.recomendar(
          _resultado.classe,
          _resultado.confianca,
          destino: _destino,
        );

  @override
  void initState() {
    super.initState();
    if (!_precisaDestino) _salvar();
  }

  void _escolherDestino(Destino destino) {
    setState(() => _destino = destino);
    _salvar();
  }

  void _salvar() {
    final recomendacao = _recomendacao!;
    final destino = _destino;
    final repositorio = widget.dependencias.repositorio;
    _gravacao = _gravacao.then((_) async {
      try {
        final id = _idSalvo;
        if (id == null) {
          _idSalvo = await repositorio.inserir(
            Analise(
              dataHora: widget.dataHora,
              caminhoFoto: widget.caminhoFoto,
              classe: _resultado.classe,
              confianca: _resultado.confianca,
              recomendacao: recomendacao,
              destino: destino,
              versaoModelo: widget.info.versao,
              tempoInferenciaMs: _resultado.tempoInferencia.inMilliseconds,
            ),
          );
        } else {
          await repositorio.atualizarDecisao(
            id,
            recomendacao: recomendacao,
            destino: destino,
          );
        }
        if (mounted && _erroAoSalvar != null) {
          setState(() => _erroAoSalvar = null);
        }
      } catch (erro) {
        if (mounted) setState(() => _erroAoSalvar = '$erro');
      }
    });
  }

  String _rodape() {
    final partes = [
      'Modelo ${widget.info.versao}',
      'inferência em ${_resultado.tempoInferencia.inMilliseconds} ms no aparelho',
    ];
    if (limiarConfiancaAindaPendente) {
      partes.add(
        'limiar de confiança ${formatarPercentual(_regra.limiarConfianca)} '
        '(provisório, a definir na validação)',
      );
    }
    return partes.join(' · ');
  }

  String _explicacao() {
    if (_confiancaBaixa) {
      return 'O modelo não teve confiança suficiente nesta foto. Tire outra '
          'para ter uma análise segura.';
    }
    return switch (_resultado.classe) {
      ClasseMaturacao.verde => 'O tomate ainda está verde.',
      ClasseMaturacao.deVez => _destino == Destino.mercadoDistante
          ? 'O tomate continua amadurecendo depois de colhido. Para mercado '
              'distante, colha agora.'
          : 'Para venda perto ou consumo próprio, deixe amadurecer mais no pé.',
      ClasseMaturacao.maduro => 'O tomate está maduro.',
      ClasseMaturacao.passado => 'O tomate passou do ponto.',
      ClasseMaturacao.outro => 'O modelo não reconheceu um tomate na foto.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final recomendacao = _recomendacao;
    final probabilidades = _resultado.probabilidades.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: SizedBox(
                width: 240,
                child: MolduraEnquadramento(
                  child: Image.file(
                    widget.dependencias.fotos.arquivo(widget.caminhoFoto),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _CartaoClasse(
              classe: _resultado.classe,
              confianca: _resultado.confianca,
              confiancaBaixa: _confiancaBaixa,
            ),
            if (_precisaDestino) ...[
              const SizedBox(height: 8),
              _PerguntaDestino(
                selecionado: _destino,
                aoEscolher: _escolherDestino,
              ),
            ],
            if (recomendacao != null) ...[
              const SizedBox(height: 8),
              _CartaoRecomendacao(
                recomendacao: recomendacao,
                explicacao: _explicacao(),
              ),
            ],
            if (recomendacao == Recomendacao.novaFoto) ...[
              const SizedBox(height: 8),
              const _DicasNovaFoto(),
            ],
            if (_erroAoSalvar != null) ...[
              const SizedBox(height: 8),
              Text(
                'Não foi possível salvar no histórico: $_erroAoSalvar',
                style: TextStyle(color: tema.colorScheme.error),
              ),
            ],
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text('Probabilidade de cada classe'),
              tilePadding: EdgeInsets.zero,
              children: [
                for (final entrada in probabilidades)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.circle, size: 14, color: corDaClasse(entrada.key)),
                    title: Text(entrada.key.nome),
                    trailing: Text(formatarPercentual(entrada.value)),
                  ),
              ],
            ),
            Text(_rodape(), style: tema.textTheme.bodySmall),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Nova análise'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      TelaHistorico(dependencias: widget.dependencias),
                ),
              ),
              icon: const Icon(Icons.history),
              label: const Text('Ver histórico'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoClasse extends StatelessWidget {
  const _CartaoClasse({
    required this.classe,
    required this.confianca,
    required this.confiancaBaixa,
  });

  final ClasseMaturacao classe;
  final double confianca;
  final bool confiancaBaixa;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(Icons.circle, size: 32, color: corDaClasse(classe)),
        title: Text(
          confiancaBaixa ? 'Classe mais provável: ${classe.nome}' : classe.nome,
          style: tema.textTheme.titleLarge,
        ),
        subtitle: Text(
          'Confiança: ${formatarPercentual(confianca)}'
          '${confiancaBaixa ? ' (baixa)' : ''}',
        ),
      ),
    );
  }
}

class _PerguntaDestino extends StatelessWidget {
  const _PerguntaDestino({required this.selecionado, required this.aoEscolher});

  final Destino? selecionado;
  final ValueChanged<Destino> aoEscolher;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Para onde vai este tomate?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text('A recomendação para o tomate de vez depende do destino.'),
            const SizedBox(height: 12),
            for (final destino in Destino.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: destino == selecionado
                    ? FilledButton(
                        onPressed: () => aoEscolher(destino),
                        child: Text(destino.nome, textAlign: TextAlign.center),
                      )
                    : OutlinedButton(
                        onPressed: () => aoEscolher(destino),
                        child: Text(destino.nome, textAlign: TextAlign.center),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartaoRecomendacao extends StatelessWidget {
  const _CartaoRecomendacao({
    required this.recomendacao,
    required this.explicacao,
  });

  final Recomendacao recomendacao;
  final String explicacao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      color: tema.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              iconeDaRecomendacao(recomendacao),
              size: 40,
              color: tema.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recomendacao.nome,
                    style: tema.textTheme.headlineSmall?.copyWith(
                      color: tema.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    explicacao,
                    style: TextStyle(color: tema.colorScheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DicasNovaFoto extends StatelessWidget {
  const _DicasNovaFoto();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dicas para a nova foto', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final dica in dicasDeFoto) Text('•  $dica'),
          ],
        ),
      ),
    );
  }
}
