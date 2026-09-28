class ViolationModel {
  final String userId;
  final int warningCount;
  final String warningDate;
  final DateTime? blockedUntil;
  final DateTime? blockedAt;
  final String? blockedReason;

  ViolationModel({
    required this.userId,
    required this.warningCount,
    required this.warningDate,
    this.blockedUntil,
    this.blockedAt,
    this.blockedReason,
  });

  bool get isCurrentlyBlocked {
    if (blockedUntil == null) return false;
    return blockedUntil!.isAfter(DateTime.now());
  }

  factory ViolationModel.fromJson(Map<String, dynamic> json) => ViolationModel(
    userId: json['user_id'] as String? ?? '',
    warningCount: json['warning_count'] as int? ?? 0,
    warningDate: json['warning_date'] as String? ?? '',
    blockedUntil: json['blocked_until'] != null ? DateTime.tryParse(json['blocked_until'] as String) : null,
    blockedAt: json['blocked_at'] != null ? DateTime.tryParse(json['blocked_at'] as String) : null,
    blockedReason: json['blocked_reason'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'warning_count': warningCount,
    'warning_date': warningDate,
    if (blockedUntil != null) 'blocked_until': blockedUntil?.toIso8601String(),
    if (blockedAt != null) 'blocked_at': blockedAt?.toIso8601String(),
    if (blockedReason != null) 'blocked_reason': blockedReason,
  };
}
