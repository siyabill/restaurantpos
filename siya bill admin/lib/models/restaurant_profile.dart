class RestaurantProfileModel {
  final String id;
  final String appUserId;
  final String restaurantName;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? fssaiNumber;
  final String? upiId;
  final bool upiEnabled;
  final String? thankYouMessage;
  final double gstPercentage;
  final String subscriptionStatus;
  final double subscriptionExpiry;
  final String subscriptionPlan;
  final String? restaurantCode;
  final String? licenseKey;
  final double? activationDate;
  final bool referredByRewardGranted;
  final DateTime updatedAt;

  RestaurantProfileModel({
    required this.id,
    required this.appUserId,
    required this.restaurantName,
    this.phone,
    this.email,
    this.address,
    this.gstNumber,
    this.fssaiNumber,
    this.upiId,
    this.upiEnabled = false,
    this.thankYouMessage,
    this.gstPercentage = 0.0,
    required this.subscriptionStatus,
    required this.subscriptionExpiry,
    required this.subscriptionPlan,
    this.restaurantCode,
    this.licenseKey,
    this.activationDate,
    this.referredByRewardGranted = false,
    required this.updatedAt,
  });

  bool get isActive => subscriptionStatus == 'premium' || subscriptionStatus == 'trial';

  factory RestaurantProfileModel.fromJson(Map<String, dynamic> json) => RestaurantProfileModel(
    id: json['id'] as String? ?? 'global',
    appUserId: json['app_user_id'] as String? ?? '',
    restaurantName: json['restaurant_name'] as String? ?? '',
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    address: json['address'] as String?,
    gstNumber: json['gst_number'] as String?,
    fssaiNumber: json['fssai_number'] as String?,
    upiId: json['upi_id'] as String?,
    upiEnabled: json['upi_enabled'] as bool? ?? false,
    thankYouMessage: json['thank_you_message'] as String?,
    gstPercentage: (json['gst_percentage'] as num?)?.toDouble() ?? 0.0,
    subscriptionStatus: json['subscription_status'] as String? ?? 'trial',
    subscriptionExpiry: (json['subscription_expiry'] as num?)?.toDouble() ?? 0.0,
    subscriptionPlan: json['subscription_plan'] as String? ?? 'free-trial',
    restaurantCode: json['restaurant_code'] as String?,
    licenseKey: json['license_key'] as String?,
    activationDate: (json['activation_date'] as num?)?.toDouble(),
    referredByRewardGranted: json['referred_by_reward_granted'] as bool? ?? false,
    updatedAt: json['updated_at'] != null 
        ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'app_user_id': appUserId,
    'restaurant_name': restaurantName,
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (address != null) 'address': address,
    if (gstNumber != null) 'gst_number': gstNumber,
    if (fssaiNumber != null) 'fssai_number': fssaiNumber,
    if (upiId != null) 'upi_id': upiId,
    'upi_enabled': upiEnabled,
    if (thankYouMessage != null) 'thank_you_message': thankYouMessage,
    'gst_percentage': gstPercentage,
    'subscription_status': subscriptionStatus,
    'subscription_expiry': subscriptionExpiry,
    'subscription_plan': subscriptionPlan,
    if (restaurantCode != null) 'restaurant_code': restaurantCode,
    if (licenseKey != null) 'license_key': licenseKey,
    if (activationDate != null) 'activation_date': activationDate,
    'referred_by_reward_granted': referredByRewardGranted,
    'updated_at': updatedAt.toIso8601String(),
  };
}
