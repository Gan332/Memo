// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// DriftDatabaseGenerator
// **************************************************************************

// ignore_for_file: type=lint
class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String _alias;
  $NotesTable(this.attachedDatabase, [this._alias = 'notes']);
  static const VerificationMeta _idMeta = VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      defaultValue: const Constant(''));
  static const VerificationMeta _contentMeta = VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string,
      defaultValue: const Constant(''));
  static const VerificationMeta _noteTypeMeta = VerificationMeta('noteType');
  @override
  late final GeneratedColumn<String> noteType = GeneratedColumn<String>(
      'note_type', aliasedName, false,
      type: DriftSqlType.string,
      defaultValue: const Constant('text'));
  static const VerificationMeta _colorMeta = VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, defaultValue: const Constant(0xFFFEF7E0));
  static const VerificationMeta _isPinnedMeta = VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string);
  static const VerificationMeta _updatedAtMeta =
      VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string);
  @override
  List<GeneratedColumn> get columns =>
      [id, title, content, noteType, color, isPinned, isArchived, createdAt, updatedAt];
  @override
  String get aliasedName => _alias;
  @override
  String get actualTableName => 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<NoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('note_type')) {
      context.handle(_noteTypeMeta,
          noteType.isAcceptableOrUnknown(data['note_type']!, _noteTypeMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      noteType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note_type'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final int id;
  final String title;
  final String content;
  final String noteType;
  final int color;
  final bool isPinned;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;
  const NoteRow(
      {required this.id,
      required this.title,
      required this.content,
      required this.noteType,
      required this.color,
      required this.isPinned,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['note_type'] = Variable<String>(noteType);
    map['color'] = Variable<int>(color);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  NoteRowCompanion toCompanion(bool nullToAbsent) {
    return NoteRowCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      noteType: Value(noteType),
      color: Value(color),
      isPinned: Value(isPinned),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      noteType: serializer.fromJson<String>(json['noteType']),
      color: serializer.fromJson<int>(json['color']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'noteType': serializer.toJson<String>(noteType),
      'color': serializer.toJson<int>(color),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  NoteRow copyWith(
          {int? id,
          String? title,
          String? content,
          String? noteType,
          int? color,
          bool? isPinned,
          bool? isArchived,
          String? createdAt,
          String? updatedAt}) =>
      NoteRow(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        noteType: noteType ?? this.noteType,
        color: color ?? this.color,
        isPinned: isPinned ?? this.isPinned,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('noteType: $noteType, ')
          ..write('color: $color, ')
          ..write('isPinned: $isPinned, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, content, noteType, color,
      isPinned, isArchived, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == id &&
          other.title == title &&
          other.content == content &&
          other.noteType == noteType &&
          other.color == color &&
          other.isPinned == isPinned &&
          other.isArchived == isArchived &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt);
}

class NoteRowCompanion extends UpdateCompanion<NoteRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> content;
  final Value<String> noteType;
  final Value<int> color;
  final Value<bool> isPinned;
  final Value<bool> isArchived;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const NoteRowCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.noteType = const Value.absent(),
    this.color = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NoteRowCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.noteType = const Value.absent(),
    this.color = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isArchived = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  })  : createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<NoteRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? noteType,
    Expression<int>? color,
    Expression<bool>? isPinned,
    Expression<bool>? isArchived,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (noteType != null) 'note_type': noteType,
      if (color != null) 'color': color,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) map['id'] = Variable<int>(id.value);
    if (title.present) map['title'] = Variable<String>(title.value);
    if (content.present) map['content'] = Variable<String>(content.value);
    if (noteType.present) map['note_type'] = Variable<String>(noteType.value);
    if (color.present) map['color'] = Variable<int>(color.value);
    if (isPinned.present) map['is_pinned'] = Variable<bool>(isPinned.value);
    if (isArchived.present)
      map['is_archived'] = Variable<bool>(isArchived.value);
    if (createdAt.present) map['created_at'] = Variable<String>(createdAt.value);
    if (updatedAt.present) map['updated_at'] = Variable<String>(updatedAt.value);
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteRowCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('noteType: $noteType, ')
          ..write('color: $color, ')
          ..write('isPinned: $isPinned, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String _alias;
  $TagsTable(this.attachedDatabase, [this._alias = 'tags']);
  static const VerificationMeta _idMeta = VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string);
  static const VerificationMeta _colorMeta = VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, defaultValue: const Constant(0xFF42A5F5));
  static const VerificationMeta _createdAtMeta =
      VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string);
  @override
  List<GeneratedColumn> get columns => [id, name, color, createdAt];
  @override
  String get aliasedName => _alias;
  @override
  String get actualTableName => 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final int color;
  final String createdAt;
  const Tag(
      {required this.id,
      required this.name,
      required this.color,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  TagCompanion toCompanion(bool nullToAbsent) {
    return TagCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Tag copyWith({int? id, String? name, int? color, String? createdAt}) => Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == id &&
          other.name == name &&
          other.color == color &&
          other.createdAt == createdAt);
}

class TagCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  final Value<String> createdAt;
  const TagCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TagCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    required String createdAt,
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) map['id'] = Variable<int>(id.value);
    if (name.present) map['name'] = Variable<String>(name.value);
    if (color.present) map['color'] = Variable<int>(color.value);
    if (createdAt.present) map['created_at'] = Variable<String>(createdAt.value);
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NoteTagsTable extends NoteTags
    with TableInfo<$NoteTagsTable, NoteTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String _alias;
  $NoteTagsTable(this.attachedDatabase, [this._alias = 'note_tags']);
  static const VerificationMeta _noteIdMeta = VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
      'note_id', aliasedName, false,
      type: DriftSqlType.int,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES notes (id)'));
  static const VerificationMeta _tagIdMeta = VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.int,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tags (id)'));
  @override
  List<GeneratedColumn> get columns => [noteId, tagId];
  @override
  String get aliasedName => _alias;
  @override
  String get actualTableName => 'note_tags';
  @override
  VerificationContext validateIntegrity(Insertable<NoteTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note_id')) {
      context.handle(_noteIdMeta,
          noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta));
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId, tagId};
  @override
  NoteTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteTag(
      noteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}note_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $NoteTagsTable createAlias(String alias) {
    return $NoteTagsTable(attachedDatabase, alias);
  }
}

class NoteTag extends DataClass implements Insertable<NoteTag> {
  final int noteId;
  final int tagId;
  const NoteTag({required this.noteId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note_id'] = Variable<int>(noteId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  NoteTagCompanion toCompanion(bool nullToAbsent) {
    return NoteTagCompanion(
      noteId: Value(noteId),
      tagId: Value(tagId),
    );
  }

  factory NoteTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteTag(
      noteId: serializer.fromJson<int>(json['noteId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noteId': serializer.toJson<int>(noteId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  NoteTag copyWith({int? noteId, int? tagId}) => NoteTag(
        noteId: noteId ?? this.noteId,
        tagId: tagId ?? this.tagId,
      );

  @override
  String toString() {
    return (StringBuffer('NoteTag(')
          ..write('noteId: $noteId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(noteId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteTag &&
          other.noteId == noteId &&
          other.tagId == tagId);
}

class NoteTagCompanion extends UpdateCompanion<NoteTag> {
  final Value<int> noteId;
  final Value<int> tagId;
  const NoteTagCompanion({
    this.noteId = const Value.absent(),
    this.tagId = const Value.absent(),
  });
  NoteTagCompanion.insert({
    required int noteId,
    required int tagId,
  })  : noteId = Value(noteId),
        tagId = Value(tagId);
  static Insertable<NoteTag> custom({
    Expression<int>? noteId,
    Expression<int>? tagId,
  }) {
    return RawValuesInsertable({
      if (noteId != null) 'note_id': noteId,
      if (tagId != null) 'tag_id': tagId,
    });
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noteId.present) map['note_id'] = Variable<int>(noteId.value);
    if (tagId.present) map['tag_id'] = Variable<int>(tagId.value);
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteTagCompanion(')
          ..write('noteId: $noteId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }
}

class $ChecklistItemsTable extends ChecklistItems
    with TableInfo<$ChecklistItemsTable, ChecklistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String _alias;
  $ChecklistItemsTable(this.attachedDatabase, [this._alias = 'checklist_items']);
  static const VerificationMeta _idMeta = VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _noteIdMeta = VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
      'note_id', aliasedName, false,
      type: DriftSqlType.int,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES notes (id)'));
  static const VerificationMeta _textMeta = VerificationMeta('text');
  @override
  late final GeneratedColumn<String> text = GeneratedColumn<String>(
      'text', aliasedName, false,
      type: DriftSqlType.string);
  static const VerificationMeta _isCompletedMeta =
      VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta = VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get columns =>
      [id, noteId, text, isCompleted, sortOrder];
  @override
  String get aliasedName => _alias;
  @override
  String get actualTableName => 'checklist_items';
  @override
  VerificationContext validateIntegrity(Insertable<ChecklistItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('note_id')) {
      context.handle(_noteIdMeta,
          noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta));
    }
    if (data.containsKey('text')) {
      context.handle(
          _textMeta, text.isAcceptableOrUnknown(data['text']!, _textMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChecklistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChecklistItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      noteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}note_id'])!,
      text: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $ChecklistItemsTable createAlias(String alias) {
    return $ChecklistItemsTable(attachedDatabase, alias);
  }
}

class ChecklistItem extends DataClass implements Insertable<ChecklistItem> {
  final int id;
  final int noteId;
  final String text;
  final bool isCompleted;
  final int sortOrder;
  const ChecklistItem(
      {required this.id,
      required this.noteId,
      required this.text,
      required this.isCompleted,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['note_id'] = Variable<int>(noteId);
    map['text'] = Variable<String>(text);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ChecklistItemCompanion toCompanion(bool nullToAbsent) {
    return ChecklistItemCompanion(
      id: Value(id),
      noteId: Value(noteId),
      text: Value(text),
      isCompleted: Value(isCompleted),
      sortOrder: Value(sortOrder),
    );
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChecklistItem(
      id: serializer.fromJson<int>(json['id']),
      noteId: serializer.fromJson<int>(json['noteId']),
      text: serializer.fromJson<String>(json['text']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'noteId': serializer.toJson<int>(noteId),
      'text': serializer.toJson<String>(text),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ChecklistItem copyWith(
          {int? id,
          int? noteId,
          String? text,
          bool? isCompleted,
          int? sortOrder}) =>
      ChecklistItem(
        id: id ?? this.id,
        noteId: noteId ?? this.noteId,
        text: text ?? this.text,
        isCompleted: isCompleted ?? this.isCompleted,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  @override
  String toString() {
    return (StringBuffer('ChecklistItem(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('text: $text, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, noteId, text, isCompleted, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChecklistItem &&
          other.id == id &&
          other.noteId == noteId &&
          other.text == text &&
          other.isCompleted == isCompleted &&
          other.sortOrder == sortOrder);
}

class ChecklistItemCompanion extends UpdateCompanion<ChecklistItem> {
  final Value<int> id;
  final Value<int> noteId;
  final Value<String> text;
  final Value<bool> isCompleted;
  final Value<int> sortOrder;
  const ChecklistItemCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.text = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ChecklistItemCompanion.insert({
    this.id = const Value.absent(),
    required int noteId,
    required String text,
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
  })  : noteId = Value(noteId),
        text = Value(text);
  static Insertable<ChecklistItem> custom({
    Expression<int>? id,
    Expression<int>? noteId,
    Expression<String>? text,
    Expression<bool>? isCompleted,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (text != null) 'text': text,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) map['id'] = Variable<int>(id.value);
    if (noteId.present) map['note_id'] = Variable<int>(noteId.value);
    if (text.present) map['text'] = Variable<String>(text.value);
    if (isCompleted.present)
      map['is_completed'] = Variable<bool>(isCompleted.value);
    if (sortOrder.present) map['sort_order'] = Variable<int>(sortOrder.value);
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistItemCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('text: $text, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $NoteColorValuesTable extends NoteColorValues
    with TableInfo<$NoteColorValuesTable, NoteColorValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String _alias;
  $NoteColorValuesTable(this.attachedDatabase, [this._alias = 'note_color_values']);
  static const VerificationMeta _valueMeta = VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
      'value', aliasedName, false,
      type: DriftSqlType.int);
  static const VerificationMeta _labelMeta = VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string);
  @override
  List<GeneratedColumn> get columns => [value, label];
  @override
  String get aliasedName => _alias;
  @override
  String get actualTableName => 'note_color_values';
  @override
  VerificationContext validateIntegrity(Insertable<NoteColorValue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {value};
  @override
  NoteColorValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteColorValue(
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}value'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
    );
  }

  @override
  $NoteColorValuesTable createAlias(String alias) {
    return $NoteColorValuesTable(attachedDatabase, alias);
  }
}

class NoteColorValue extends DataClass implements Insertable<NoteColorValue> {
  final int value;
  final String label;
  const NoteColorValue({required this.value, required this.label});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['value'] = Variable<int>(value);
    map['label'] = Variable<String>(label);
    return map;
  }

  NoteColorValuesCompanion toCompanion(bool nullToAbsent) {
    return NoteColorValuesCompanion(
      value: Value(value),
      label: Value(label),
    );
  }

  factory NoteColorValue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteColorValue(
      value: serializer.fromJson<int>(json['value']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'value': serializer.toJson<int>(value),
      'label': serializer.toJson<String>(label),
    };
  }

  NoteColorValue copyWith({int? value, String? label}) => NoteColorValue(
        value: value ?? this.value,
        label: label ?? this.label,
      );

  @override
  String toString() {
    return (StringBuffer('NoteColorValue(')
          ..write('value: $value, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(value, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteColorValue &&
          other.value == value &&
          other.label == label);
}

class NoteColorValuesCompanion extends UpdateCompanion<NoteColorValue> {
  final Value<int> value;
  final Value<String> label;
  const NoteColorValuesCompanion({
    this.value = const Value.absent(),
    this.label = const Value.absent(),
  });
  NoteColorValuesCompanion.insert({
    required int value,
    required String label,
  })  : value = Value(value),
        label = Value(label);
  static Insertable<NoteColorValue> custom({
    Expression<int>? value,
    Expression<String>? label,
  }) {
    return RawValuesInsertable({
      if (value != null) 'value': value,
      if (label != null) 'label': label,
    });
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (value.present) map['value'] = Variable<int>(value.value);
    if (label.present) map['label'] = Variable<String>(label.value);
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteColorValuesCompanion(')
          ..write('value: $value, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $NotesTable notes = $NotesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $NoteTagsTable noteTags = $NoteTagsTable(this);
  late final $ChecklistItemsTable checklistItems = $ChecklistItemsTable(this);
  late final $NoteColorValuesTable noteColorValues = $NoteColorValuesTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [notes, tags, noteTags, checklistItems, noteColorValues];
}
