import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../state/providers/theme_provider.dart';
import '../services/backup_service.dart';
import '../services/platform_file.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ListView(
            children: [
              _buildSectionHeader(context, '外观'),
              _buildThemeTile(context, themeProvider),
              _buildDynamicColorTile(context, themeProvider),
              const Divider(height: 32),
              _buildSectionHeader(context, '数据'),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('导出备份'),
                subtitle: const Text('导出所有笔记和标签'),
                onTap: () => _exportBackup(context),
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('导入备份'),
                subtitle: const Text('从备份文件恢复笔记'),
                onTap: () => _importBackup(context),
              ),
              const Divider(height: 32),
              _buildSectionHeader(context, '关于'),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('版本'),
                subtitle: Text('1.0.0'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('主题模式'),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.phone_android),
          ),
        ],
        selected: {themeProvider.themeMode},
        onSelectionChanged: (modes) {
          themeProvider.setThemeMode(modes.first);
        },
      ),
    );
  }

  Widget _buildDynamicColorTile(
      BuildContext context, ThemeProvider themeProvider) {
    return SwitchListTile(
      secondary: const Icon(Icons.palette),
      title: const Text('动态取色'),
      subtitle: const Text('使用系统壁纸颜色（Android 12+）'),
      value: themeProvider.useDynamicColor,
      onChanged: (value) {
        themeProvider.setUseDynamicColor(value);
      },
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    try {
      final service = BackupService();
      final json = await service.exportBackup();
      final filename = 'memo_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final path = await saveBackupToFile(json);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('备份已导出: $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final fileBytes = result.files.first.bytes;
      final filePath = result.files.first.path;
      String json;

      if (kIsWeb) {
        if (fileBytes == null) return;
        json = String.fromCharCodes(fileBytes);
      } else {
        if (filePath == null) return;
        json = await loadBackupFromFile(filePath);
      }

      final service = BackupService();
      final metadata = await service.importBackup(json);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '导入完成: 新增${metadata.addedCount}条, '
              '更新${metadata.updatedCount}条, '
              '跳过${metadata.skippedCount}条, '
              '失败${metadata.failedCount}条',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }
}
