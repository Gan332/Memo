import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/providers/checklist_provider.dart';
import '../domain/entities/checklist_entity.dart';

class ChecklistEditor extends StatefulWidget {
  final int? noteId;

  const ChecklistEditor({super.key, this.noteId});

  @override
  State<ChecklistEditor> createState() => _ChecklistEditorState();
}

class _ChecklistEditorState extends State<ChecklistEditor> {
  final _newItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChecklistProvider>().loadItems(widget.noteId!);
      });
    }
  }

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _newItemController.text.trim();
    if (text.isEmpty || widget.noteId == null) return;

    context.read<ChecklistProvider>().addItem(widget.noteId!, text);
    _newItemController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<ChecklistProvider>(
          builder: (context, provider, _) {
            if (provider.totalCount > 0) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: provider.progress,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${provider.completedCount}/${provider.totalCount}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Expanded(
          child: Consumer<ChecklistProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.items.length,
                onReorder: (oldIndex, newIndex) {
                  if (widget.noteId == null) return;
                  provider.reorder(oldIndex, newIndex, widget.noteId!);
                },
                itemBuilder: (context, index) {
                  final item = provider.items[index];
                  return _ChecklistTile(
                    key: ValueKey(item.id),
                    item: item,
                    onToggle: () {
                      if (widget.noteId == null) return;
                      provider.toggleItem(
                        item.id!,
                        item.isCompleted,
                        widget.noteId!,
                      );
                    },
                    onDelete: () {
                      if (widget.noteId == null) return;
                      provider.deleteItem(item.id!, widget.noteId!);
                    },
                    onEdit: (newText) {
                      provider.updateItem(item.copyWith(text: newText));
                    },
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newItemController,
                  decoration: const InputDecoration(
                    hintText: '添加清单项...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChecklistTile extends StatefulWidget {
  final ChecklistEntity item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ValueChanged<String> onEdit;

  const _ChecklistTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_ChecklistTile> createState() => _ChecklistTileState();
}

class _ChecklistTileState extends State<_ChecklistTile> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Checkbox(
          value: widget.item.isCompleted,
          onChanged: (_) => widget.onToggle(),
        ),
        title: _isEditing
            ? TextField(
                controller: _controller,
                autofocus: true,
                onSubmitted: (value) {
                  widget.onEdit(value);
                  setState(() => _isEditing = false);
                },
                onTapOutside: (_) {
                  widget.onEdit(_controller.text);
                  setState(() => _isEditing = false);
                },
              )
            : Text(
                widget.item.text,
                style: TextStyle(
                  decoration: widget.item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: widget.item.isCompleted
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : null,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: '编辑',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 20, color: Theme.of(context).colorScheme.error),
              onPressed: widget.onDelete,
              tooltip: '删除',
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
}
