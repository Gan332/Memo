import 'package:flutter/material.dart';

import '../domain/entities/tag_entity.dart';

class FilterMenu extends StatefulWidget {
  final Function(bool? archived, bool? pinned, String? noteType, int? tagId)
      onApplyFilter;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '筛选笔记',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('置顶'),
                selected: _pinned == true,
                onSelected: (selected) {
                  setState(() => _pinned = selected ? true : null);
                },
              ),
              FilterChip(
                label: const Text('文本'),
                selected: _noteType == 'text',
                onSelected: (selected) {
                  setState(() => _noteType = selected ? 'text' : null);
                },
              ),
              FilterChip(
                label: const Text('清单'),
                selected: _noteType == 'checklist',
                onSelected: (selected) {
                  setState(() => _noteType = selected ? 'checklist' : null);
                },
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
                child: const Text('清除筛选'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  widget.onApplyFilter(_archived, _pinned, _noteType, _tagId);
                },
                child: const Text('应用'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
