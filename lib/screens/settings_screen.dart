import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../l10n/app_localizations.dart';
import '../state/providers/theme_provider.dart';
import '../services/backup_service.dart';
import '../services/platform_file.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ListView(
            children: [
              _buildSectionHeader(context, l10n.appearance),
              _buildThemeTile(context, themeProvider, l10n),
              _buildDynamicColorTile(context, themeProvider, l10n),
              _buildLanguageTile(context, themeProvider, l10n),
              const Divider(height: 32),
              _buildSectionHeader(context, l10n.data),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: Text(l10n.exportBackup),
                subtitle: Text(l10n.exportBackupSubtitle),
                onTap: () => _exportBackup(context, l10n),
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: Text(l10n.importBackup),
                subtitle: Text(l10n.importBackupSubtitle),
                onTap: () => _importBackup(context, l10n),
              ),
              const Divider(height: 32),
              _buildSectionHeader(context, l10n.about),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.version),
                subtitle: const Text('1.0.0'),
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

  Widget _buildThemeTile(
      BuildContext context, ThemeProvider themeProvider, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: Text(l10n.themeMode),
      trailing: SegmentedButton<ThemeMode>(
        segments: [
          const ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode),
          ),
          const ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode),
          ),
          const ButtonSegment(
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
      BuildContext context, ThemeProvider themeProvider, AppLocalizations l10n) {
    return SwitchListTile(
      secondary: const Icon(Icons.palette),
      title: Text(l10n.dynamicColor),
      subtitle: Text(l10n.dynamicColorSubtitle),
      value: themeProvider.useDynamicColor,
      onChanged: (value) {
        themeProvider.setUseDynamicColor(value);
      },
    );
  }

  Widget _buildLanguageTile(
      BuildContext context, ThemeProvider themeProvider, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language),
      trailing: SegmentedButton<String>(
        segments: [
          ButtonSegment(
            value: 'zh',
            label: Text(l10n.languageChinese),
          ),
          ButtonSegment(
            value: 'en',
            label: Text(l10n.languageEnglish),
          ),
        ],
        selected: {themeProvider.locale.languageCode},
        onSelectionChanged: (codes) {
          final code = codes.first;
          themeProvider.setLocale(Locale(code, code == 'zh' ? 'CN' : 'US'));
        },
      ),
    );
  }

  Future<void> _exportBackup(
      BuildContext context, AppLocalizations l10n) async {
    try {
      final service = BackupService();
      final json = await service.exportBackup();
      final path = await saveBackupToFile(json);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportedBackup(path))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _importBackup(
      BuildContext context, AppLocalizations l10n) async {
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
            content: Text(l10n.importComplete(
              added: metadata.addedCount,
              updated: metadata.updatedCount,
              skipped: metadata.skippedCount,
              failed: metadata.failedCount,
            )),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importFailed(e.toString()))),
        );
      }
    }
  }
}
