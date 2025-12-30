import 'package:flutter/material.dart';
import 'package:glow_vita_salon/controller/feedback_controller.dart';
import 'package:glow_vita_salon/model/feedback.dart';
import 'package:glow_vita_salon/model/product.dart';
import 'package:glow_vita_salon/model/salon.dart';
import 'package:glow_vita_salon/model/service.dart';
import 'package:glow_vita_salon/model/specialist.dart';
import 'package:glow_vita_salon/view/select_datetime_screen.dart';
import 'package:glow_vita_salon/widget/coupon_card.dart';
import 'package:glow_vita_salon/widget/product_card.dart';
import 'package:glow_vita_salon/widget/service_card.dart';
import 'package:glow_vita_salon/widget/specialist_avatar.dart';

import '../services/api_service.dart';

class SalonDetailsScreen extends StatefulWidget {
  final Salon salon;
  final bool scrollToProducts;

  const SalonDetailsScreen({
    super.key,
    required this.salon,
    this.scrollToProducts = false,
  });

  @override
  State<SalonDetailsScreen> createState() => _SalonDetailsScreenState();
}

class _SalonDetailsScreenState extends State<SalonDetailsScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final List<String> _imageUrls;
  String _selectedServiceCategory = 'Hair Cuts';
  final List<Service> _selectedServices = [];
  late Future<List<Product>> _productsFuture;
  final FeedbackController _feedbackController = FeedbackController();
  bool _showStaffSelection = false;
  final Map<String, Specialist> _selectedStaff = {};

  final List<String> _serviceCategories = ['All Categories', 'Hair Cuts', 'Hair Treatment', 'Nail Art', 'Makeup'];

  final List<Service> _services = [
    Service(name: 'Straight Cut', duration: '10 mins - 15 mins', price: 250, category: 'Hair Cuts', imageUrl: 'https://i.pravatar.cc/150?img=1'),
    Service(name: 'Layer Cut', duration: '20 mins - 30 mins', price: 500, category: 'Hair Cuts', isDiscounted: true, discountLabel: 'Save 50%', imageUrl: 'https://i.pravatar.cc/150?img=2'),
    Service(name: 'Step Cut', duration: '25 mins - 35 mins', price: 400, category: 'Hair Cuts', imageUrl: 'https://i.pravatar.cc/150?img=3'),
    Service(name: 'Feather Cut', duration: '20 mins - 30 mins', price: 350, category: 'Hair Cuts', imageUrl: 'https://i.pravatar.cc/150?img=4'),
    Service(name: 'Kids Hair Cut (Boys/Girls)', duration: '10 mins - 20 mins', price: 150, category: 'Hair Cuts', imageUrl: 'https://i.pravatar.cc/150?img=5'),
    Service(name: 'Advanced Haircut (Any Style)', duration: '30 mins - 45 mins', price: 600, category: 'Hair Cuts', imageUrl: 'https://i.pravatar.cc/150?img=6'),
    Service(name: 'Hair Spa', duration: '45 mins', price: 800, category: 'Hair Treatment', imageUrl: 'https://i.pravatar.cc/150?img=7'),
    Service(name: 'Manicure', duration: '30 mins', price: 400, category: 'Nail Art', imageUrl: 'https://i.pravatar.cc/150?img=8'),
    Service(name: 'Pedicure', duration: '45 mins', price: 600, category: 'Nail Art', imageUrl: 'https://i.pravatar.cc/150?img=9'),
    Service(name: 'Bridal Makeup', duration: '2 hours', price: 5000, category: 'Makeup', imageUrl: 'https://i.pravatar.cc/150?img=10'),
  ];

  final List<Specialist> _specialists = [
    Specialist(name: 'Rohit Roy', imageUrl: 'https://i.pravatar.cc/150?img=12'),
    Specialist(name: 'Dnyanada Deny', imageUrl: 'https://i.pravatar.cc/150?img=33'),
    Specialist(name: 'Jolie Torp', imageUrl: 'https://i.pravatar.cc/150?img=32'),
    Specialist(name: 'Rocky Roy', imageUrl: 'https://i.pravatar.cc/150?img=60'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _imageUrls = [widget.salon.imageUrl, widget.salon.imageUrl, widget.salon.imageUrl];
    _productsFuture = ApiService.getProducts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = _selectedServiceCategory == 'All Categories'
        ? _services
        : _services.where((s) => s.category == _selectedServiceCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildImageCarousel(),
          SliverToBoxAdapter(child: _buildActionsSection()),
          const SliverToBoxAdapter(child: Divider(thickness: 1, height: 1)),
          SliverToBoxAdapter(child: _buildOffersSection()),
          if (!_showStaffSelection) ...[
            SliverToBoxAdapter(child: _buildServicesSection()),
            _buildServicesList(filteredServices),
          ] else
            _buildStaffSelectionList(),
          _buildSpecialistsSection(),
          SliverToBoxAdapter(child: _buildProductSection()),
          SliverToBoxAdapter(child: _buildAboutUsSection()),
          SliverToBoxAdapter(child: _buildClientFeedbackSection()),
        ],
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildBottomAppBar() {
    final price = _selectedServices.fold<double>(0, (sum, service) => sum + service.price);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFF4A2C3F),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹ ${price.toStringAsFixed(2)}/-',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              if (_showStaffSelection) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectDateTimeScreen(
                      selectedServices: _selectedServices.map((s) => s.name).toList(),
                      selectedStaff: _selectedStaff.map((key, value) => MapEntry(key, value.name)),
                    ),
                  ),
                );
              } else {
                if (_selectedServices.isNotEmpty) {
                  setState(() {
                    _showStaffSelection = true;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a service first.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4A2C3F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: Text(
              _showStaffSelection ? 'Continue' : 'Next',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildImageCarousel() {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          SizedBox(
            height: 280,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  _imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  if (_showStaffSelection) {
                    setState(() {
                      _showStaffSelection = false;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.salon.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10.0, color: Colors.black)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.salon.address} • 2.0 Kms',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [Shadow(blurRadius: 8.0, color: Colors.black)],
                  ),
                ),
              ],
            ),
          ),
          if (_imageUrls.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_imageUrls.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
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
            icon: const Icon(Icons.star_outline, size: 18, color: Color(0xFF4A2C3F)),
            label: Text(
              widget.salon.rating.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
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

  Widget _buildOffersSection() {
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
            imageUrl: widget.salon.imageUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
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
                  'Select Services',
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
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _serviceCategories.length,
              itemBuilder: (context, index) {
                final category = _serviceCategories[index];
                final isSelected = category == _selectedServiceCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedServiceCategory = category;
                      });
                    },
                    child: Chip(
                      label: Text(category, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                      backgroundColor: isSelected ? const Color(0xFF4A2C3F) : Colors.grey.shade200,
                      side: BorderSide(color: isSelected ? const Color(0xFF4A2C3F) : Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  SliverList _buildServicesList(List<Service> services) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final service = services[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedServices.contains(service)) {
                    _selectedServices.remove(service);
                  } else {
                    _selectedServices.add(service);
                  }
                });
              },
              child: ServiceCard(
                service: service,
                isSelected: _selectedServices.contains(service),
              ),
            ),
          );
        },
        childCount: services.length,
      ),
    );
  }

  SliverToBoxAdapter _buildSpecialistsSection() {
    return SliverToBoxAdapter(
      child: Padding(
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
                itemCount: _specialists.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: SpecialistAvatar(specialist: _specialists[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection() {
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
            future: _productsFuture,
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutUsSection() {
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
            'Welcome to ${widget.salon.name}, your premier destination for professional grooming services. Our team of skilled professionals is dedicated to providing top-notch beauty and wellness experiences tailored to your needs.',
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

  Widget _buildClientFeedbackSection() {
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
            itemCount: _feedbackController.feedbacks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildFeedbackCard(_feedbackController.feedbacks[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(Reviews review) {
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    _buildRatingStars(review.rating),
                  ],
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(review.date, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(height: 12),
                Text(review.comment, style: TextStyle(color: Colors.grey.shade700)),
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

  SliverToBoxAdapter _buildStaffSelectionList() {
    return SliverToBoxAdapter(
      child: Padding(
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
                    'Select Staff',
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _specialists.length,
              itemBuilder: (context, index) {
                final specialist = _specialists[index];
                final isSelected = _selectedStaff.containsValue(specialist);
                return _buildStaffMemberCard(specialist, isSelected);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffMemberCard(Specialist specialist, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF4A2C3F) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
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
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(specialist.imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialist.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('4.9 (177 reviews)', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Icon(Icons.watch_later_outlined, color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text('10+ Years Exp', style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(width: 6),

                      Text('3k Clients', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (isSelected) {
                  _selectedStaff.clear();
                } else {
                  _selectedStaff.clear();
                  for (var service in _selectedServices) {
                    _selectedStaff[service.name] = specialist;
                  }
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? const Color(0xFF2E7D32) : Colors.white,
              foregroundColor: isSelected ? Colors.white : const Color(0xFF4A2C3F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade400),
              ),
            ),
            child: Text(isSelected ? 'Selected' : 'Select'),
          ),
        ],
      ),
    );
  }
}
