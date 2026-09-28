class SettingsModel {
  final String appUserId;
  final String id;
  final Map<String, dynamic> data;
  final DateTime updatedAt;

  SettingsModel({
    required this.appUserId,
    required this.id,
    required this.data,
    required this.updatedAt,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    appUserId: json['app_user_id'] as String? ?? 'global',
    id: json['id'] as String? ?? '',
    data: json['data'] as Map<String, dynamic>? ?? {},
    updatedAt: json['updated_at'] != null 
        ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'app_user_id': appUserId,
    'id': id,
    'data': data,
    'updated_at': updatedAt.toIso8601String(),
  };
}
