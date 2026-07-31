import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/providers/note_provider.dart';
import '../state/providers/tag_provider.dart';

typedef NoteFilterCallback =
    void Function(bool? archived, bool? pinned, String? noteType, int? tagId,
        bool? hasReminder);

class FilterMenu extends StatefulWidget {
  final NoteFilterCallback onApplyFilter;
  final VoidCallback onClearFilter;

  const FilterMenu({
    super.key,
    required this.onApplyFilter,
    required this.onClearFilter,
  });

  @override
  State<FilterMenu> createState() => _FilterMenuState();
}

class _FilterMenuState extends State<FilterMenu> {
  bool? _archived;
  bool? _pinned;
  String? _noteType;
  int? _tagId;
  bool? _hasReminder;
  late SortBy _sortBy;
  late bool _sortAscending;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<NoteProvider>();
    _archived = provider.filterArchived;
    _pinned = provider.filterPinned;
    _noteType = provider.filterNoteType;
    _tagId = provider.filterTagId;
    _hasReminder = provider.filterHasReminder;
    _sortBy = provider.sortBy;
    _sortAscending = provider.sortAscending;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.filterTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: Text(l10n.pinned),
                selected: _pinned == true,
                onSelected: (selected) {
                  setState(() => _pinned = selected ? true : null);
                },
              ),
              FilterChip(
                label: Text(l10n.hasReminder),
                selected: _hasReminder == true,
                onSelected: (selected) {
                  setState(() => _hasReminder = selected ? true : null);
                },
              ),
              FilterChip(
                label: Text(l10n.textNote),
                selected: _noteType == 'text',
                onSelected: (selected) {
                  setState(() => _noteType = selected ? 'text' : null);
                },
              ),
              FilterChip(
                label: Text(l10n.checklistNote),
                selected: _noteType == 'checklist',
                onSelected: (selected) {
                  setState(() => _noteType = selected ? 'checklist' : null);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<TagProvider>(
            builder: (context, tagProvider, _) {
              if (tagProvider.tags.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tag,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tagProvider.tags.map((tag) {
                      return FilterChip(
                        label: Text(tag.name),
                        selected: _tagId == tag.id,
                        onSelected: (selected) {
                          setState(
                              () => _tagId = selected ? tag.id! : null);
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
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            l10n.sortBy,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SegmentedButton<SortBy>(
            segments: [
              ButtonSegment(
                value: SortBy.updatedAt,
                label: Text(l10n.lastModified),
              ),
              ButtonSegment(
                value: SortBy.createdAt,
                label: Text(l10n.createdAtLabel),
              ),
              ButtonSegment(
                value: SortBy.title,
                label: Text(l10n.titleLabel),
              ),
            ],
            selected: {_sortBy},
            onSelectionChanged: (values) {
              setState(() => _sortBy = values.first);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(l10n.ascending),
              const Spacer(),
              Switch(
                value: _sortAscending,
                onChanged: (value) => setState(() => _sortAscending = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  widget.onClearFilter();
                },
                child: Text(l10n.clearFilters),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  context
                      .read<NoteProvider>()
                      .setSortBy(_sortBy, ascending: _sortAscending);
                  widget.onApplyFilter(
                    _archived,
                    _pinned,
                    _noteType,
                    _tagId,
                    _hasReminder,
                  );
                },
                child: Text(l10n.applyFilters),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
