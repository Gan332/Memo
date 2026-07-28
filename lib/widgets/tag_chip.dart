import 'package:flutter/material.dart';

import '../domain/entities/tag_entity.dart';

class TagChip extends StatelessWidget {
  final TagEntity tag;
  final VoidCallback? onDeleted;

  const TagChip({
    super.key,
    required this.tag,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: tag.backgroundColor,
        radius: 8,
      ),
      label: Text(
        tag.name,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      onDeleted: onDeleted,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
