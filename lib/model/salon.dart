import 'vendor.dart';

class Salon {
  final String name;
  final String salonType;
  final String address;
  final double rating;
  final int clientCount;
  final String imageUrl;
  final String description;
  final bool hasNewOffer;

  Salon({
    required this.name,
    required this.salonType,
    required this.address,
    required this.rating,
    required this.clientCount,
    required this.imageUrl,
    required this.description,
    this.hasNewOffer = false,
  });

  // Factory constructor to create a Salon from a Vendor
  factory Salon.fromVendor(Vendor vendor) {
    return Salon(
      name: vendor.businessName,
      salonType: vendor.category,
      address: '${vendor.city}, ${vendor.state}',
      rating: 4.5, // Default rating since it's not in the vendor data
      clientCount: 0, // Default client count since it's not in the vendor data
      imageUrl: vendor.fullImageUrl,
      description: vendor.description,
      hasNewOffer: false,
    );
  }
}