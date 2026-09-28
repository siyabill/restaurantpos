class OutletModel {
  final String id;
  final String name;
  final String location;
  final String contactNumber;
  final String gstNumber;
  final String fssaiNumber;
  final bool isActive;
  final int syncLatencySec;
  final String activeProfile;

  OutletModel({
    required this.id,
    required this.name,
    required this.location,
    required this.contactNumber,
    required this.gstNumber,
    required this.fssaiNumber,
    required this.isActive,
    required this.syncLatencySec,
    required this.activeProfile,
  });

  factory OutletModel.fromJson(Map<String, dynamic> json) => OutletModel(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    location: json['location'] as String? ?? '',
    contactNumber: json['contact_number'] as String? ?? '',
    gstNumber: json['gst_number'] as String? ?? '',
    fssaiNumber: json['fssai_number'] as String? ?? '',
    isActive: json['is_active'] as bool? ?? true,
    syncLatencySec: json['sync_latency_sec'] as int? ?? 0,
    activeProfile: json['active_profile'] as String? ?? 'Standard',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'contact_number': contactNumber,
    'gst_number': gstNumber,
    'fssai_number': fssaiNumber,
    'is_active': isActive,
    'sync_latency_sec': syncLatencySec,
    'active_profile': activeProfile,
  };
}
