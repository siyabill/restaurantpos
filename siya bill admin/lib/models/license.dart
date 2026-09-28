class LicenseModel {
  final String id;
  final String licenseKey;
  final String planType;
  final int expiryDays;
  final String status;
  final String restaurantCode;
  final String? claimedByUserId;
  final DateTime? claimedAt;
  final DateTime createdAt;

  LicenseModel({
    required this.id,
    required this.licenseKey,
    required this.planType,
    required this.expiryDays,
    required this.status,
    required this.restaurantCode,
    this.claimedByUserId,
    this.claimedAt,
    required this.createdAt,
  });

  factory LicenseModel.fromJson(Map<String, dynamic> json) => LicenseModel(
    id: json['id'] as String? ?? '',
    licenseKey: json['license_key'] as String? ?? '',
    planType: json['plan_type'] as String? ?? 'monthly',
    expiryDays: (json['expiry_days'] as num?)?.toInt() ?? 30,
    status: json['status'] as String? ?? 'active',
    restaurantCode: json['restaurant_code'] as String? ?? '',
    claimedByUserId: json['claimed_by_user_id'] as String?,
    claimedAt: json['claimed_at'] != null ? DateTime.tryParse(json['claimed_at'] as String) : null,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now() : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'license_key': licenseKey,
    'plan_type': planType,
    'expiry_days': expiryDays,
    'status': status,
    'restaurant_code': restaurantCode,
    if (claimedByUserId != null) 'claimed_by_user_id': claimedByUserId,
    if (claimedAt != null) 'claimed_at': claimedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}
