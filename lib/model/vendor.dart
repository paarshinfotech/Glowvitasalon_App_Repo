class Vendor {
  final String id;
  final String firstName;
  final String lastName;
  final String businessName;
  final String state;
  final String city;
  final String category;
  final List<String> subCategories;
  final String description;
  final String profileImage;
  final Map<String, dynamic> subscription;
  final String createdAt;
  final List<Service> services;

  Vendor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.businessName,
    required this.state,
    required this.city,
    required this.category,
    required this.subCategories,
    required this.description,
    required this.profileImage,
    required this.subscription,
    required this.createdAt,
    required this.services,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      businessName: json['businessName'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      category: json['category'] ?? '',
      subCategories: List<String>.from(json['subCategories'] ?? []),
      description: json['description'] ?? '',
      profileImage: json['profileImage'] ?? '',
      subscription: json['subscription'] ?? {},
      createdAt: json['createdAt'] ?? '',
      services: (json['services'] as List<dynamic>?)
              ?.map((service) => Service.fromJson(service))
              .toList() ??
          [],
    );
  }

  // Get full image URL with proper formatting
  String get fullImageUrl {
    if (profileImage.isEmpty) {
      return ''; // Return an empty string if no image is available.
    }
    
    const String baseUrl = "https://v2winonline.com";
    
    if (profileImage.startsWith('http')) {
      return profileImage; // Already a full URL.
    }
    
    // Remove any leading slashes from the image path to prevent double slashes.
    final imagePath = profileImage.startsWith('/') ? profileImage.substring(1) : profileImage;
    return "$baseUrl/$imagePath";
  }
}

class Service {
  final String id;
  final String name;
  final Category category;
  final int price;
  final int duration;
  final String description;

  Service({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.duration,
    required this.description,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: Category.fromJson(json['category'] ?? {}),
      price: json['price']?.toInt() ?? 0,
      duration: json['duration']?.toInt() ?? 0,
      description: json['description'] ?? '',
    );
  }
}

class Category {
  final String id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}