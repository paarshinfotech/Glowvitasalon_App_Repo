class Product {
  final String id;
  final String name;
  final String description;
  final int price;
  final int salePrice;
  final String image;
  final String vendorId;
  final String vendorName;
  final String category;
  final int stock;
  final bool isNew;
  final String rating;
  final int reviewCount;
  final String hint;
  final bool isFlashSale;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.salePrice,
    required this.image,
    required this.vendorId,
    required this.vendorName,
    required this.category,
    required this.stock,
    required this.isNew,
    required this.rating,
    required this.reviewCount,
    required this.hint,
    required this.isFlashSale,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      salePrice: json['salePrice'] ?? 0,
      image: json['image'] ?? '',
      vendorId: json['vendorId'] ?? '',
      vendorName: json['vendorName'] ?? '',
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      isNew: json['isNew'] ?? false,
      rating: json['rating']?.toString() ?? '0',
      reviewCount: json['reviewCount'] ?? 0,
      hint: json['hint'] ?? '',
      isFlashSale: json['isFlashSale'] ?? false,
    );
  }

  // This getter now robustly constructs the full image URL.
  String get fullImageUrl {
    const String baseUrl = "https://v2winonline.com";
    if (image.isEmpty) {
      return ''; // Return an empty string if the image path is not available.
    }
    if (image.startsWith('http')) {
      return image; // Already a full URL.
    }
    // Remove any leading slashes from the image path to prevent double slashes.
    final imagePath = image.startsWith('/') ? image.substring(1) : image;
    return "$baseUrl/$imagePath";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'salePrice': salePrice,
      'image': image,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'category': category,
      'stock': stock,
      'isNew': isNew,
      'rating': rating,
      'reviewCount': reviewCount,
      'hint': hint,
      'isFlashSale': isFlashSale,
    };
  }
}
