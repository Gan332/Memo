import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';
import '../services/attachment_service.dart';
import '../data/database/app_database.dart';
import '../state/providers/note_provider.dart';
import '../state/providers/tag_provider.dart';
import '../state/providers/checklist_provider.dart';
import '../domain/entities/note_entity.dart';
import '../domain/entities/tag_entity.dart';
import '../theme/app_colors.dart';
import '../utils/edit_history.dart';
import '../utils/markdown_format.dart';
import '../widgets/tag_chip.dart';
import '../widgets/checklist_editor.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteEntity? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> with WidgetsBindingObserver {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late Color _selectedColor;
  NoteType _noteType = NoteType.text;
  List<int> _selectedTagIds = [];
  late EditHistory _contentHistory;
  bool _isUndoRedoing = false;
  bool _isPreviewing = false;
  int? _reminderTimestamp;
  final _contentFocusNode = FocusNode();
  Timer? _autoSaveTimer;
  bool _didAutoSave = false;
  final ImagePicker _imagePicker = ImagePicker();
  List<Attachment> _attachments = [];

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      _loadAttachments();
    } else {
      _selectedColor = const Color(0xFFFEF7E0);
    }
    _contentController.addListener(_onContentChanged);
    _titleController.addListener(_onTitleChanged);
    _contentFocusNode.addListener(_onContentFocusChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _performAutoSave();
    }
  }

  void _onContentFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onTitleChanged() {
    if (!_isUndoRedoing) {
      _scheduleAutoSave();
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 5), _performAutoSave);
  }

  void _performAutoSave() {
    _autoSaveTimer?.cancel();
    if (!mounted || !isEditing) return;
    if (isEditing) {
      final loc = AppLocalizations.of(context);
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();
      final now = DateTime.now();
      final provider = context.read<NoteProvider>();
      final updated = widget.note!.copyWith(
        title: title.isEmpty ? loc.untitled : title,
        content: _noteType == NoteType.text ? content : '',
        noteType: _noteType,
        color: _selectedColor.value,
        updatedAt: now,
      );
      provider.updateNote(updated);
      setState(() => _didAutoSave = true);
    }
  }

  void _onContentChanged() {
    if (!_isUndoRedoing) {
      _contentHistory.push(_contentController.text);
      if (isEditing) {
        _scheduleAutoSave();
      }
    }
  }

  void _undo() {
    final prev = _contentHistory.undo();
    if (prev != null) {
      setState(() {
        _isUndoRedoing = true;
        _contentController.text = prev;
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: prev.length),
        );
        _isUndoRedoing = false;
      });
    }
  }

  void _redo() {
    final next = _contentHistory.redo();
    if (next != null) {
      setState(() {
        _isUndoRedoing = true;
        _contentController.text = next;
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: next.length),
        );
        _isUndoRedoing = false;
      });
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

  Future<void> _loadAttachments() async {
    if (widget.note?.id == null) return;
    try {
      final service = AttachmentService();
      final attachments = await service.getAttachmentsForNote(widget.note!.id!);
      if (mounted) {
        setState(() => _attachments = attachments);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _attachments = const []);
      }
    }
  }

  Future<void> _addAttachmentFromCamera() async {
    final file = await _imagePicker.pickImage(source: ImageSource.camera);
    if (file == null || widget.note?.id == null) return;
    final service = AttachmentService();
    await service.addAttachment(
      noteId: widget.note!.id!,
      sourcePath: file.path,
      fileName: file.name,
      mimeType: 'image/jpeg',
    );
    await _loadAttachments();
  }

  Future<void> _addAttachmentFromGallery() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null || widget.note?.id == null) return;
    final service = AttachmentService();
    await service.addAttachment(
      noteId: widget.note!.id!,
      sourcePath: file.path,
      fileName: file.name,
      mimeType: 'image/jpeg',
    );
    await _loadAttachments();
  }

  Future<void> _addAttachmentFromFile() async {
    if (widget.note?.id == null) return;
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    final service = AttachmentService();
    await service.addAttachment(
      noteId: widget.note!.id!,
      sourcePath: file.path!,
      fileName: file.name,
      mimeType: file.extension ?? 'application/octet-stream',
    );
    await _loadAttachments();
  }

  Future<void> _deleteAttachment(int attachmentId) async {
    final service = AttachmentService();
    await service.deleteAttachment(attachmentId);
    await _loadAttachments();
  }

  void _showAttachmentPicker() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.addAttachment,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.takePhoto),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _addAttachmentFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.chooseFromGallery),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _addAttachmentFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file_outlined),
                title: Text(l10n.attachFile),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _addAttachmentFromFile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final text = title.isEmpty
        ? content
        : '$title\n\n$content';
    if (text.isEmpty && _noteType != NoteType.checklist) return;
    unawaited(Share.share(text));
  }

  Widget _buildAttachmentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.attachment_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${_attachments.length} ${AppLocalizations.of(context).attachment}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _attachments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final attachment = _attachments[index];
                final isImage = attachment.mimeType.startsWith('image/');
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      if (isImage)
                        Image.file(
                          File(attachment.filePath),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildAttachmentPlaceholder(attachment),
                        )
                      else
                        _buildAttachmentPlaceholder(attachment),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(attachment.fileName),
                                content: Text(AppLocalizations.of(context).confirmDeleteAttachment),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: Text(AppLocalizations.of(context).cancel),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      _deleteAttachment(attachment.id);
                                    },
                                    child: Text(
                                      AppLocalizations.of(context).delete,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error.withOpacity(0.9),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPlaceholder(Attachment attachment) {
    return Container(
      width: 80,
      height: 80,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Text(
            attachment.fileName.length > 10
                ? '${attachment.fileName.substring(0, 10)}...'
                : attachment.fileName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Formatting toolbar ──────────────────────────────────────────

  void _insertFormatting(String prefix, String suffix) {
    final selection = _contentController.selection;
    _applyFormattingResult(
      MarkdownFormat.wrap(
        text: _contentController.text,
        selectionStart: selection.start,
        selectionEnd: selection.end,
        prefix: prefix,
        suffix: suffix,
      ),
    );
  }

  void _insertHeading() {
    final selection = _contentController.selection;
    _applyFormattingResult(
      MarkdownFormat.insertLinePrefix(
        text: _contentController.text,
        selectionOffset: selection.start,
        prefix: '# ',
        suppressIfAlreadyPrefixed: true,
      ),
    );
  }

  void _insertBulletList() {
    final selection = _contentController.selection;
    _applyFormattingResult(
      MarkdownFormat.insertLinePrefix(
        text: _contentController.text,
        selectionOffset: selection.start,
        prefix: '- ',
        suppressIfAlreadyPrefixed: false,
      ),
    );
  }

  void _insertNumberedList() {
    final selection = _contentController.selection;
    _applyFormattingResult(
      MarkdownFormat.insertLinePrefix(
        text: _contentController.text,
        selectionOffset: selection.start,
        prefix: '1. ',
        suppressIfAlreadyPrefixed: false,
      ),
    );
  }

  void _applyFormattingResult(MarkdownFormatResult result) {
    _contentController.text = result.text;
    _contentController.selection =
        TextSelection.collapsed(offset: result.cursorOffset);
    if (mounted && _contentFocusNode.canRequestFocus) {
      _contentFocusNode.requestFocus();
    }
  }

  void _insertImageMarkdown() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;

    if (widget.note?.id != null) {
      final service = AttachmentService();
      await service.addAttachment(
        noteId: widget.note!.id!,
        sourcePath: file.path,
        fileName: file.name,
        mimeType: 'image/jpeg',
      );
      await _loadAttachments();
    }

    final l10n = AppLocalizations.of(context);
    final markdown = '\n![${l10n.noteImage}](${file.path})\n';
    final text = _contentController.text;
    final cursorPos = _contentController.selection.start;
    final newText =
        '${text.substring(0, cursorPos)}$markdown${text.substring(cursorPos)}';
    _contentController.text = newText;
    _contentController.selection =
        TextSelection.collapsed(offset: cursorPos + markdown.length);
  }

  Widget _buildFormattingToolbar() {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurfaceVariant;
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          _toolbarBtn(Icons.format_bold, () => _insertFormatting('**', '**'), iconColor, l10n.bold),
          _toolbarBtn(Icons.format_italic, () => _insertFormatting('*', '*'), iconColor, l10n.italic),
          _toolbarBtn(Icons.format_strikethrough, () => _insertFormatting('~~', '~~'), iconColor, l10n.strikethrough),
          _toolbarBtn(Icons.code, () => _insertFormatting('`', '`'), iconColor, l10n.inlineCode),
          _toolbarBtn(Icons.format_quote, () => _insertFormatting('> ', ''), iconColor, l10n.quote),
          _tbDivider(),
          _toolbarBtn(Icons.title, _insertHeading, iconColor, l10n.heading),
          _toolbarBtn(Icons.format_list_bulleted, _insertBulletList, iconColor, l10n.bulletList),
          _toolbarBtn(Icons.format_list_numbered, _insertNumberedList, iconColor, l10n.numberedList),
          _tbDivider(),
          _toolbarBtn(Icons.image_outlined, _insertImageMarkdown, iconColor, l10n.insertImage),
          _toolbarBtn(Icons.link, () => _insertFormatting('[', '](url)'), iconColor, l10n.insertLink),
        ],
      ),
    );
  }

  Widget _toolbarBtn(
    IconData icon,
    VoidCallback onPressed,
    Color iconColor,
    String tooltip,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: iconColor,
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 44),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _tbDivider() {
    return VerticalDivider(
      width: 8,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSaveTimer?.cancel();
    _contentController.removeListener(_onContentChanged);
    _contentFocusNode.removeListener(_onContentFocusChanged);
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _save() async {
    _autoSaveTimer?.cancel();
    final loc = AppLocalizations.of(context);
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
      final updated = NoteEntity(
        id: widget.note!.id,
        title: title.isEmpty ? loc.untitled : title,
        content: _noteType == NoteType.text ? content : '',
        noteType: _noteType,
        color: _selectedColor.value,
        isPinned: widget.note!.isPinned,
        isArchived: widget.note!.isArchived,
        isDeleted: widget.note!.isDeleted,
        deletedAt: widget.note!.deletedAt,
        reminderTimestamp: _reminderTimestamp,
        reminderFired: _reminderTimestamp == null ? null : false,
        createdAt: widget.note!.createdAt,
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
        title: title.isEmpty ? loc.untitled : title,
        content: _noteType == NoteType.text ? content : '',
        noteType: _noteType,
        color: _selectedColor.value,
        reminderTimestamp: _reminderTimestamp,
        reminderFired: _reminderTimestamp == null ? null : false,
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
    final loc = AppLocalizations.of(context);
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
              loc.selectColor,
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
    final loc = AppLocalizations.of(context);
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
                      loc.selectTags,
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
    final l10n = AppLocalizations.of(context);
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
        title: Text(isEditing ? l10n.editNote : l10n.newNote),
        actions: [
          if (_noteType == NoteType.text) ...[
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: l10n.undo,
              onPressed:
                  _contentHistory.canUndo ? _undo : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              tooltip: l10n.redo,
              onPressed:
                  _contentHistory.canRedo ? _redo : null,
            ),
          ],
          if (_noteType == NoteType.text && !isEditing)
            IconButton(
              icon: Icon(
                _isPreviewing ? Icons.edit : Icons.visibility,
              ),
              tooltip: _isPreviewing ? l10n.edit : l10n.preview,
              onPressed: () {
                setState(() => _isPreviewing = !_isPreviewing);
              },
            ),
          if (isEditing && widget.note!.noteType != NoteType.checklist)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: l10n.convertToChecklist,
              onPressed: _showConvertConfirmDialog,
            ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: l10n.changeColor,
            onPressed: _showColorPicker,
          ),
          if (!isEditing)
            IconButton(
              icon: Icon(
                _noteType == NoteType.checklist ? Icons.checklist : Icons.notes,
              ),
              tooltip: _noteType == NoteType.checklist ? l10n.convertToText : l10n.convertToChecklist,
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
            tooltip: l10n.reminder,
            onPressed: _showReminderPicker,
          ),
          IconButton(
            icon: const Icon(Icons.label_outlined),
            tooltip: l10n.tagManage,
            onPressed: _showTagSelector,
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.attachment_outlined),
              tooltip: l10n.attachment,
              onPressed: _showAttachmentPicker,
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: l10n.share,
              onPressed: _shareNote,
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: l10n.export,
              onPressed: _exportNote,
            ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: l10n.save,
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
              decoration: InputDecoration(
                hintText: l10n.titleHint,
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isEditing
                  ? l10n.lastEditedAt(DateFormat('yyyy/MM/dd HH:mm').format(widget.note!.updatedAt))
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
                      name: l10n.unknown,
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
          if (isEditing && _attachments.isNotEmpty)
            _buildAttachmentsSection(),
          if (isEditing && _attachments.isEmpty && _noteType != NoteType.checklist)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 24,
                child: Text(
                  l10n.noAttachments,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
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
                                    l10n.noPreviewContent,
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
                          focusNode: _contentFocusNode,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: l10n.contentHint,
                            border: InputBorder.none,
                            filled: false,
                          ),
                        ),
                      ),
          ),
          if (_noteType == NoteType.text && !_isPreviewing && _contentFocusNode.hasFocus)
            _buildFormattingToolbar(),
          if (_noteType == NoteType.text && !_isPreviewing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    l10n.charCount(_contentController.text.length),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n.wordCount(_computeWordCount()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  if (_didAutoSave && isEditing)
                    Text(
                      l10n.autoSaved,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
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
    final loc = AppLocalizations.of(context);
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
    final fallbackTitle = loc.untitled;
    final fileName =
        '${exportService.sanitizeFileName(note.title.isNotEmpty ? note.title : fallbackTitle)}.md';

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
          SnackBar(content: Text(loc.exportSucceeded(fileName))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.exportFailed('$e'))),
        );
      }
    }
  }

  Future<void> _scheduleReminderNotification(
      int noteId, String title, DateTime date) async {
    final l = AppLocalizations.of(context);
    await NotificationService().scheduleNotification(
      id: noteId,
      title: l.reminderNotificationTitle(title),
      body: l.reminderNotificationBody(title),
      scheduledDate: date,
    );
  }

  int _computeWordCount() {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  Future<void> _showReminderPicker() async {
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    final initialDate = _reminderTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(_reminderTimestamp! * 1000)
        : now.add(const Duration(hours: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: l.reminderDateHelp,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: l.reminderTimeHelp,
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
          SnackBar(content: Text(l.reminderPastError)),
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
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.convertConfirmTitle),
        content: Text(loc.convertConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.confirm),
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
