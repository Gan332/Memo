import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/providers/note_provider.dart';
import '../state/providers/tag_provider.dart';
import '../data/database/app_database.dart';
import '../domain/entities/note_entity.dart';
import '../widgets/note_card.dart';
import '../widgets/filter_menu.dart';
import '../data/models/note_template.dart';
import '../widgets/template_picker.dart';
import 'add_edit_note_screen.dart';
import 'archive_screen.dart';
import 'tag_manage_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'trash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().loadNotes();
      context.read<TagProvider>().loadTags();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<NoteProvider>().setSearchQuery(value);
  }

  void _openNote({NoteEntity? note}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditNoteScreen(note: note),
      ),
    );
    if (mounted) {
      context.read<NoteProvider>().loadNotes();
    }
  }

  void _showTemplatePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TemplatePicker(
        onSelect: (template) {
          Navigator.of(context).pop();
          if (template == NoteTemplate.builtIn[0]) {
            _openNote();
          } else {
            _openNote(
              note: NoteEntity(
                title: template.title,
                content: template.content,
                noteType: template.noteType,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
          }
        },
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => FilterMenu(
        onApplyFilter: (archived, pinned, noteType, tagId, hasReminder) {
          context.read<NoteProvider>().setFilter(
                archived: archived,
                pinned: pinned,
                noteType: noteType,
                tagId: tagId,
                hasReminder: hasReminder,
              );
          Navigator.pop(context);
        },
        onClearFilter: () {
          context.read<NoteProvider>().clearFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _focusSearch() {
    setState(() => _isSearching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchController.clear();
    _onSearchChanged('');
    setState(() => _isSearching = false);
  }

  void _handleDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ArchiveScreen()),
      );
    } else if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TagManageScreen()),
      );
    } else if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const StatsScreen()),
      );
    } else if (index == 4) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TrashScreen()),
      );
    } else if (index == 5) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 840;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyN,
          control: true,
        ): _showTemplatePicker,
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
        ): () {
          if (isWide) {
            _searchFocusNode.requestFocus();
          } else if (!_isSearching) {
            _focusSearch();
          }
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_isSearching) {
            _closeSearch();
          } else {
            context.read<NoteProvider>().exitMultiSelectMode();
          }
        },
        const SingleActivator(
          LogicalKeyboardKey.digit1,
          control: true,
        ): () => _handleDestinationSelected(0),
        const SingleActivator(
          LogicalKeyboardKey.digit2,
          control: true,
        ): () => _handleDestinationSelected(1),
        const SingleActivator(
          LogicalKeyboardKey.digit3,
          control: true,
        ): () => _handleDestinationSelected(2),
        const SingleActivator(
          LogicalKeyboardKey.digit4,
          control: true,
        ): () => _handleDestinationSelected(3),
        const SingleActivator(
          LogicalKeyboardKey.digit5,
          control: true,
        ): () => _handleDestinationSelected(4),
        const SingleActivator(
          LogicalKeyboardKey.digit6,
          control: true,
        ): () => _handleDestinationSelected(5),
      },
      child: Focus(
        autofocus: true,
        child: Consumer<NoteProvider>(
          builder: (context, provider, _) {
            return Scaffold(
              body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
              bottomNavigationBar: isWide
                  ? null
                  : NavigationBar(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _handleDestinationSelected,
                      destinations: [
                        NavigationDestination(
                          icon: const Icon(Icons.note_outlined),
                          selectedIcon: const Icon(Icons.note),
                          label: AppLocalizations.of(context).textNote,
                        ),
                        NavigationDestination(
                          icon: Badge(
                            isLabelVisible:
                                provider.archivedNotes.isNotEmpty,
                            label: Text('${provider.archivedNotes.length}'),
                            child: const Icon(Icons.archive_outlined),
                          ),
                          selectedIcon: Badge(
                            isLabelVisible:
                                provider.archivedNotes.isNotEmpty,
                            label: Text('${provider.archivedNotes.length}'),
                            child: const Icon(Icons.archive),
                          ),
                          label: AppLocalizations.of(context).archive,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.label_outlined),
                          selectedIcon: const Icon(Icons.label),
                          label: AppLocalizations.of(context).tagManage,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.insert_chart_outlined),
                          selectedIcon: const Icon(Icons.insert_chart),
                          label: AppLocalizations.of(context).stats,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.delete_outline),
                          selectedIcon: const Icon(Icons.delete),
                          label: AppLocalizations.of(context).trash,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.settings_outlined),
                          selectedIcon: const Icon(Icons.settings),
                          label: AppLocalizations.of(context).settings,
                        ),
                      ],
                    ),
              floatingActionButton: provider.isMultiSelectMode
                  ? null
                  : FloatingActionButton(
                      onPressed: _showTemplatePicker,
                      tooltip: AppLocalizations.of(context).newNote,
                      child: const Icon(Icons.add),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNarrowLayout() {
    final provider = context.watch<NoteProvider>();
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildNoteList(),
            ],
          ),
        ),
        if (provider.isMultiSelectMode) _buildBatchActionBar(context),
      ],
    );
  }

  Widget _buildWideLayout() {
    final archivedCount = context.watch<NoteProvider>().archivedNotes.length;
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: IconButton(
              icon: const Icon(Icons.note_add_outlined),
              onPressed: () => _openNote(),
              tooltip: AppLocalizations.of(context).newNote,
            ),
          ),
          labelType: NavigationRailLabelType.all,
          destinations: [
            NavigationRailDestination(
              icon: const Icon(Icons.note_outlined),
              selectedIcon: const Icon(Icons.note),
              label: Text(AppLocalizations.of(context).textNote),
            ),
            NavigationRailDestination(
              icon: Badge(
                isLabelVisible: archivedCount > 0,
                label: Text('$archivedCount'),
                child: const Icon(Icons.archive_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: archivedCount > 0,
                label: Text('$archivedCount'),
                child: const Icon(Icons.archive),
              ),
              label: Text(AppLocalizations.of(context).archive),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.label_outlined),
              selectedIcon: const Icon(Icons.label),
              label: Text(AppLocalizations.of(context).tagManage),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.insert_chart_outlined),
              selectedIcon: const Icon(Icons.insert_chart),
              label: Text(AppLocalizations.of(context).stats),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.delete_outline),
              selectedIcon: const Icon(Icons.delete),
              label: Text(AppLocalizations.of(context).trash),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: Text(AppLocalizations.of(context).settings),
            ),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedIndex == 0
              ? _buildNotePanel()
              : _selectedIndex == 1
                  ? const ArchiveScreen()
                  : _selectedIndex == 2
                      ? const TagManageScreen()
                      : _selectedIndex == 3
                          ? const StatsScreen()
                          : _selectedIndex == 4
                              ? const TrashScreen()
                              : const SettingsScreen(),
        ),
      ],
    );
  }

  Widget _buildNotePanel() {
    final provider = context.watch<NoteProvider>();
    return Column(
      children: [
        if (provider.isMultiSelectMode)
          _buildWideMultiSelectBar(provider)
        else
          _buildSearchBar(),
        Expanded(child: _buildNoteListBody()),
      ],
    );
  }

  Widget _buildAppBar() {
    final provider = context.watch<NoteProvider>();
    if (provider.isMultiSelectMode) {
      return SliverAppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: provider.exitMultiSelectMode,
        ),
        title: Text(
          AppLocalizations.of(context)
              .selectedCount(provider.selectedNoteIds.length),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: AppLocalizations.of(context).selectAll,
            onPressed: provider.selectAllNotes,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: AppLocalizations.of(context).deselectAll,
            onPressed: provider.deselectAllNotes,
          ),
        ],
      );
    }
    return SliverAppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchHint,
                border: InputBorder.none,
              ),
              onChanged: _onSearchChanged,
            )
          : Text(AppLocalizations.of(context).homeTitle),
      actions: [
        if (!_isSearching) ...[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: AppLocalizations.of(context).searchHint,
            onPressed: () => setState(() => _isSearching = true),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: AppLocalizations.of(context).filterTitle,
            onPressed: _showFilterMenu,
          ),
        ],
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: AppLocalizations.of(context).clearFilters,
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
              setState(() => _isSearching = false);
            },
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildWideMultiSelectBar(NoteProvider provider) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: provider.exitMultiSelectMode,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.selectedCount(provider.selectedNoteIds.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: l10n.selectAll,
            onPressed: provider.selectAllNotes,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: l10n.deselectAll,
            onPressed: provider.deselectAllNotes,
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: l10n.duplicate,
            onPressed: provider.duplicateSelectedNotes,
          ),
        ],
      ),
    );
  }

  Widget _buildBatchActionBar(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.delete,
                onPressed:
                    () => _confirmBatchDelete(context, provider),
              ),
              IconButton(
                icon: const Icon(Icons.archive_outlined),
                tooltip: l10n.archive,
                onPressed: () => provider.archiveSelectedNotes(),
              ),
              IconButton(
                icon: const Icon(Icons.push_pin_outlined),
                tooltip: l10n.pin,
                onPressed: () => provider.pinSelectedNotes(),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined),
                tooltip: l10n.duplicate,
                onPressed: () => provider.duplicateSelectedNotes(),
              ),
              IconButton(
                icon: const Icon(Icons.label_outlined),
                tooltip: l10n.tagManage,
                onPressed:
                    () => _showBatchTagPicker(context, provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmBatchDelete(
      BuildContext context, NoteProvider provider) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.selectedCount(provider.selectedNoteIds.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.deleteSelectedNotes();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showBatchTagPicker(
      BuildContext context, NoteProvider provider) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Consumer<TagProvider>(
        builder: (context, tagProvider, _) {
          if (tagProvider.tags.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l10n.emptyTags)),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tagManage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tagProvider.tags.map((tag) {
                    return FilterChip(
                      label: Text(tag.name),
                      selected: false,
                      onSelected: (_) {
                        final tagId = tag.id;
                        if (tagId != null) {
                          provider.tagSelectedNotes(tagId);
                          Navigator.of(context).pop();
                        }
                      },
                      avatar: CircleAvatar(
                        backgroundColor: tag.backgroundColor,
                        child: const Icon(Icons.label,
                            color: Colors.white, size: 14),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoteList() {
    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
        final l10n = AppLocalizations.of(context);
        if (provider.isLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error.isNotEmpty) {
          return SliverFillRemaining(
            child: _buildErrorState(provider),
          );
        }

        if (provider.notes.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(provider),
          );
        }

        final pinnedNotes = provider.notes.where((n) => n.isPinned).toList();
        final unpinnedNotes = provider.notes.where((n) => !n.isPinned).toList();

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _sectionedNoteChild(provider, index, l10n);
              },
              childCount: _sectionedItemCount(
                pinnedNotes.isNotEmpty,
                pinnedNotes.length,
                unpinnedNotes.length,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteListBody() {
    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
        final l10n = AppLocalizations.of(context);
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return _buildErrorState(provider);
        }

        if (provider.notes.isEmpty) {
          return _buildEmptyState(provider);
        }

        final pinnedNotes = provider.notes.where((n) => n.isPinned).toList();
        final unpinnedNotes = provider.notes.where((n) => !n.isPinned).toList();
        final hasPinned = pinnedNotes.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () => provider.loadNotes(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: _sectionedItemCount(hasPinned, pinnedNotes.length, unpinnedNotes.length),
            itemBuilder: (context, index) {
              return _sectionedNoteChild(provider, index, l10n);
            },
          ),
        );
      },
    );
  }

  // ── Sectioned list helpers ──────────────────────────────────────

  int _sectionedItemCount(bool hasPinned, int pinnedCount, int unpinnedCount) {
    if (!hasPinned) return unpinnedCount;
    // Header for pinned + pinned items + (header + items for others if any)
    return 1 + pinnedCount + (unpinnedCount > 0 ? 1 + unpinnedCount : 0);
  }

  Widget _sectionedNoteChild(
    NoteProvider provider,
    int index,
    AppLocalizations l10n,
  ) {
    final pinnedNotes = provider.notes.where((n) => n.isPinned).toList();
    final unpinnedNotes = provider.notes.where((n) => !n.isPinned).toList();
    final hasPinned = pinnedNotes.isNotEmpty;

    if (hasPinned) {
      if (index == 0) return _sectionHeader(l10n.pinnedNotes);
      if (index <= pinnedNotes.length) {
        return _noteCardFor(pinnedNotes[index - 1], provider);
      }
      if (index == pinnedNotes.length + 1) {
        if (unpinnedNotes.isEmpty) return const SizedBox.shrink();
        return _sectionHeader(l10n.otherNotes);
      }
      final noteIndex = index - pinnedNotes.length - 2;
      if (noteIndex < unpinnedNotes.length) {
        return _noteCardFor(unpinnedNotes[noteIndex], provider);
      }
      return const SizedBox.shrink();
    }

    if (index >= unpinnedNotes.length) return const SizedBox.shrink();
    return _noteCardFor(unpinnedNotes[index], provider);
  }

  Widget _noteCardFor(NoteRow note, NoteProvider provider) {
    return NoteCard(
      note: note,
      searchQuery: provider.searchQuery,
      onTap: () => _openNote(
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
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildEmptyState(NoteProvider provider) {
    final l10n = AppLocalizations.of(context);
    final isSearching = provider.searchQuery.isNotEmpty || provider.isFiltering;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.note_add_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? l10n.noNotes : l10n.emptyNotes,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching ? '' : l10n.emptyNotesHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(NoteProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              provider.error,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => provider.loadNotes(),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}
