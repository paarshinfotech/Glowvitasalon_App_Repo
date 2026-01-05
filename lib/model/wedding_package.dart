import 'package:glow_vita_salon/model/service.dart';

class WeddingPackage {
  final String name;
  final String description;
  final String duration;
  final double price;
  final String? imageUrl;
  final List<Service> services;

  WeddingPackage({
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    this.imageUrl,
    required this.services,
  });
}
