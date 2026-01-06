import 'package:glow_vita_salon/model/service.dart';

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
  final List<String> gallery;
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
    required this.gallery,
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
      gallery: List<String>.from(json['gallery'] ?? []),
      subscription: json['subscription'] ?? {},
      createdAt: json['createdAt'] ?? '',
      services:
          (json['services'] as List<dynamic>?)
              ?.map((service) => Service.fromJson(service))
              .toList() ??
          [],
    );
  }

  // Helper to format image URL
  String _formatUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    const String baseUrl = "https://v2winonline.com";
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "$baseUrl/$cleanPath";
  }

  // Get full image URL with proper formatting
  String get fullImageUrl => _formatUrl(profileImage);

  // Get full gallery URLs
  List<String> get fullGalleryUrls => gallery.map(_formatUrl).toList();
}
