import 'package:flutter/material.dart';

import '../../../application/sync/save_service.dart';
import '../../../core/time/instant_format.dart';
import '../../../domain/sync/merge_planner.dart';
import '../../format/sync_labels.dart';

/// Prévia da importação de um save (SPEC §10.3, passo 3): alterações por
/// tabela, conflitos (com a escolha da versão), unificações e possíveis
/// duplicatas. Devolve as escolhas dos conflitos ao confirmar, ou `null`.
class ImportPreviewDialog extends StatefulWidget {
  const ImportPreviewDialog({
    required this.preview,
    this.thenExport = false,
    this.recheck,
    super.key,
  });

  final ImportPreview preview;

  /// Recalcula os avisos de consistência com outras escolhas de conflito.
  final Future<List<ImportWarning>> Function(Map<RowRef, MergeSide> choices)?
  recheck;

  /// "Importar e gerar novo save": o botão muda de nome.
  final bool thenExport;

  @override
  State<ImportPreviewDialog> createState() => _ImportPreviewDialogState();
}

class _ImportPreviewDialogState extends State<ImportPreviewDialog> {
  late final Map<RowRef, MergeSide> _choices = {
    for (final c in widget.preview.plan.conflicts) c.ref: c.defaultSide,
  };
  late List<ImportWarning> _warnings = widget.preview.warnings;
  bool _checking = false;
  int _checkSeq = 0;

  void _choose(RowRef ref, MergeSide side) {
    setState(() => _choices[ref] = side);
    final recheck = widget.recheck;
    if (recheck == null) return;
    final seq = ++_checkSeq;
    setState(() => _checking = true);
    recheck(Map.of(_choices)).then(
      (warnings) {
        if (!mounted || seq != _checkSeq) return;
        setState(() {
          _warnings = warnings;
          _checking = false;
        });
      },
      onError: (Object _) {
        if (mounted && seq == _checkSeq) setState(() => _checking = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = widget.preview;
    final plan = preview.plan;
    final m = preview.manifest;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final sections = <Widget>[
      Text(
        'Arquivo ${preview.fileName}, gerado em ${m.deviceName} em '
        '${SyncLabels.instant(m.createdAt)} (Patrion ${m.appVersion}).',
        style: muted,
      ),
      if (preview.fromThisDevice)
        const _Note(
          icon: Icons.info_outline,
          text:
              'Este save foi gerado por este mesmo computador. Importá-lo não '
              'traz nada de outro PC.',
        ),
      if (preview.upgradedFromOlderSchema)
        _Note(
          icon: Icons.info_outline,
          text:
              'O save é de uma versão anterior do banco (schema '
              '${m.schemaVersion}) e foi convertido para a atual.',
        ),
      if (_checking)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: LinearProgressIndicator(),
        ),
      if (_warnings.isNotEmpty) _WarningsCard(warnings: _warnings),
      const SizedBox(height: 16),
      if (plan.isEmpty)
        const _Note(
          icon: Icons.check_circle_outline,
          text:
              'Nenhuma alteração: este computador já tem tudo o que está no '
              'arquivo.',
        )
      else ...[
        if (plan.visibleChanges > 0) _ChangesTable(plan: plan),
        if (plan.alreadyDeleted > 0)
          _Note(
            icon: Icons.info_outline,
            text:
                'Também vêm ${plan.alreadyDeleted} '
                '${plan.alreadyDeleted == 1 ? 'registro que já estava excluído' : 'registros que já estavam excluídos'} '
                'no outro computador (por exemplo, cadastros unificados lá). '
                'Nada deste computador é excluído por eles.',
          ),
      ],
      if (plan.conflicts.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text(
          'Conflitos (${plan.conflicts.length})',
          style: theme.textTheme.titleMedium,
        ),
        Text(
          'O mesmo registro foi alterado nos dois computadores desde a última '
          'sincronização. Por padrão fica a versão mais recente; você pode '
          'escolher a outra.',
          style: muted,
        ),
        for (final c in plan.conflicts)
          _ConflictTile(
            conflict: c,
            preview: preview,
            choice: _choices[c.ref]!,
            onChanged: (side) => _choose(c.ref, side),
          ),
      ],
      if (plan.unifications.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text(
          'Cadastros repetidos que serão unificados '
          '(${plan.unifications.length})',
          style: theme.textTheme.titleMedium,
        ),
        Text(
          'Cadastrados nos dois computadores separadamente. Ficam um só, e as '
          'operações dos dois passam a apontar para ele.',
          style: muted,
        ),
        for (final u in plan.unifications)
          ListTile(
            dense: true,
            leading: const Icon(Icons.merge_type),
            title: Text(
              '${SyncLabels.entity(u.entity)}: '
              '${SyncLabels.describe(u.table, u.canonical)}',
            ),
          ),
      ],
      if (plan.duplicates.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text(
          'Possíveis operações duplicadas (${plan.duplicates.length})',
          style: theme.textTheme.titleMedium,
        ),
        Text(
          'Mesma data, ativo, tipo, quantidade e preço. Nada é apagado: '
          'confira em Operações e exclua a repetida, se for o caso.',
          style: muted,
        ),
        for (final d in plan.duplicates)
          ListTile(
            dense: true,
            leading: Icon(
              Icons.content_copy,
              color: theme.colorScheme.error,
              semanticLabel: 'Possível duplicata',
            ),
            title: Text(
              '${d.operations.length}× '
              '${SyncLabels.describe('operations', d.operations.first)}',
            ),
          ),
      ],
      const SizedBox(height: 16),
      Text(
        'Antes de aplicar, o app faz um backup automático deste computador. '
        'A importação é feita de uma vez: se algo falhar, nada é alterado.',
        style: muted,
      ),
    ];

    final size = MediaQuery.sizeOf(context);
    return AlertDialog(
      title: const Text('Prévia da importação'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 820,
          minWidth: 560,
          maxHeight: size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_choices),
          child: Text(
            widget.thenExport ? 'Aplicar e gerar novo save' : 'Aplicar',
          ),
        ),
      ],
    );
  }
}

/// Inconsistências que a carteira real passaria a ter. Avisa sem bloquear.
class _WarningsCard extends StatelessWidget {
  const _WarningsCard({required this.warnings});

  final List<ImportWarning> warnings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = warnings.length;
    return Card(
      key: const Key('import-warnings'),
      margin: const EdgeInsets.only(top: 12),
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: theme.colorScheme.onErrorContainer,
                  semanticLabel: 'Atenção',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Depois de aplicar, a carteira fica com $n '
                    '${n == 1 ? 'operação inconsistente' : 'operações inconsistentes'}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            for (final w in warnings)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '• ${SyncLabels.warning(w)}',
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Isso acontece, por exemplo, quando a mesma posição foi alterada '
              'nos dois computadores. Você pode aplicar e corrigir depois em '
              'Operações, ou escolher outra versão nos conflitos abaixo.',
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ChangesTable extends StatelessWidget {
  const _ChangesTable({required this.plan});

  final MergePlan plan;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowHeight: 36,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 40,
      columns: const [
        DataColumn(label: Text('Tabela')),
        DataColumn(label: Text('Novos'), numeric: true),
        DataColumn(label: Text('Alterados'), numeric: true),
        DataColumn(label: Text('Excluídos'), numeric: true),
      ],
      rows: [
        for (final MapEntry(key: table, value: c) in plan.changes.entries)
          if (c.visible > 0)
            DataRow(
              cells: [
                DataCell(Text(SyncLabels.table(table))),
                DataCell(Text('${c.inserted}')),
                DataCell(Text('${c.updated}')),
                DataCell(Text('${c.deleted}')),
              ],
            ),
      ],
    );
  }
}

class _ConflictTile extends StatelessWidget {
  const _ConflictTile({
    required this.conflict,
    required this.preview,
    required this.choice,
    required this.onChanged,
  });

  final SyncConflict conflict;
  final ImportPreview preview;
  final MergeSide choice;
  final ValueChanged<MergeSide> onChanged;

  String _when(String instant) {
    try {
      parseInstant(instant);
      return SyncLabels.instant(instant);
    } on FormatException {
      return instant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schema = preview.schemas[conflict.table]!;
    final diffs = SyncLabels.differences(
      schema,
      conflict.local,
      conflict.incoming,
    );
    String label(MergeSide side, String base) =>
        side == conflict.defaultSide ? '$base (mais recente)' : base;

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${SyncLabels.table(conflict.table)}: '
              '${SyncLabels.describe(conflict.table, conflict.local)}',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  children: [
                    const SizedBox(),
                    Text(
                      'Este computador\n'
                      '${_when(conflict.local['updated_at'] ?? '')}',
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      '${preview.manifest.deviceName}\n'
                      '${_when(conflict.incoming['updated_at'] ?? '')}',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
                for (final (name, local, incoming) in diffs)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16, top: 4),
                        child: Text(name),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(local),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(incoming),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            RadioGroup<MergeSide>(
              groupValue: choice,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              child: Wrap(
                spacing: 16,
                children: [
                  _RadioOption(
                    value: MergeSide.local,
                    label: label(MergeSide.local, 'Manter a deste computador'),
                    onSelected: onChanged,
                  ),
                  _RadioOption(
                    value: MergeSide.incoming,
                    label: label(MergeSide.incoming, 'Usar a recebida'),
                    onSelected: onChanged,
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

class _RadioOption extends StatelessWidget {
  const _RadioOption({
    required this.value,
    required this.label,
    required this.onSelected,
  });

  final MergeSide value;
  final String label;
  final ValueChanged<MergeSide> onSelected;

  // O texto também seleciona a opção.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<MergeSide>(value: value),
          Text(label),
        ],
      ),
    );
  }
}
