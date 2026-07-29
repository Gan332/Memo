import 'package:flutter/material.dart';

import '../data/models/note_template.dart';

class TemplatePicker extends StatelessWidget {
  final void Function(NoteTemplate template) onSelect;

  const TemplatePicker({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '新建笔记',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: NoteTemplate.builtIn.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final template = NoteTemplate.builtIn[index];
                return ListTile(
                  leading: Text(
                    template.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(template.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onSelect(template),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
