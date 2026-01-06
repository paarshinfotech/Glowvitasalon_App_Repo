class Category {
  final String id;
  final String name;
  final String iconUrl;

  Category({required this.id, required this.name, required this.iconUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    String image = json['categoryImage'] ?? '';
    if (image.isNotEmpty && !image.startsWith('http')) {
      // Remove leading slash if present
      if (image.startsWith('/')) image = image.substring(1);
      image = "https://v2winonline.com/$image";
    }

    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: image.isEmpty ? 'https://via.placeholder.com/60' : image,
    );
  }
}
