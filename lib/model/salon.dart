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
}
