import 'package:flutter/material.dart';
import 'package:glow_vita_salon/controller/salon_details_controller.dart';
import 'package:glow_vita_salon/model/salon.dart';
import 'package:glow_vita_salon/model/product.dart';
import 'package:glow_vita_salon/model/feedback.dart';
import 'package:glow_vita_salon/widget/coupon_card.dart';
import 'package:glow_vita_salon/widget/product_card.dart';
import 'package:glow_vita_salon/widget/specialist_avatar.dart';

class ActionsSection extends StatelessWidget {
  final Salon salon;
  const ActionsSection({super.key, required this.salon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildActionItem(Icons.call_outlined, 'Call', () {}),
              const SizedBox(width: 32),
              _buildActionItem(Icons.directions_outlined, 'Directions', () {}),
              const SizedBox(width: 32),
              _buildActionItem(Icons.share_outlined, 'Share', () {}),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.star_outline,
              size: 18,
              color: Color(0xFF4A2C3F),
            ),
            label: Text(
              salon.rating.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade800, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}

class OffersSection extends StatelessWidget {
  final Salon salon;
  const OffersSection({super.key, required this.salon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Offers for you',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 3,
                  width: 120,
                  color: const Color(0xFF4A2C3F).withOpacity(0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CouponCard(
            title: 'Layer Cut',
            discount: '50% Off',
            validity: '*Valid until December 27, 2025',
            imageUrl: salon.imageUrl,
          ),
        ],
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  final Salon salon;
  const AboutSection({super.key, required this.salon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Us',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 60,
            color: const Color(0xFF4A2C3F).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to ${salon.name}, your premier destination for professional grooming services. Our team of skilled professionals is dedicated to providing top-notch beauty and wellness experiences tailored to your needs.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class FeedbackSection extends StatelessWidget {
  final SalonDetailsController controller;
  const FeedbackSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Client Feedback',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 120,
                color: const Color(0xFF4A2C3F).withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.feedbackController.feedbacks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildFeedbackCard(
              context,
              controller.feedbackController.feedbacks[index],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, Reviews review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(review.imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        review.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildRatingStars(review.rating),
                  ],
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    review.date,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(height: 12),
                Text(
                  review.comment,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        final fullStar = index < rating.floor();
        final halfStar = !fullStar && (rating - index) >= 0.5;
        final icon = fullStar
            ? Icons.star
            : halfStar
            ? Icons.star_half
            : Icons.star_border;
        return Icon(icon, color: Colors.amber, size: 18);
      }),
    );
  }
}

class SpecialistsSection extends StatelessWidget {
  final SalonDetailsController controller;
  const SpecialistsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Our Skilled Specialists',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 3,
                  width: 100,
                  color: const Color(0xFF4A2C3F).withOpacity(0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: controller.specialists.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: SpecialistAvatar(
                  specialist: controller.specialists[index],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductSection extends StatelessWidget {
  final SalonDetailsController controller;
  const ProductSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 3,
                  width: 60,
                  color: const Color(0xFF4A2C3F).withOpacity(0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Product>>(
            future: controller.productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No products found'));
              } else {
                final products = snapshot.data!.take(2).toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    itemCount: products.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.65,
                        ),
                    itemBuilder: (context, index) =>
                        ProductCard(product: products[index]),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
