class Offer {
  final String id;
  final String code;
  final String
  type; // 'percentage' or 'flat' (assuming flat is possible based on naming)
  final double value;
  final String status;
  final DateTime? startDate;
  final DateTime? expires;
  final List<String> applicableServices;
  final List<String> applicableCategories;

  Offer({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.status,
    this.startDate,
    this.expires,
    this.applicableServices = const [],
    this.applicableCategories = const [],
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? 'percentage',
      value: (json['value'] is int)
          ? (json['value'] as int).toDouble()
          : (json['value'] as double? ?? 0.0),
      status: json['status'] ?? 'Inactive',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      expires: json['expires'] != null
          ? DateTime.tryParse(json['expires'])
          : null,
      applicableServices: json['applicableServices'] != null
          ? List<String>.from(json['applicableServices'])
          : [],
      applicableCategories: json['applicableServiceCategories'] != null
          ? List<String>.from(json['applicableServiceCategories'])
          : [],
    );
  }
}
