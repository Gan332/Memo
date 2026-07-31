import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../data/database/app_database.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import 'package:provider/provider.dart';
import '../state/providers/note_provider.dart';

class NoteCard extends StatelessWidget {
  final NoteRow note;
  final VoidCallback onTap;
  final bool isTrash;
  final VoidCallback? onRestore;
  final VoidCallback? onPermanentDelete;
  final String? searchQuery;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.isTrash = false,
    this.onRestore,
    this.onPermanentDelete,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<NoteProvider>();
    final isSelected = provider.isMultiSelectMode &&
        provider.selectedNoteIds.contains(note.id);
    final color = AppColors.backgroundColor(
      note.color,
      Theme.of(context).brightness,
    );
    final onColor = AppColors.onBackgroundColor(
      note.color,
      Theme.of(context).brightness,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: isTrash
          ? _buildTrashCard(context, color, onColor)
          : provider.isMultiSelectMode
              ? _buildMultiSelectCard(context, isSelected, color, onColor, l10n)
              : _buildNormalCard(context, color, onColor, l10n),
    );
  }

  Widget _buildMultiSelectCard(
    BuildContext context,
    bool isSelected,
    Color color,
    Color onColor,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<NoteProvider>().toggleNoteSelection(note.id);
      },
      child: Card(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : color,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) {
                  context.read<NoteProvider>().toggleNoteSelection(note.id);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedText(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: onColor,
                          ),
                      maxLines: 1,
                    ),
                    if (note.content.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildHighlightedText(
                        note.content,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: onColor.withOpacity(0.7),
                            ),
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormalCard(
    BuildContext context,
    Color color,
    Color onColor,
    AppLocalizations l10n,
  ) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              context.read<NoteProvider>().togglePin(note.id, note.isPinned);
            },
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            icon: note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
            label: note.isPinned ? l10n.unpin : l10n.pin,
          ),
          SlidableAction(
            onPressed: (_) {
              context.read<NoteProvider>().toggleArchive(note.id, false);
            },
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor:
                Theme.of(context).colorScheme.onSecondaryContainer,
            icon: Icons.archive,
            label: l10n.archive,
          ),
          SlidableAction(
            onPressed: (_) => _confirmDelete(context, l10n),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            icon: Icons.delete_outline,
            label: l10n.delete,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () {
          context.read<NoteProvider>().enterMultiSelectMode();
          context.read<NoteProvider>().toggleNoteSelection(note.id);
        },
        child: Card(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (note.isPinned) ...[
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (note.noteType == 'checklist') ...[
                      Icon(
                        Icons.checklist,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (note.reminderTimestamp != null &&
                        note.reminderFired != true) ...[
                      Icon(
                        Icons.notifications_active,
                        size: 16,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: _buildHighlightedText(
                        note.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: onColor,
                                ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 48),
                    child: MarkdownBody(
                      data: note.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: onColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        h1: TextStyle(
                          color: onColor.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: TextStyle(
                          color: onColor.withOpacity(0.7),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      fitContent: true,
                      softLineBreak: true,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      formatRelativeDateFromIso(note.updatedAt, l10n),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: onColor.withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrashCard(
    BuildContext context,
    Color color,
    Color onColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: onColor,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 48),
                  child: MarkdownBody(
                    data: note.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: onColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      h1: TextStyle(
                        color: onColor.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: TextStyle(
                        color: onColor.withOpacity(0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    fitContent: true,
                    softLineBreak: true,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    note.deletedAt != null
                        ? '${AppLocalizations.of(context).deletedAt} ${formatRelativeDateFromIso(note.deletedAt!, AppLocalizations.of(context))}'
                        : '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onColor.withOpacity(0.5),
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.restore_from_trash),
                    tooltip: AppLocalizations.of(context).restore,
                    onPressed: onRestore,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_forever,
                        color: Theme.of(context).colorScheme.error),
                    tooltip: AppLocalizations.of(context).permanentDelete,
                    onPressed: onPermanentDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build text with search result highlighting when [searchQuery] is set.
  Widget _buildHighlightedText(
    String text, {
    required TextStyle? style,
    int maxLines = 1,
  }) {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final query = searchQuery!.toLowerCase();
    final lower = text.toLowerCase();
    final spans = <InlineSpan>[];
    int start = 0;

    while (true) {
      final index = lower.indexOf(query, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style?.copyWith(
          backgroundColor: Colors.yellow.withOpacity(0.4),
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + query.length;
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteNoteTitle),
        content: Text(l10n.deleteNoteConfirm(note.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<NoteProvider>();
      final deletedNote = note;
      await provider.deleteNote(note.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deletedNote(deletedNote.title)),
            action: SnackBarAction(
              label: l10n.undo,
              onPressed: () {
                provider.restoreNote(deletedNote.id);
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
