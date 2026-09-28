class PlanModel {
  final String id;
  final String name;
  final double price;
  final int durationDays;
  final List<String> features;
  final bool isActive;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.features,
    required this.isActive,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    var rawFeatures = json['features'] as List?;
    List<String> parsedFeatures = rawFeatures != null
        ? rawFeatures.map((f) => f.toString()).toList()
        : [];
    return PlanModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 30,
      features: parsedFeatures,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'duration_days': durationDays,
    'features': features,
    'is_active': isActive,
  };
}
