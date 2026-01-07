import 'package:flutter/material.dart';
import 'package:glow_vita_salon/controller/salon_details_controller.dart';
import 'package:glow_vita_salon/model/service.dart';
import 'package:glow_vita_salon/widget/service_card.dart';

class ServiceSelectionHeader extends StatelessWidget {
  final SalonDetailsController controller;

  const ServiceSelectionHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    bool isIndividualSelected =
        controller.serviceType == ServiceType.individual;
    bool isWeddingSelected = controller.serviceType == ServiceType.wedding;

    // Determine visibility based on capabilities
    bool showWeddingOption = controller.hasWeddingService;

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
          if (controller.services.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          controller.setServiceType(ServiceType.individual),
                      icon: Icon(
                        Icons.person,
                        color: isIndividualSelected
                            ? Colors.white
                            : Colors.black,
                        size: 20,
                      ),
                      label: Text(
                        'Individual Services',
                        style: TextStyle(
                          color: isIndividualSelected
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isIndividualSelected
                            ? const Color(0xFF4A2C3F)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: isIndividualSelected
                            ? null
                            : BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  if (showWeddingOption) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            controller.setServiceType(ServiceType.wedding),
                        icon: Icon(
                          Icons.favorite,
                          color: isWeddingSelected
                              ? Colors.white
                              : Colors.black,
                          size: 20,
                        ),
                        label: Text(
                          'Wedding Packages',
                          style: TextStyle(
                            color: isWeddingSelected
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isWeddingSelected
                              ? const Color(0xFF4A2C3F)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: isWeddingSelected
                              ? null
                              : BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isIndividualSelected) ...[
              const SizedBox(height: 16),
              BookingPreferenceSection(controller: controller),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: controller.serviceCategories.length,
                  itemBuilder: (context, index) {
                    final category = controller.serviceCategories[index];
                    final isSelected =
                        category == controller.selectedServiceCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => controller.selectServiceCategory(category),
                        child: Chip(
                          label: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          backgroundColor: isSelected
                              ? const Color(0xFF4A2C3F)
                              : Colors.grey.shade200,
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF4A2C3F)
                                : Colors.grey.shade400,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class BookingPreferenceSection extends StatelessWidget {
  final SalonDetailsController controller;

  const BookingPreferenceSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.hasHomeService && !controller.hasSalonService) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Side: Icon and Text
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.redAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How would you like to book?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select your preferred services location type',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right Side: Buttons
          Column(
            children: [
              if (controller.hasSalonService)
                _BookingTypeButton(
                  title: 'Visit Salon',
                  icon: Icons.content_cut,
                  isSelected:
                      controller.bookingPreference ==
                      BookingPreference.visitSalon,
                  onTap: () => controller.setBookingPreference(
                    BookingPreference.visitSalon,
                  ),
                ),
              if (controller.hasSalonService && controller.hasHomeService)
                const SizedBox(height: 8),
              if (controller.hasHomeService)
                _BookingTypeButton(
                  title: 'Home Service',
                  icon: Icons.home,
                  isSelected:
                      controller.bookingPreference ==
                      BookingPreference.homeService,
                  onTap: () => controller.setBookingPreference(
                    BookingPreference.homeService,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingTypeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BookingTypeButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130, // Fixed width for consistency
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A2C3F) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A2C3F) : Colors.grey.shade400,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceList extends StatelessWidget {
  final SalonDetailsController controller;
  final List<Service> services;

  const ServiceList({
    super.key,
    required this.controller,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No Services Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This salon has not listed any services under this category yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final service = services[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ServiceCard(
            service: service,
            isSelected: controller.selectedServices.contains(service),
            onBookTap: () => controller.toggleService(service),
          ),
        );
      }, childCount: services.length),
    );
  }
}
