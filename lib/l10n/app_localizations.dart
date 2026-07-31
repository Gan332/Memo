import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  bool get isZh => locale.languageCode == 'zh';

  String get appTitle => isZh ? '备忘录' : 'Memo';
  String get homeTitle => isZh ? '备忘录' : 'Memo';
  String get emptyNotes => isZh ? '还没有笔记' : 'No notes yet';
  String get emptyNotesHint => isZh ? '点击右下角 + 创建第一条笔记' : 'Tap + to create your first note';
  String get searchHint => isZh ? '搜索笔记...' : 'Search notes...';
  String get newNote => isZh ? '新建笔记' : 'New Note';
  String get editNote => isZh ? '编辑笔记' : 'Edit Note';
  String get titleHint => isZh ? '标题' : 'Title';
  String get contentHint => isZh ? '开始记录...' : 'Start writing...';
  String get save => isZh ? '保存' : 'Save';
  String get cancel => isZh ? '取消' : 'Cancel';
  String get delete => isZh ? '删除' : 'Delete';
  String get confirm => isZh ? '确定' : 'Confirm';
  String get undo => isZh ? '撤销' : 'Undo';
  String get redo => isZh ? '重做' : 'Redo';
  String get pin => isZh ? '置顶' : 'Pin';
  String get unpin => isZh ? '取消置顶' : 'Unpin';
  String get archive => isZh ? '归档' : 'Archive';
  String get restore => isZh ? '恢复' : 'Restore';
  String get restoreFromArchive => isZh ? '恢复笔记' : 'Restore Note';
  String get deleteNoteTitle => isZh ? '删除笔记' : 'Delete Note';

  String deleteNoteConfirm(String title) => isZh
      ? '确定要删除「$title」吗？'
      : 'Delete "$title"?';

  String deletedNote(String title) => isZh
      ? '已删除「$title」'
      : 'Deleted "$title"';

  String restoredNote(String title) => isZh
      ? '已恢复「$title」'
      : 'Restored "$title"';

  String get archiveTitle => isZh ? '归档笔记' : 'Archived Notes';
  String get emptyArchive => isZh ? '没有归档笔记' : 'No archived notes';

  String archivedAt(String date) => isZh
      ? '归档于 $date'
      : 'Archived on $date';

  String get tagManage => isZh ? '管理标签' : 'Manage Tags';
  String get emptyTags => isZh ? '还没有标签' : 'No tags yet';
  String get emptyTagsHint => isZh ? '点击右下角 + 创建第一个标签' : 'Tap + to create your first tag';
  String get newTag => isZh ? '新建标签' : 'New Tag';
  String get editTag => isZh ? '编辑标签' : 'Edit Tag';
  String get tagNameHint => isZh ? '标签名称' : 'Tag name';
  String get create => isZh ? '创建' : 'Create';
  String get selectTags => isZh ? '选择标签' : 'Select Tags';
  String get selectColor => isZh ? '选择颜色' : 'Select Color';
  String get convertToChecklist => isZh ? '转换为清单' : 'Convert to Checklist';
  String get convertToText => isZh ? '切换为文本' : 'Switch to Text';
  String get convertConfirmTitle => isZh ? '转换笔记类型' : 'Convert Note Type';
  String get convertConfirmContent => isZh
      ? '将文本笔记转换为清单后，原有内容将清空。确定继续吗？'
      : 'Converting to checklist will clear existing content. Continue?';
  String get addChecklistItem => isZh ? '添加清单项...' : 'Add item...';
  String get edit => isZh ? '编辑' : 'Edit';
  String get settings => isZh ? '设置' : 'Settings';
  String get appearance => isZh ? '外观' : 'Appearance';
  String get themeMode => isZh ? '主题模式' : 'Theme Mode';
  String get dynamicColor => isZh ? '动态取色' : 'Dynamic Color';
  String get dynamicColorSubtitle => isZh ? '使用系统壁纸颜色（Android 12+）' : 'Use system wallpaper colors (Android 12+)';
  String get data => isZh ? '数据' : 'Data';
  String get exportBackup => isZh ? '导出备份' : 'Export Backup';
  String get exportBackupSubtitle => isZh ? '导出所有笔记和标签' : 'Export all notes and tags';
  String get importBackup => isZh ? '导入备份' : 'Import Backup';
  String get importBackupSubtitle => isZh ? '从备份文件恢复笔记' : 'Restore notes from backup file';

  String exportedBackup(String path) => isZh
      ? '备份已导出: $path'
      : 'Backup exported: $path';

  String exportFailed(String error) => isZh
      ? '导出失败: $error'
      : 'Export failed: $error';

  String importComplete({
    required int added,
    required int updated,
    required int skipped,
    required int failed,
  }) => isZh
      ? '导入完成: 新增$added条, 更新$updated条, 跳过$skipped条, 失败$failed条'
      : 'Import complete: $added added, $updated updated, $skipped skipped, $failed failed';

  String importFailed(String error) => isZh
      ? '导入失败: $error'
      : 'Import failed: $error';

  String get about => isZh ? '关于' : 'About';
  String get version => isZh ? '版本' : 'Version';
  String get retry => isZh ? '重试' : 'Retry';
  String get filterTitle => isZh ? '筛选' : 'Filter';
  String get clearFilters => isZh ? '清除筛选' : 'Clear Filters';
  String get applyFilters => isZh ? '应用筛选' : 'Apply Filters';
  String get pinned => isZh ? '已置顶' : 'Pinned';
  String get textNote => isZh ? '文本' : 'Text';
  String get checklistNote => isZh ? '清单' : 'Checklist';
  String get language => isZh ? '语言' : 'Language';
  String get languageSystem => isZh ? '跟随系统' : 'System';
  String get languageChinese => '中文';
  String get languageEnglish => 'English';
  String get loading => isZh ? '加载中...' : 'Loading...';
  String get noNotes => isZh ? '没有找到相关笔记' : 'No matching notes found';
  String get sortBy => isZh ? '排序' : 'Sort by';
  String get lastModified => isZh ? '最近修改' : 'Modified';
  String get createdAtLabel => isZh ? '创建时间' : 'Created';
  String get titleLabel => isZh ? '标题' : 'Title';
  String get ascending => isZh ? '升序' : 'Ascending';
  String get descending => isZh ? '降序' : 'Descending';
  String get multiSelect => isZh ? '多选' : 'Multi-select';
  String get selectAll => isZh ? '全选' : 'Select All';
  String get deselectAll => isZh ? '取消全选' : 'Deselect All';
  String get batchDelete => isZh ? '批量删除' : 'Delete Selected';
  String get batchArchive => isZh ? '批量归档' : 'Archive Selected';
  String get batchPin => isZh ? '批量置顶' : 'Pin Selected';
  String get batchTag => isZh ? '批量打标签' : 'Tag Selected';
  String get notes => isZh ? '笔记' : 'Notes';
  String get tag => isZh ? '标签' : 'Tag';

  // Tag management
  String get deleteTagTitle => isZh ? '删除标签' : 'Delete Tag';
  String deleteTagConfirm(String tagName) => isZh
      ? '确定要删除标签「$tagName」吗？\n标签将被移除，但关联的笔记不会被删除。'
      : 'Delete tag "$tagName"?\nThe tag will be removed, but linked notes won\'t be deleted.';

  // Trash
  String get trash => isZh ? '回收站' : 'Trash';
  String get trashEmpty => isZh ? '回收站为空' : 'Trash is empty';
  String get emptyTrash => isZh ? '清空回收站' : 'Empty Trash';
  String get emptyTrashConfirm => isZh ? '确定要清空回收站吗？删除的笔记将无法恢复。' : 'Permanently delete all trashed notes? This action cannot be undone.';
  String get permanentDelete => isZh ? '永久删除' : 'Delete Forever';
  String get permanentDeleteConfirm => isZh ? '确定要永久删除这条笔记吗？此操作无法撤销。' : 'Delete this note forever? This action cannot be undone.';
  String get deletedAt => isZh ? '删除于' : 'Deleted';

  // Preview & Stats
  String get preview => isZh ? '预览' : 'Preview';
  String get noPreviewContent => isZh ? '暂无内容预览' : 'Nothing to preview';
  String charCount(int count) => isZh ? '字符: $count' : 'Chars: $count';
  String wordCount(int count) => isZh ? '单词: $count' : 'Words: $count';

  // Reminder
  String get reminder => isZh ? '提醒' : 'Reminder';
  String get hasReminder => isZh ? '有提醒' : 'Has Reminder';
  String get setReminder => isZh ? '设置提醒' : 'Set Reminder';
  String get clearReminder => isZh ? '清除提醒' : 'Clear Reminder';
  String get reminderDateHelp => isZh ? '设置提醒日期' : 'Select reminder date';
  String get reminderTimeHelp => isZh ? '设置提醒时间' : 'Select reminder time';
  String get reminderPastError => isZh ? '提醒时间不能早于当前时间' : 'Reminder time cannot be in the past';
  String reminderNotificationTitle(String title) => isZh ? '提醒: $title' : 'Reminder: $title';
  String reminderNotificationBody(String title) => isZh ? '笔记「$title」提醒' : 'Reminder for "$title"';

  // Multi-select
  String selectedCount(int count) => isZh ? '已选 $count 项' : '$count selected';

  // Tag count
  String noteCount(int count) => isZh ? '$count 条笔记' : '$count notes';

  // Editor actions
  String get untitled => isZh ? '无标题' : 'Untitled';
  String get changeColor => isZh ? '更换颜色' : 'Change color';
  String get unknown => isZh ? '未知' : 'Unknown';
  String lastEditedAt(String formatted) => isZh
      ? '最后编辑：$formatted'
      : 'Last edited: $formatted';

  // Export
  String get export => isZh ? '导出' : 'Export';
  String exportSucceeded(String fileName) => isZh
      ? '导出成功：$fileName'
      : 'Export successful: $fileName';

  // Templates
  String get newNoteFromTemplate => isZh ? '新建笔记' : 'New Note';
  String get blankNote => isZh ? '空白笔记' : 'Blank Note';
  String get meetingNotes => isZh ? '会议记录' : 'Meeting Notes';
  String get journal => isZh ? '日记' : 'Journal';
  String get todoList => isZh ? '待办清单' : 'TODO List';
  String get idea => isZh ? '灵感' : 'Idea';

  // Attachments & Share
  String get attachment => isZh ? '附件' : 'Attachment';
  String get addAttachment => isZh ? '添加附件' : 'Add Attachment';
  String get takePhoto => isZh ? '拍照' : 'Take Photo';
  String get chooseFromGallery => isZh ? '从相册选择' : 'Choose from Gallery';
  String get attachFile => isZh ? '选择文件' : 'Attach File';
  String get noAttachments => isZh ? '暂无附件，点击附件按钮添加' : 'No attachments. Tap attachment icon to add';
  String get share => isZh ? '分享' : 'Share';
  String get confirmDeleteAttachment => isZh ? '确定要删除此附件吗？' : 'Delete this attachment?';

  // Auto-save
  String get autoSaved => isZh ? '已自动保存' : 'Auto-saved';
  String get saveFailed => isZh ? '保存失败' : 'Save failed';

  // Formatting toolbar
  String get noteImage => isZh ? '笔记图片' : 'Note image';
  String get bold => isZh ? '加粗' : 'Bold';
  String get italic => isZh ? '斜体' : 'Italic';
  String get strikethrough => isZh ? '删除线' : 'Strikethrough';
  String get inlineCode => isZh ? '行内代码' : 'Inline Code';
  String get quote => isZh ? '引用' : 'Quote';
  String get heading => isZh ? '标题' : 'Heading';
  String get bulletList => isZh ? '无序列表' : 'Bullet List';
  String get numberedList => isZh ? '有序列表' : 'Numbered List';
  String get insertImage => isZh ? '插入图片' : 'Insert Image';
  String get insertLink => isZh ? '插入链接' : 'Insert Link';

  // Notes section
  String get pinnedNotes => isZh ? '置顶笔记' : 'Pinned';
  String get otherNotes => isZh ? '其他笔记' : 'Notes';

  String justNow() => isZh ? '刚刚' : 'just now';

  String minutesAgo(int minutes) => isZh
      ? '$minutes 分钟前'
      : '$minutes minutes ago';

  String hoursAgo(int hours) => isZh
      ? '$hours 小时前'
      : '$hours hours ago';

  String daysAgo(int days) => isZh
      ? '$days 天前'
      : '$days days ago';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
