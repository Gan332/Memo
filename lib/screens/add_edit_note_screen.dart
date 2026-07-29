import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../services/notification_service.dart';
import '../services/export_service.dart';
import '../state/providers/note_provider.dart';
import '../state/providers/tag_provider.dart';
import '../state/providers/checklist_provider.dart';
import '../domain/entities/note_entity.dart';
import '../domain/entities/tag_entity.dart';
import '../theme/app_colors.dart';
import '../utils/edit_history.dart';
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
  late EditHistory _contentHistory;
  bool _isUndoRedoing = false;
  bool _isPreviewing = false;
  int? _reminderTimestamp;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _contentHistory = EditHistory(
      initial: widget.note?.content ?? '',
    );
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = Color(widget.note!.color);
      _noteType = widget.note!.noteType;
      _reminderTimestamp = widget.note!.reminderTimestamp;
      _loadSelectedTags();
    } else {
      _selectedColor = const Color(0xFFFEF7E0);
    }
    _contentController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    if (!_isUndoRedoing) {
      _contentHistory.push(_contentController.text);
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
        reminderTimestamp: _reminderTimestamp,
        updatedAt: now,
      );
      await provider.updateNote(updated);

      // Schedule notification if reminder set
      if (_reminderTimestamp != null) {
        final reminderDate =
            DateTime.fromMillisecondsSinceEpoch(_reminderTimestamp! * 1000);
        await _scheduleReminderNotification(updated.id!, updated.title, reminderDate);
      }

      // Update tags for existing note
      final oldTagIds = await tagProvider.getTagIdsForNote(widget.note!.id!);
      for (final tagId in oldTagIds) {
        if (!_selectedTagIds.contains(tagId)) {
          await tagProvider.removeTagFromNote(widget.note!.id!, tagId);
        }
      }
      for (final tagId in _selectedTagIds) {
        if (!oldTagIds.contains(tagId)) {
          await tagProvider.addTagToNote(widget.note!.id!, tagId);
        }
      }
    } else {
      final note = NoteEntity(
        title: title.isEmpty ? '无标题' : title,
        content: _noteType == NoteType.text ? content : '',
        noteType: _noteType,
        color: _selectedColor.value,
        reminderTimestamp: _reminderTimestamp,
        createdAt: now,
        updatedAt: now,
      );
      final noteId = await provider.addNote(note);

      // Schedule notification if reminder set
      if (_reminderTimestamp != null) {
        final reminderDate =
            DateTime.fromMillisecondsSinceEpoch(_reminderTimestamp! * 1000);
        await _scheduleReminderNotification(noteId, note.title, reminderDate);
      }

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
                          final isSelected = _selectedTagIds.contains(tag.id);
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
          if (_noteType == NoteType.text && !isEditing)
            IconButton(
              icon: Icon(
                _isPreviewing ? Icons.edit : Icons.visibility,
              ),
              tooltip: _isPreviewing ? '编辑' : '预览',
              onPressed: () {
                setState(() => _isPreviewing = !_isPreviewing);
              },
            ),
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
                _noteType == NoteType.checklist ? Icons.checklist : Icons.notes,
              ),
              tooltip: _noteType == NoteType.checklist ? '切换为文本' : '切换为清单',
              onPressed: () {
                setState(() {
                  _noteType = _noteType == NoteType.text
                      ? NoteType.checklist
                      : NoteType.text;
                  _isPreviewing = false;
                });
              },
            ),
          IconButton(
            icon: Icon(
              _reminderTimestamp != null
                  ? Icons.notifications_active
                  : Icons.notifications_none,
            ),
            tooltip: '提醒',
            onPressed: _showReminderPicker,
          ),
          IconButton(
            icon: const Icon(Icons.label_outlined),
            tooltip: '管理标签',
            onPressed: _showTagSelector,
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: '导出',
              onPressed: _exportNote,
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
                : _isPreviewing
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          child: _contentController.text.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    '暂无内容预览',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                )
                              : MarkdownBody(
                                  data: _contentController.text,
                                  selectable: true,
                                ),
                        ),
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
          if (_noteType == NoteType.text && !_isPreviewing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '字符: ${_contentController.text.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '单词: ${_computeWordCount()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _exportNote() async {
    if (widget.note?.id == null) return;
    final repo = context.read<NoteProvider>();
    final noteWithTags = await repo.getNote(widget.note!.id!);
    if (noteWithTags == null) return;

    final exportService = ExportService();
    final dir = await exportService.pickDirectory();
    if (dir == null) return;

    final note = noteWithTags.note;
    final tagNames =
        noteWithTags.tags.map((t) => t.name).toList();
    final fileName =
        '${exportService.sanitizeFileName(note.title.isNotEmpty ? note.title : '无标题')}.md';

    String content;
    if (note.noteType == 'checklist') {
      // Fetch checklist items
      final checklistProvider = context.read<ChecklistProvider>();
      final items = await checklistProvider.getItems(note.id);
      content = exportService.formatChecklistAsMarkdown(
          note, items);
    } else {
      content = exportService.formatAsMarkdown(note, tagNames);
    }

    try {
      await exportService.exportToFile(dir, fileName, content);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出成功：$fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e')),
        );
      }
    }
  }

  Future<void> _scheduleReminderNotification(
      int noteId, String title, DateTime date) async {
    await NotificationService().scheduleNotification(
      id: noteId,
      title: '提醒: $title',
      body: '笔记「$title」提醒',
      scheduledDate: date,
    );
  }

  int _computeWordCount() {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  Future<void> _showReminderPicker() async {
    final now = DateTime.now();
    final initialDate = _reminderTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(_reminderTimestamp! * 1000)
        : now.add(const Duration(hours: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: '设置提醒日期',
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: '设置提醒时间',
    );
    if (time == null || !mounted) return;

    final reminderDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (reminderDate.isBefore(now)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提醒时间不能早于当前时间')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _reminderTimestamp =
            reminderDate.millisecondsSinceEpoch ~/ 1000;
      });
    }
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
