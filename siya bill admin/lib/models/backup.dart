class BackupModel {
  final String name;
  final int sizeBytes;
  final DateTime createdAt;
  final String path;

  BackupModel({
    required this.name,
    required this.sizeBytes,
    required this.createdAt,
    required this.path,
  });

  String get sizeFormatted {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory BackupModel.fromJson(Map<String, dynamic> json) => BackupModel(
    name: json['name'] as String? ?? '',
    sizeBytes: json['size'] as int? ?? json['size_bytes'] as int? ?? 0,
    createdAt: json['created_at'] != null 
        ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
        : DateTime.now(),
    path: json['path'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'size': sizeBytes,
    'created_at': createdAt.toIso8601String(),
    'path': path,
  };
}
