import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../domain/entities/note_entity.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).trash),
            actions: [
              if (provider.trashedNotes.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: AppLocalizations.of(context).emptyTrash,
                  onPressed: () => _confirmEmptyTrash(context, provider),
                ),
            ],
          ),
          body: provider.trashedNotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 100,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).trashEmpty,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: provider.trashedNotes.length,
                  itemBuilder: (context, index) {
                    final note = provider.trashedNotes[index];
                    return NoteCard(
                      note: NoteEntity(
                        id: note.id,
                        title: note.title,
                        content: note.content,
                        noteType: note.noteType == 'checklist'
                            ? NoteType.checklist
                            : NoteType.text,
                        color: note.color,
                        isPinned: note.isPinned,
                        isArchived: note.isArchived,
                        createdAt: DateTime.parse(note.createdAt),
                        updatedAt: DateTime.parse(note.updatedAt),
                      ),
                      isTrash: true,
                      onRestore: () => provider.restoreNote(note.id),
                      onPermanentDelete: () =>
                          _confirmPermanentDelete(context, provider, note.id),
                    );
                  },
                ),
        );
      },
    );
  }

  void _confirmEmptyTrash(BuildContext context, NoteProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).emptyTrash),
        content:
            Text(AppLocalizations.of(context).emptyTrashConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              provider.emptyTrash();
              Navigator.of(ctx).pop();
            },
            child: Text(
              AppLocalizations.of(context).delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPermanentDelete(
      BuildContext context, NoteProvider provider, int noteId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).permanentDelete),
        content:
            Text(AppLocalizations.of(context).permanentDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              provider.permanentlyDeleteNote(noteId);
              Navigator.of(ctx).pop();
            },
            child: Text(
              AppLocalizations.of(context).delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
