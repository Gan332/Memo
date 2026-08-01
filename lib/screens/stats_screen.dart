import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/note_repository.dart';
import '../domain/entities/tag_entity.dart';
import '../l10n/app_localizations.dart';
import '../state/providers/note_provider.dart';
import '../state/providers/tag_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<NoteStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = context.read<NoteProvider>().getStats();
  }

  Future<void> _reloadStats() async {
    await context.read<NoteProvider>().loadNotes();
    if (!mounted) return;
    setState(() {
      _statsFuture = context.read<NoteProvider>().getStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: FutureBuilder<NoteStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildError(context, l10n);
          }
          if (!snapshot.hasData) {
            return Center(child: Text(l10n.noData));
          }
          final stats = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _reloadStats,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _buildOverview(context, stats, l10n),
                const SizedBox(height: 16),
                _buildContentVolume(context, stats, l10n),
                const SizedBox(height: 16),
                _buildTypeDistribution(context, stats, l10n),
                const SizedBox(height: 16),
                _buildCreationTrend(context, stats, l10n),
                const SizedBox(height: 16),
                _buildTagDistribution(context, stats, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(l10n.loadFailed, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _statsFuture = context.read<NoteProvider>().getStats();
              });
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    NoteStats stats,
    AppLocalizations l10n,
  ) {
    return _buildCard(
      context,
      title: l10n.statsOverview,
      child: Row(
        children: [
          _statItem(context, l10n.totalNotes, stats.totalCount,
              Icons.notes, null),
          _statItem(context, l10n.activeNotes, stats.activeCount,
              Icons.edit_note, null),
          _statItem(context, l10n.pinnedStat, stats.pinnedCount,
              Icons.push_pin, null),
        ],
      ),
    );
  }

  Widget _statItem(
    BuildContext context,
    String label,
    int value,
    IconData icon,
    Color? color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentVolume(
    BuildContext context,
    NoteStats stats,
    AppLocalizations l10n,
  ) {
    return _buildCard(
      context,
      title: l10n.contentVolume,
      child: Row(
        children: [
          _statItem(context, l10n.totalWords, stats.totalWords,
              Icons.text_fields, null),
          _statItem(context, l10n.totalChars, stats.totalChars,
              Icons.data_object, null),
          _statItem(
            context,
            l10n.reminderStat,
            stats.reminderCount,
            Icons.notifications_active,
            Theme.of(context).colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDistribution(
    BuildContext context,
    NoteStats stats,
    AppLocalizations l10n,
  ) {
    return _buildCard(
      context,
      title: l10n.typeDistribution,
      child: Column(
        children: [
          _distributionBar(
            context,
            l10n.textNote,
            stats.textCount,
            stats.totalCount,
            Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _distributionBar(
            context,
            l10n.checklistNote,
            stats.checklistCount,
            stats.totalCount,
            Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          _distributionBar(
            context,
            l10n.trash,
            stats.trashedCount,
            stats.totalCount,
            Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _distributionBar(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              '${l10n.notesCount(count)} (${(fraction * 100).toStringAsFixed(0)}%)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildCreationTrend(
    BuildContext context,
    NoteStats stats,
    AppLocalizations l10n,
  ) {
    final maxCount = stats.createdByDay.reduce((a, b) => a > b ? a : b);
    final theme = Theme.of(context);
    final labels = List<String>.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      if (i == 6) return l10n.todayLabel;
      return '${day.month}/${day.day}';
    });

    return _buildCard(
      context,
      title: l10n.creationTrend,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final count = stats.createdByDay[i];
          final height = maxCount == 0
              ? 0.0
              : 80.0 * (count / maxCount);
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (count > 0)
                  Text(
                    '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 2),
                Container(
                  height: height < 4 ? (count > 0 ? 4 : 0) : height,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i == 6
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.45),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTagDistribution(
    BuildContext context,
    NoteStats stats,
    AppLocalizations l10n,
  ) {
    final tagProvider = context.watch<TagProvider>();
    final theme = Theme.of(context);
    final entries = stats.tagUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _buildCard(
      context,
      title: l10n.tagDistribution,
      child: entries.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  l10n.noTagsForStats,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            )
          : Column(
              children: entries.take(10).map((entry) {
                final tag = tagProvider.tags.firstWhere(
                  (t) => t.id == entry.key,
                  orElse: () => TagEntity(
                    name: '#${entry.key}',
                    createdAt: DateTime.now(),
                  ),
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _distributionBar(
                    context,
                    tag.name,
                    entry.value,
                    stats.totalCount,
                    tag.backgroundColor,
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
