import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../data/database/app_database.dart';

class AttachmentService {
  final AppDatabase _db;

  AttachmentService({AppDatabase? db}) : _db = db ?? AppDatabase();

  Future<String> get _attachmentsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'attachments'));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir.path;
  }

  Future<int> addAttachment({
    required int noteId,
    required String sourcePath,
    required String fileName,
    required String mimeType,
  }) async {
    final dir = await _attachmentsDir;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = p.extension(fileName);
    final newFileName = '${noteId}_$timestamp$ext';
    final destPath = p.join(dir, newFileName);

    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);

    final fileSize = await sourceFile.length();

    return _db.into(_db.attachments).insert(
          AttachmentsCompanion.insert(
            noteId: noteId,
            filePath: destPath,
            fileName: fileName,
            mimeType: mimeType,
            fileSize: Value(fileSize),
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
  }

  Future<List<Attachment>> getAttachmentsForNote(int noteId) async {
    return (_db.select(_db.attachments)
          ..where((a) => a.noteId.equals(noteId))
          ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
        .get();
  }

  Future<void> deleteAttachment(int id) async {
    final attachment = await (_db.select(_db.attachments)
          ..where((a) => a.id.equals(id)))
        .getSingleOrNull();

    if (attachment != null) {
      final file = File(attachment.filePath);
      if (file.existsSync()) {
        await file.delete();
      }
      await (_db.delete(_db.attachments)
            ..where((a) => a.id.equals(id)))
          .go();
    }
  }

  Future<void> deleteAttachmentsForNote(int noteId) async {
    final attachments = await getAttachmentsForNote(noteId);
    for (final attachment in attachments) {
      final file = File(attachment.filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    }
    await (_db.delete(_db.attachments)
          ..where((a) => a.noteId.equals(noteId)))
        .go();
  }
}
