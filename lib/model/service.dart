class Service {
  final String name;
  final String duration;
  final double price;
  final String category;
  final bool isDiscounted;
  final String? discountLabel;
  final String? imageUrl;

  Service({
    required this.name,
    required this.duration,
    required this.price,
    required this.category,
    this.isDiscounted = false,
    this.discountLabel,
    this.imageUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Service && other.name == name && other.category == category;
  }

  @override
  int get hashCode => name.hashCode ^ category.hashCode;
}
