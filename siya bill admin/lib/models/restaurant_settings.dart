class RestaurantSettingsModel {
  final String id;
  final String appUserId;
  final int billSequence;
  final DateTime updatedAt;

  RestaurantSettingsModel({
    required this.id,
    required this.appUserId,
    required this.billSequence,
    required this.updatedAt,
  });

  factory RestaurantSettingsModel.fromJson(Map<String, dynamic> json) => RestaurantSettingsModel(
    id: json['id'] as String? ?? 'global',
    appUserId: json['app_user_id'] as String? ?? '',
    billSequence: (json['bill_sequence'] as num?)?.toInt() ?? 1,
    updatedAt: json['updated_at'] != null 
        ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'app_user_id': appUserId,
    'bill_sequence': billSequence,
    'updated_at': updatedAt.toIso8601String(),
  };
}
