class Service {
  final String? id;
  final String name;
  final String
  duration; // API returns int (minutes), but UI uses String. We'll convert.
  final double price;
  final String category;
  final bool isDiscounted;
  final String? discountLabel;
  final String? imageUrl;
  final String? description;
  final double? discountedPrice;
  final String? gender;
  final bool? homeServiceAvailable;
  final double? homeServiceCharges;
  final bool? weddingServiceAvailable;
  final double? weddingServiceCharges;

  Service({
    this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.category,
    this.isDiscounted = false,
    this.discountLabel,
    this.imageUrl,
    this.description,
    this.discountedPrice,
    this.gender,
    this.homeServiceAvailable,
    this.homeServiceCharges,
    this.weddingServiceAvailable,
    this.weddingServiceCharges,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // Helper to format duration
    String formatDuration(int? minutes) {
      if (minutes == null) return '';
      if (minutes < 60) return '$minutes mins';
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) return '$hours hrs';
      return '$hours hrs $mins mins';
    }

    // Helper for image URL
    String getFullImageUrl(String? path) {
      if (path == null || path.isEmpty)
        return 'https://via.placeholder.com/150';
      if (path.startsWith('http')) return path;
      const baseUrl = "https://v2winonline.com";
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;
      return "$baseUrl/$cleanPath";
    }

    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final discountedPrice = (json['discountedPrice'] as num?)?.toDouble();
    final isDiscounted = discountedPrice != null && discountedPrice < price;

    // Calculate save % for discount label
    String? discountLabel;
    if (isDiscounted) {
      final diff = price - discountedPrice;
      final percent = (diff / price) * 100;
      discountLabel = 'Save ${percent.round()}%';
    }

    return Service(
      id: json['_id'],
      name: json['name'] ?? '',
      duration: formatDuration(json['duration'] as int?),
      price:
          discountedPrice ??
          price, // Use discounted price as main display price? Or original?

      // Usually UI shows current price. If discounted, current is discountedPrice.
      // But wait, the UI might show strike-through.
      // The Model has `price` and `discountedPrice`.
      // Let's use `price` as the base price and `discountedPrice` as the special price?
      // Or `price` as the effective price the user pays?
      // Based on existing: `price` seems to be the one used for calculations.
      // So if there is a discount, `price` in model should be the effective price (discountedPrice).
      // And we can perform logic to show original price if needed, but existing model doesn't have originalPrice field.
      // I'll stick to: price = effective price.
      category: json['category'] is Map
          ? (json['category']['name'] ?? '')
          : (json['category'] as String? ?? ''),
      isDiscounted: isDiscounted,
      discountLabel: discountLabel,
      imageUrl: getFullImageUrl(json['image']),
      description: json['description'],
      discountedPrice: discountedPrice,
      gender: json['gender'],
      homeServiceAvailable: json['homeService']?['available'] ?? false,
      homeServiceCharges: (json['homeService']?['charges'] as num?)?.toDouble(),
      weddingServiceAvailable: json['weddingService']?['available'] ?? false,
      weddingServiceCharges: (json['weddingService']?['charges'] as num?)
          ?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Service && other.name == name && other.category == category;
  }

  @override
  int get hashCode => name.hashCode ^ category.hashCode;
}
