import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../data/database/app_database.dart';
import '../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../state/providers/note_provider.dart';

class NoteCard extends StatelessWidget {
  final NoteRow note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Slidable(
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
              label: note.isPinned ? '取消置顶' : '置顶',
            ),
            SlidableAction(
              onPressed: (_) {
                context.read<NoteProvider>().toggleArchive(note.id, false);
              },
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onSecondaryContainer,
              icon: Icons.archive,
              label: '归档',
            ),
            SlidableAction(
              onPressed: (_) => _confirmDelete(context),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              icon: Icons.delete_outline,
              label: '删除',
            ),
          ],
        ),
        child: GestureDetector(
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
                      Expanded(
                        child: Text(
                          note.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    Text(
                      note.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: onColor.withOpacity(0.7),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        _formattedDate(note.updatedAt),
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
      ),
    );
  }

  String _formattedDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';
    return '${date.month}/${date.day}';
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除笔记'),
        content: Text('确定要删除「${note.title}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
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
            content: Text('已删除「${deletedNote.title}」'),
            action: SnackBarAction(
              label: '撤销',
              onPressed: () {
                provider.restoreDeletedNote(deletedNote);
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
