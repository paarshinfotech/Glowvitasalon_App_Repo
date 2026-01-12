import 'package:glow_vita_salon/model/service.dart';
import 'package:glow_vita_salon/model/specialist.dart';

class PackageService {
  final Service service;
  final bool isLocked;

  PackageService({required this.service, this.isLocked = false});
}

class WeddingPackage {
  final String name;
  final String description;
  final String duration;
  final double price;
  final String? imageUrl;
  final List<PackageService> services;
  final List<Specialist> staff;
  final int bufferTimeMinutes;

  WeddingPackage({
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    this.imageUrl,
    required this.services,
    this.staff = const [],
    this.bufferTimeMinutes = 30, // Default 30 mins for setup/travel
  });
}
