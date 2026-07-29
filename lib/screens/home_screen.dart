import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/providers/note_provider.dart';
import '../state/providers/tag_provider.dart';
import '../domain/entities/note_entity.dart';
import '../widgets/note_card.dart';
import '../widgets/filter_menu.dart';
import '../widgets/template_picker.dart';
import 'add_edit_note_screen.dart';
import 'archive_screen.dart';
import 'tag_manage_screen.dart';
import 'settings_screen.dart';
import 'trash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
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
          if (template.name == '空白笔记') {
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
        onApplyFilter: (archived, pinned, noteType, tagId) {
          context.read<NoteProvider>().setFilter(
                archived: archived,
                pinned: pinned,
                noteType: noteType,
                tagId: tagId,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 840;

    return Scaffold(
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
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
                    MaterialPageRoute(builder: (_) => const TrashScreen()),
                  );
                } else if (index == 4) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                }
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.note_outlined),
                  selectedIcon: const Icon(Icons.note),
                  label: AppLocalizations.of(context).textNote,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.archive_outlined),
                  selectedIcon: const Icon(Icons.archive),
                  label: AppLocalizations.of(context).archive,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.label_outlined),
                  selectedIcon: const Icon(Icons.label),
                  label: AppLocalizations.of(context).tagManage,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showTemplatePicker,
        tooltip: AppLocalizations.of(context).newNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        _buildNoteList(),
      ],
    );
  }

  Widget _buildWideLayout() {
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
              icon: const Icon(Icons.archive_outlined),
              selectedIcon: const Icon(Icons.archive),
              label: Text(AppLocalizations.of(context).archive),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.label_outlined),
              selectedIcon: const Icon(Icons.label),
              label: Text(AppLocalizations.of(context).tagManage),
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
                          ? const TrashScreen()
                          : const SettingsScreen(),
        ),
      ],
    );
  }

  Widget _buildNotePanel() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildNoteListBody()),
      ],
    );
  }

  Widget _buildAppBar() {
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
            tooltip: '搜索',
            onPressed: () => setState(() => _isSearching = true),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: '筛选',
            onPressed: _showFilterMenu,
          ),
        ],
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: '清除搜索',
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
        decoration: InputDecoration(
          hintText: '搜索笔记...',
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

  Widget _buildNoteList() {
    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
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

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final note = provider.notes[index];
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
              },
              childCount: provider.notes.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteListBody() {
    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return _buildErrorState(provider);
        }

        if (provider.notes.isEmpty) {
          return _buildEmptyState(provider);
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadNotes(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: provider.notes.length,
            itemBuilder: (context, index) {
              final note = provider.notes[index];
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
            },
          ),
        );
      },
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
