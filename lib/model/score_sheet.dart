class ScoreSheet {
  final String id;
  final String name;
  final String imagePath;
  final DateTime createdAt;

  const ScoreSheet({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.createdAt,
  });

  factory ScoreSheet.fromJson(Map<String, dynamic> json) {
    return ScoreSheet(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
