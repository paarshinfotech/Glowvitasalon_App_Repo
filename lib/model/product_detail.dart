class ProductDetail {
  final String id;
  final String name;
  final String description;
  final int price;
  final int salePrice;
  final List<String> images;
  final String vendorId;
  final String vendorName;
  final String vendorLocation;
  final String category;
  final int stock;
  final String rating;
  final int reviewCount;
  final String? size;
  final String? sizeMetric;
  final List<String> keyIngredients;
  final String? forBodyPart;
  final String? bodyPartType;
  final String? productForm;
  final String? brand;

  ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.salePrice,
    required this.images,
    required this.vendorId,
    required this.vendorName,
    required this.vendorLocation,
    required this.category,
    required this.stock,
    required this.rating,
    required this.reviewCount,
    this.size,
    this.sizeMetric,
    required this.keyIngredients,
    this.forBodyPart,
    this.bodyPartType,
    this.productForm,
    this.brand,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    return ProductDetail(
      id: productJson['id'] ?? '',
      name: productJson['name'] ?? '',
      description: productJson['description'] ?? '',
      price: productJson['price'] ?? 0,
      salePrice: productJson['salePrice'] ?? 0,
      images: List<String>.from(productJson['images'] ?? []),
      vendorId: productJson['vendorId'] ?? '',
      vendorName: productJson['vendorName'] ?? '',
      vendorLocation: productJson['vendorLocation'] ?? '',
      category: productJson['category'] ?? '',
      stock: productJson['stock'] ?? 0,
      rating: productJson['rating']?.toString() ?? '0',
      reviewCount: productJson['reviewCount'] ?? 0,
      size: productJson['size'],
      sizeMetric: productJson['sizeMetric'],
      keyIngredients: List<String>.from(productJson['keyIngredients'] ?? []),
      forBodyPart: productJson['forBodyPart'],
      bodyPartType: productJson['bodyPartType'],
      productForm: productJson['productForm'],
      brand: productJson['brand'],
    );
  }

  // This getter returns the first image URL with proper formatting
  String get fullImageUrl {
    if (images.isEmpty) {
      return ''; // Return an empty string if no images are available.
    }
    
    String firstImage = images.first;
    const String baseUrl = "https://v2winonline.com";
    
    if (firstImage.startsWith('http')) {
      return firstImage; // Already a full URL.
    }
    
    // Remove any leading slashes from the image path to prevent double slashes.
    final imagePath = firstImage.startsWith('/') ? firstImage.substring(1) : firstImage;
    return "$baseUrl/$imagePath";
  }
}
