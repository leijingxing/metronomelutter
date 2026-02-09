import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:rhythm_metronome/global_data.dart';
import 'package:rhythm_metronome/model/score_sheet.dart';
import 'package:uuid/uuid.dart';

class ScoreSheetService {
  static const String _scoreSheetsKey = 'scoreSheets';
  static const String _selectedSheetIdKey = 'selectedScoreSheetId';
  static const String _sheetDirName = 'score_sheets';

  final Uuid _uuid = const Uuid();

  Future<List<ScoreSheet>> loadSheets() async {
    final String raw = GlobalData.sp.getString(_scoreSheetsKey) ?? '[]';
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) {
      return <ScoreSheet>[];
    }
    final List<ScoreSheet> sheets = decoded
        .whereType<Map>()
        .map((Map<dynamic, dynamic> e) =>
            ScoreSheet.fromJson(Map<String, dynamic>.from(e)))
        .where((ScoreSheet e) => e.id.isNotEmpty && e.imagePath.isNotEmpty)
        .toList();
    sheets.sort(
        (ScoreSheet a, ScoreSheet b) => b.createdAt.compareTo(a.createdAt));
    return sheets;
  }

  Future<void> saveSheets(List<ScoreSheet> sheets) async {
    final String encoded = jsonEncode(
      sheets.map((ScoreSheet e) => e.toJson()).toList(growable: false),
    );
    await GlobalData.sp.putString(_scoreSheetsKey, encoded);
  }

  String? loadSelectedId() {
    return GlobalData.sp.getString(_selectedSheetIdKey);
  }

  Future<void> saveSelectedId(String? id) async {
    if (id == null || id.isEmpty) {
      await GlobalData.sp.remove(_selectedSheetIdKey);
      return;
    }
    await GlobalData.sp.putString(_selectedSheetIdKey, id);
  }

  Future<ScoreSheet> addSheet({
    required String name,
    required String sourceImagePath,
  }) async {
    final Directory dir = await _sheetDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final String id = _uuid.v4();
    final String normalized = sourceImagePath.replaceAll('\\', '/');
    final String filename = normalized.split('/').last;
    final int dotIndex = filename.lastIndexOf('.');
    final String ext = dotIndex >= 0 ? filename.substring(dotIndex) : '';
    final String safeExt = ext.isEmpty ? '.jpg' : ext;
    final String separator = Platform.pathSeparator;
    final String targetPath = '${dir.path}$separator$id$safeExt';
    await File(sourceImagePath).copy(targetPath);
    return ScoreSheet(
      id: id,
      name: name,
      imagePath: targetPath,
      createdAt: DateTime.now(),
    );
  }

  Future<void> deleteSheetImage(String imagePath) async {
    final File file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _sheetDirectory() async {
    final Directory base = await getApplicationDocumentsDirectory();
    final String separator = Platform.pathSeparator;
    return Directory('${base.path}$separator$_sheetDirName');
  }
}
