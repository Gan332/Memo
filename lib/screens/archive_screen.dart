import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../data/database/app_database.dart';
import '../domain/entities/note_entity.dart';
import '../l10n/app_localizations.dart';
import '../screens/add_edit_note_screen.dart';
import '../state/providers/note_provider.dart';
import '../theme/app_colors.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().setFilter(archived: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<NoteProvider>().setFilter(archived: null);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).archiveTitle),
        ),
        body: Consumer<NoteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.archivedNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 100,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).emptyArchive,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.archivedNotes.length,
            itemBuilder: (context, index) {
              final note = provider.archivedNotes[index];
              return _ArchiveNoteCard(
                note: note,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditNoteScreen(
                        note: NoteEntity(
                          id: note.id,
                          title: note.title,
                          content: note.content,
                          noteType: NoteType.values.byName(note.noteType),
                          color: note.color,
                          isPinned: note.isPinned,
                          isArchived: note.isArchived,
                          createdAt: DateTime.parse(note.createdAt),
                          updatedAt: DateTime.parse(note.updatedAt),
                        ),
                      ),
                    ),
                  );
                },
                onRestore: () {
                  provider.toggleArchive(note.id, true);
                  _showUndoSnackBar(context, note);
                },
                onDelete: () {
                  provider.deleteNote(note.id);
                },
              );
            },
          );
        },
      ),
      ),
    );
  }

  void _showUndoSnackBar(BuildContext context, NoteRow note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).restoredNote(note.title)),
        action: SnackBarAction(
          label: AppLocalizations.of(context).undo,
          onPressed: () {
            context.read<NoteProvider>().toggleArchive(note.id, false);
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _ArchiveNoteCard extends StatelessWidget {
  final NoteRow note;
  final VoidCallback onTap;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _ArchiveNoteCard({
    required this.note,
    required this.onTap,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.backgroundColor(
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
              onPressed: (_) => onRestore(),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              icon: Icons.restore,
              label: AppLocalizations.of(context).restore,
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              icon: Icons.delete_outline,
              label: AppLocalizations.of(context).delete,
            ),
          ],
        ),
        child: Card(
          color: color,
          child: InkWell(
            onTap: onTap,
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).archivedAt(note.updatedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
