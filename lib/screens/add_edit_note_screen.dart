import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../state/providers/note_provider.dart';
import '../state/providers/tag_provider.dart';
import '../state/providers/checklist_provider.dart';
import '../domain/entities/note_entity.dart';
import '../domain/entities/tag_entity.dart';
import '../theme/app_colors.dart';
import '../widgets/tag_chip.dart';
import '../widgets/checklist_editor.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteEntity? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late Color _selectedColor;
  NoteType _noteType = NoteType.text;
  List<int> _selectedTagIds = [];

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = Color(widget.note!.color);
      _noteType = widget.note!.noteType;
      _loadSelectedTags();
    } else {
      _selectedColor = const Color(0xFFFEF7E0);
    }
  }

  Future<void> _loadSelectedTags() async {
    if (widget.note?.id == null) return;
    final tagProvider = context.read<TagProvider>();
    final tagIds = await tagProvider.getTagIdsForNote(widget.note!.id!);
    if (mounted) {
      setState(() => _selectedTagIds = tagIds);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty && _noteType != NoteType.checklist) {
      Navigator.of(context).pop();
      return;
    }

    final now = DateTime.now();
    final provider = context.read<NoteProvider>();
    final tagProvider = context.read<TagProvider>();

    if (isEditing) {
      final updated = widget.note!.copyWith(
        title: title.isEmpty ? '无标题' : title,
        content: _noteType == NoteType.text ? content : '',
        noteType: _noteType,
        color: _selectedColor.value,
        updatedAt: now,
      );
      await provider.updateNote(updated);
    } else {
      final note = NoteEntity(
        title: title.isEmpty ? '无标题' : title,
        content: _noteType == NoteType.text ? content : '',
        noteType: _noteType,
        color: _selectedColor.value,
        createdAt: now,
        updatedAt: now,
      );
      final noteId = await provider.addNote(note);

      // Add tags to new note
      for (final tagId in _selectedTagIds) {
        await tagProvider.addTagToNote(noteId, tagId);
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择颜色',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppColors.notePalette.asMap().entries.map((entry) {
                final index = entry.key;
                final colorValue = entry.value;
                final isSelected = _selectedColor.value == colorValue;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = Color(colorValue));
                    Navigator.of(context).pop();
                  },
                  child: Tooltip(
                    message: AppColors.notePaletteLabels[index],
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                              size: 22,
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showTagSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<TagProvider>(
            builder: (context, tagProvider, _) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择标签',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: tagProvider.tags.length,
                        itemBuilder: (context, index) {
                          final tag = tagProvider.tags[index];
                          final isSelected =
                              _selectedTagIds.contains(tag.id);
                          return CheckboxListTile(
                            title: TagChip(tag: tag),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedTagIds.add(tag.id!);
                                } else {
                                  _selectedTagIds.remove(tag.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(
        _selectedColor.value,
        Theme.of(context).brightness,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor(
              _selectedColor.value,
              Theme.of(context).brightness,
            ).withOpacity(0.8),
        title: Text(isEditing ? '编辑笔记' : '新建笔记'),
        actions: [
          if (isEditing && widget.note!.noteType != 'checklist')
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: '转换为清单',
              onPressed: _showConvertConfirmDialog,
            ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: '更换颜色',
            onPressed: _showColorPicker,
          ),
          if (!isEditing)
            IconButton(
              icon: Icon(
                _noteType == NoteType.checklist
                    ? Icons.checklist
                    : Icons.notes,
              ),
              tooltip:
                  _noteType == NoteType.checklist ? '切换为文本' : '切换为清单',
              onPressed: () {
                setState(() {
                  _noteType = _noteType == NoteType.text
                      ? NoteType.checklist
                      : NoteType.text;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.label_outlined),
            tooltip: '管理标签',
            onPressed: _showTagSelector,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: '保存',
            onPressed: _save,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.headlineSmall,
              decoration: const InputDecoration(
                hintText: '标题',
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isEditing
                  ? '最后编辑：${DateFormat('yyyy/MM/dd HH:mm').format(widget.note!.updatedAt)}'
                  : DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const Divider(height: 24),
          if (_selectedTagIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _selectedTagIds.map((tagId) {
                  final tagProvider = context.read<TagProvider>();
                  final tag = tagProvider.tags.firstWhere(
                    (t) => t.id == tagId,
                    orElse: () => TagEntity(
                      name: '未知',
                      createdAt: DateTime.now(),
                    ),
                  );
                  return TagChip(
                    tag: tag,
                    onDeleted: () {
                      setState(() => _selectedTagIds.remove(tagId));
                    },
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: _noteType == NoteType.checklist
                ? ChecklistEditor(
                    noteId: widget.note?.id,
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: '开始记录...',
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showConvertConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('转换笔记类型'),
        content: const Text('将文本笔记转换为清单后，原有内容将清空。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _noteType = NoteType.checklist;
        _contentController.clear();
      });
    }
  }
}
