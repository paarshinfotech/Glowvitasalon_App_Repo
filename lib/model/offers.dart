class Offer {
  final String title;
  final String description;
  final String imageUrl;

  Offer({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  // Factory constructor to safely create an Offer from a map (e.g., from JSON)
  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      title: map['title'] as String? ?? 'Special Offer',
      description: map['description'] as String? ?? 'Details not available',
      imageUrl: map['imageUrl'] as String? ?? 'https://via.placeholder.com/220x160',
    );
  }
}
