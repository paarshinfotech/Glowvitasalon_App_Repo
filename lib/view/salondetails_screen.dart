import 'package:flutter/material.dart';
import 'package:glow_vita_salon/controller/salon_details_controller.dart';
import 'package:glow_vita_salon/model/salon.dart';
import 'package:glow_vita_salon/model/service.dart';
import 'package:glow_vita_salon/model/specialist.dart';
import 'package:glow_vita_salon/widget/coupon_card.dart';
import 'package:glow_vita_salon/widget/product_card.dart';
import 'package:glow_vita_salon/widget/service_card.dart';
import 'package:glow_vita_salon/widget/specialist_avatar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/product.dart';
import '../model/feedback.dart';

class SalonDetailsScreen extends StatelessWidget {
  final Salon salon;
  final bool scrollToProducts;

  const SalonDetailsScreen({
    super.key,
    required this.salon,
    this.scrollToProducts = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SalonDetailsController(salon),
      child: Consumer<SalonDetailsController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              slivers: [
                _buildImageCarousel(context, controller),
                SliverToBoxAdapter(child: _buildActionsSection(context, controller)),
                const SliverToBoxAdapter(child: Divider(thickness: 1, height: 1)),
                SliverToBoxAdapter(child: _buildOffersSection(context, controller)),
                if (controller.currentState == SalonDetailsState.services)
                  ..._buildServicesContent(context, controller)
                else if (controller.currentState == SalonDetailsState.staff)
                  _buildStaffSelectionList(context, controller)
                else
                  _buildDateTimeSelectionList(context, controller),
                if (controller.currentState != SalonDetailsState.dateTime) ...[
                  _buildSpecialistsSection(context, controller),
                  SliverToBoxAdapter(child: _buildProductSection(context, controller)),
                ],
                SliverToBoxAdapter(child: _buildAboutUsSection(context, controller)),
                SliverToBoxAdapter(child: _buildClientFeedbackSection(context, controller)),
              ],
            ),
            bottomNavigationBar: _buildBottomAppBar(context, controller),
          );
        },
      ),
    );
  }

  List<Widget> _buildServicesContent(BuildContext context, SalonDetailsController controller) {
    return [
      SliverToBoxAdapter(child: _buildServicesSection(context, controller)),
      _buildServicesList(context, controller, controller.filteredServices),
    ];
  }

  Widget _buildBottomAppBar(BuildContext context, SalonDetailsController controller) {
    final price = controller.selectedServices.fold<double>(0, (sum, service) => sum + service.price);
    Column priceWidget(String title) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              '₹ ${price.toStringAsFixed(2)}/-',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        );

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFF4A2C3F),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: controller.currentState == SalonDetailsState.dateTime
            ? _buildDateTimeNavBar(context, controller, priceWidget('Total'))
            : controller.currentState == SalonDetailsState.staff
                ? _buildStaffNavBar(context, controller, priceWidget('Total'))
                : _buildServiceNavBar(context, controller, priceWidget('Total')),
      ),
    );
  }

  List<Widget> _buildServiceNavBar(BuildContext context, SalonDetailsController controller, Widget priceWidget) {
    return [
      priceWidget,
      ElevatedButton(
        onPressed: () {
          if (controller.selectedServices.isNotEmpty) {
            controller.proceedToStaffSelection();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a service first.'), backgroundColor: Colors.red),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4A2C3F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        ),
        child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ];
  }

  List<Widget> _buildStaffNavBar(BuildContext context, SalonDetailsController controller, Widget priceWidget) {
    return [
      OutlinedButton(
        onPressed: () => controller.backToServiceSelection(),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      priceWidget,
      ElevatedButton(
        onPressed: () {
          if (controller.selectedStaff.isNotEmpty) {
            controller.proceedToDateTimeSelection();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a staff member first.'), backgroundColor: Colors.red),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4A2C3F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ];
  }

  List<Widget> _buildDateTimeNavBar(BuildContext context, SalonDetailsController controller, Widget priceWidget) {
    return [
      priceWidget,
      ElevatedButton(
        onPressed: () {
          if (controller.selectedTime != null) {
            _showBookingConfirmation(context, controller);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a time slot.'), backgroundColor: Colors.red),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4A2C3F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        ),
        child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ];
  }

  void _showBookingConfirmation(BuildContext context, SalonDetailsController controller) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text('Your Booking Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.cut, 'Service', controller.selectedServices.first.name, '${controller.selectedServices.first.duration} • ₹${controller.selectedServices.first.price}/-'),
                      const Divider(height: 24),
                      _buildDetailRow(Icons.person_outline, 'Staff', controller.selectedStaff.values.first.name, null),
                      const Divider(height: 24),
                      _buildDetailRow(Icons.calendar_today_outlined, 'Date and Time', DateFormat('EEEE, d MMM yyyy').format(controller.selectedDate), controller.selectedTime),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Apply Coupon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter Coupon Code',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2C3F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildPriceRow('Subtotal :', '₹ ${controller.subtotal.toStringAsFixed(2)}/-'),
                const SizedBox(height: 8),
                _buildPriceRow('Platform Fee :', '₹ ${20.0.toStringAsFixed(2)}/-'),
                const SizedBox(height: 8),
                _buildPriceRow('GST :', '₹ ${2.50.toStringAsFixed(2)}/-'),
                const Divider(height: 24, thickness: 1.5),
                _buildPriceRow('Total Amount :', '₹ ${controller.totalAmount.toStringAsFixed(2)}/-', isTotal: true),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the current modal
                    _showPaymentMethod(context, controller);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C3F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Confirm Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentMethod(BuildContext context, SalonDetailsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Total : ₹ ${controller.totalAmount.toStringAsFixed(2)}/-', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildPaymentOption(
                  setModalState,
                  controller,
                  'Pay At Salon',
                  'Pay at the salon during your visit',
                  PaymentMethod.payAtSalon,
                  Icons.store_mall_directory_outlined,
                ),
                const SizedBox(height: 16),
                _buildPaymentOption(
                  setModalState,
                  controller,
                  'Pay Online',
                  'Pay now using secure online payment',
                  PaymentMethod.payOnline,
                  Icons.payment_outlined,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (controller.paymentMethod != null) {
                      Navigator.pop(context); // Close the payment modal
                      _showBookingConfirmedDialog(context, controller);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a payment method.'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C3F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBookingConfirmedDialog(BuildContext context, SalonDetailsController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Booking Confirmed!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '✨',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your appointment is confirmed.\nEnjoy a seamless experience and\npay at the salon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    controller.reset();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C3F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Booking Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    controller.reset();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(StateSetter setModalState, SalonDetailsController controller, String title,
      String subtitle, PaymentMethod value, IconData icon) {
    final isSelected = controller.paymentMethod == value;
    return GestureDetector(
      onTap: () => setModalState(() => controller.selectPaymentMethod(value)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: isSelected ? Colors.green : const Color(0xFF4A2C3F)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: value,
              groupValue: controller.paymentMethod,
              onChanged: (PaymentMethod? newValue) {
                setModalState(() {
                  controller.selectPaymentMethod(newValue);
                });
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, String? subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(String title, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(amount, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  SliverToBoxAdapter _buildImageCarousel(BuildContext context, SalonDetailsController controller) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          SizedBox(
            height: 280,
            child: PageView.builder(
              controller: controller.pageController,
              itemCount: controller.imageUrls.length,
              onPageChanged: (index) => controller.onPageChanged(index),
              itemBuilder: (context, index) => Image.network(
                controller.imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 50)),
              ),
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
            top: 10,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  if (controller.currentState != SalonDetailsState.services) {
                    controller.handleBackButton();
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
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
                  salon.name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10.0, color: Colors.black)]),
                ),
                const SizedBox(height: 8),
                Text(
                  '${salon.address} • 2.0 Kms',
                  style: const TextStyle(color: Colors.white, fontSize: 16, shadows: [Shadow(blurRadius: 8.0, color: Colors.black)]),
                ),
              ],
            ),
          ),
          if (controller.imageUrls.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.imageUrls.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: controller.currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: controller.currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, SalonDetailsController controller) {
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
            label: Text(salon.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  Widget _buildOffersSection(BuildContext context, SalonDetailsController controller) {
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
                const Text('Offers for you', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(height: 3, width: 120, color: const Color(0xFF4A2C3F).withOpacity(0.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CouponCard(title: 'Layer Cut', discount: '50% Off', validity: '*Valid until December 27, 2025', imageUrl: salon.imageUrl),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context, SalonDetailsController controller) {
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
                const Text('Select Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(height: 3, width: 60, color: const Color(0xFF4A2C3F).withOpacity(0.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: controller.serviceCategories.length,
              itemBuilder: (context, index) {
                final category = controller.serviceCategories[index];
                final isSelected = category == controller.selectedServiceCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => controller.selectServiceCategory(category),
                    child: Chip(
                      label: Text(category, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                      backgroundColor: isSelected ? const Color(0xFF4A2C3F) : Colors.grey.shade200,
                      side: BorderSide(color: isSelected ? const Color(0xFF4A2C3F) : Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  SliverList _buildServicesList(BuildContext context, SalonDetailsController controller, List<Service> services) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final service = services[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GestureDetector(
              onTap: () => controller.toggleService(service),
              child: ServiceCard(service: service, isSelected: controller.selectedServices.contains(service)),
            ),
          );
        },
        childCount: services.length,
      ),
    );
  }

  SliverToBoxAdapter _buildSpecialistsSection(BuildContext context, SalonDetailsController controller) {
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
                  const Text('Our Skilled Specialists', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(height: 3, width: 100, color: const Color(0xFF4A2C3F).withOpacity(0.5)),
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
                  child: SpecialistAvatar(specialist: controller.specialists[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(BuildContext context, SalonDetailsController controller) {
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
                const Text('Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(height: 3, width: 60, color: const Color(0xFF4A2C3F).withOpacity(0.5)),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) => ProductCard(product: products[index]),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutUsSection(BuildContext context, SalonDetailsController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About Us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(height: 3, width: 60, color: const Color(0xFF4A2C3F).withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Welcome to ${salon.name}, your premier destination for professional grooming services. Our team of skilled professionals is dedicated to providing top-notch beauty and wellness experiences tailored to your needs.',
            style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildClientFeedbackSection(BuildContext context, SalonDetailsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Client Feedback', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(height: 3, width: 120, color: const Color(0xFF4A2C3F).withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.feedbackController.feedbacks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildFeedbackCard(context, controller, controller.feedbackController.feedbacks[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, SalonDetailsController controller, Reviews review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 28, backgroundImage: NetworkImage(review.imageUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(review.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    _buildRatingStars(context, controller, review.rating),
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

  Widget _buildRatingStars(BuildContext context, SalonDetailsController controller, double rating) {
    return Row(
      children: List.generate(5, (index) {
        final fullStar = index < rating.floor();
        final halfStar = !fullStar && (rating - index) >= 0.5;
        final icon = fullStar ? Icons.star : halfStar ? Icons.star_half : Icons.star_border;
        return Icon(icon, color: Colors.amber, size: 18);
      }),
    );
  }

  SliverToBoxAdapter _buildStaffSelectionList(BuildContext context, SalonDetailsController controller) {
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
                  const Text('Select Staff', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(height: 3, width: 60, color: const Color(0xFF4A2C3F).withOpacity(0.5)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.specialists.length,
              itemBuilder: (context, index) {
                final specialist = controller.specialists[index];
                final isSelected = controller.isStaffSelected(specialist);
                return _buildStaffMemberCard(context, controller, specialist, isSelected);
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildDateTimeSelectionList(BuildContext context, SalonDetailsController controller) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18),
                SizedBox(width: 8),
                Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 30,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = controller.selectedDate.day == date.day && controller.selectedDate.month == date.month && controller.selectedDate.year == date.year;
                  final isToday = DateTime.now().day == date.day && DateTime.now().month == date.month && DateTime.now().year == date.year;

                  return GestureDetector(
                    onTap: () => controller.selectDate(date),
                    child: Container(
                      width: 65,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey[200] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? Colors.grey.shade400 : Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.deepPurpleAccent, borderRadius: BorderRadius.circular(10)),
                              child: const Text('Today', style: TextStyle(color: Colors.white, fontSize: 10)),
                            )
                          else
                            Text(DateFormat('E').format(date), style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(date.day.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(DateFormat('MMM').format(date), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24.0),
            const Row(
              children: [
                Icon(Icons.access_time_outlined, size: 18),
                SizedBox(width: 8),
                Text('Select Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            _buildTimeSlotGroup(context, controller, 'Morning', controller.morningSlots, Colors.amber.shade600),
            const SizedBox(height: 24),
            _buildTimeSlotGroup(context, controller, 'Afternoon', controller.afternoonSlots, Colors.orange.shade600),
            const SizedBox(height: 24),
            _buildTimeSlotGroup(context, controller, 'Evening', controller.eveningSlots, Colors.green.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotGroup(BuildContext context, SalonDetailsController controller, String title, List<String> slots, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 5, backgroundColor: color),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: slots.map((time) {
            final isSelected = controller.selectedTime == time;
            return GestureDetector(
              onTap: () => controller.selectTime(time),
              child: Container(
                width: (MediaQuery.of(context).size.width - 32 - 24) / 3, // 3 slots per row
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey[300] : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(time, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStaffMemberCard(BuildContext context, SalonDetailsController controller, Specialist specialist, bool isSelected) {
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
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(specialist.imageUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(specialist.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text('4.9 (177 reviews)', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 4.0,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.watch_later_outlined, color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 4),
                        Text('10+ Years Exp', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline, color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 4),
                        Text('3k Clients', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => controller.selectStaff(specialist),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? const Color(0xFF2E7D32) : Colors.white,
              foregroundColor: isSelected ? Colors.white : const Color(0xFF4A2C3F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade400),
              ),
              minimumSize: const Size(88, 36),
            ),
            child: Text(isSelected ? 'Selected' : 'Select'),
          ),
        ],
      ),
    );
  }
}
