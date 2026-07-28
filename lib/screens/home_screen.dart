import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/providers/note_provider.dart';
import '../state/providers/tag_provider.dart';
import '../domain/entities/note_entity.dart';
import '../widgets/note_card.dart';
import '../widgets/filter_menu.dart';
import 'add_edit_note_screen.dart';
import 'archive_screen.dart';
import 'tag_manage_screen.dart';
import 'settings_screen.dart';

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
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.note_outlined),
                  selectedIcon: Icon(Icons.note),
                  label: '笔记',
                ),
                NavigationDestination(
                  icon: Icon(Icons.archive_outlined),
                  selectedIcon: Icon(Icons.archive),
                  label: '归档',
                ),
                NavigationDestination(
                  icon: Icon(Icons.label_outlined),
                  selectedIcon: Icon(Icons.label),
                  label: '标签',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: '设置',
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNote(),
        tooltip: '新建笔记',
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
              tooltip: '新建笔记',
            ),
          ),
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.note_outlined),
              selectedIcon: Icon(Icons.note),
              label: Text('笔记'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.archive_outlined),
              selectedIcon: Icon(Icons.archive),
              label: Text('归档'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.label_outlined),
              selectedIcon: Icon(Icons.label),
              label: Text('标签'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('设置'),
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
              decoration: const InputDecoration(
                hintText: '搜索笔记...',
                border: InputBorder.none,
              ),
              onChanged: _onSearchChanged,
            )
          : const Text('备忘录'),
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
            isSearching ? '没有找到匹配的笔记' : '还没有笔记',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching ? '试试其他搜索词或筛选条件' : '点击右下角 + 创建第一条笔记',
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
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
