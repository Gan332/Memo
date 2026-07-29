import '../../domain/entities/note_entity.dart';

class NoteTemplate {
  final String name;
  final String icon;
  final String title;
  final String content;
  final NoteType noteType;

  const NoteTemplate({
    required this.name,
    required this.icon,
    required this.title,
    required this.content,
    this.noteType = NoteType.text,
  });

  static const List<NoteTemplate> builtIn = [
    NoteTemplate(
      name: '空白笔记',
      icon: '📝',
      title: '',
      content: '',
    ),
    NoteTemplate(
      name: '会议记录',
      icon: '📋',
      title: '会议记录',
      content: '''# 会议记录

## 日期：

## 参会人员：

## 议程

1. 

## 讨论要点

## 行动项

- [ ] ''',
    ),
    NoteTemplate(
      name: '日记',
      icon: '📔',
      title: '日记',
      content: '''# 日记

## 今日完成

## 想法

## 明天计划

1. ''',
    ),
    NoteTemplate(
      name: '待办清单',
      icon: '✅',
      title: '待办清单',
      content: '''# 待办清单

- [ ] ''',
    ),
    NoteTemplate(
      name: '灵感',
      icon: '💡',
      title: '灵感',
      content: '''# 灵感

## 想法

## 为什么

## 下一步

''',
    ),
  ];
}
