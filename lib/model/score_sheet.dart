class ScoreSheet {
  final String id;
  final String name;
  final List<String> imagePaths;
  final DateTime createdAt;

  const ScoreSheet({
    required this.id,
    required this.name,
    required this.imagePaths,
    required this.createdAt,
  });

  String get coverImagePath => imagePaths.isEmpty ? '' : imagePaths.first;

  factory ScoreSheet.fromJson(Map<String, dynamic> json) {
    final List<String> paths =
        ((json['imagePaths'] as List<dynamic>?) ?? <dynamic>[])
            .map((dynamic e) => e.toString())
            .where((String e) => e.isNotEmpty)
            .toList();
    if (paths.isEmpty) {
      final String legacyPath = json['imagePath'] as String? ?? '';
      if (legacyPath.isNotEmpty) {
        paths.add(legacyPath);
      }
    }
    return ScoreSheet(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imagePaths: paths,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'imagePaths': imagePaths,
      'imagePath': coverImagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
