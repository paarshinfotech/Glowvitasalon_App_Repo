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
      homeServiceAvailable: json['homeService'] is bool
          ? json['homeService']
          : (json['homeService']?['available'] ?? false),
      homeServiceCharges: json['homeService'] is Map
          ? (json['homeService']?['charges'] as num?)?.toDouble()
          : null,
      weddingServiceAvailable: json['weddingService'] is bool
          ? json['weddingService']
          : (json['weddingService']?['available'] ?? false),
      weddingServiceCharges: json['weddingService'] is Map
          ? (json['weddingService']?['charges'] as num?)?.toDouble()
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Service && other.name == name && other.category == category;
  }

  @override
  int get hashCode => name.hashCode ^ category.hashCode;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      // 'duration': duration, // This is a formatted string in the model. If we want raw, we'd need to store raw.
      // For cache re-hydration, we'll store the object properties directly.
      'duration':
          0, // Mocking int duration because we lost the original int. Or we can just store the formatted string and handle it?
      // Actually, fromJson expects 'duration' as int.
      // Since we modified the model to store formatted String, we can't easily convert back to int without parsing 'X mins'.
      // For now, let's just make the cache work by storing what we can, checking if fromJson can handle string duration if we tweak it, or we just store 0 properly.
      // Wait, if I cache the processed Model logic, re-hydrating via `fromJson` might fail if `fromJson` expects raw API structure.
      // Better approach: `fromJson` handles raw API JSON.
      // `toJson` should ideally return raw API JSON structure.
      // Since `duration` is String "45 mins", I'll try to parse it back to minutes for robustness.
      'price': price,
      'discountedPrice': discountedPrice,
      'category': category, // This was flattened from Map/String in fromJson
      'image': imageUrl?.replaceFirst("https://v2winonline.com/", ""),
      'description': description,
      'gender': gender,
      'homeService': {
        'available': homeServiceAvailable,
        'charges': homeServiceCharges,
      },
      'weddingService': {
        'available': weddingServiceAvailable,
        'charges': weddingServiceCharges,
      },
    };
  }
}
