class BillModel {
  final String id;
  final String appUserId;
  final double totalAmount;
  final DateTime timestamp;

  BillModel({
    required this.id,
    required this.appUserId,
    required this.totalAmount,
    required this.timestamp,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
    id: json['id'] as String? ?? '',
    appUserId: json['app_user_id'] as String? ?? '',
    totalAmount: (json['total_amount'] as num? ?? json['total'] as num? ?? 0.0).toDouble(),
    timestamp: json['timestamp'] != null 
        ? (json['timestamp'] is num
            ? ((json['timestamp'] as num).toInt() < 100000000000
                ? DateTime.fromMillisecondsSinceEpoch((json['timestamp'] as num).toInt() * 1000)
                : DateTime.fromMillisecondsSinceEpoch((json['timestamp'] as num).toInt()))
            : DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now())
        : json['created_at'] != null 
            ? (json['created_at'] is num
                ? ((json['created_at'] as num).toInt() < 100000000000
                    ? DateTime.fromMillisecondsSinceEpoch((json['created_at'] as num).toInt() * 1000)
                    : DateTime.fromMillisecondsSinceEpoch((json['created_at'] as num).toInt()))
                : DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
            : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'app_user_id': appUserId,
    'total_amount': totalAmount,
    'timestamp': timestamp.toIso8601String(),
  };
}
