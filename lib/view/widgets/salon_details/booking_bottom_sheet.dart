import 'package:flutter/material.dart';
import 'package:glow_vita_salon/controller/salon_details_controller.dart';
import 'package:glow_vita_salon/view/map_picker_screen.dart';
import 'package:glow_vita_salon/view/widgets/salon_details/booking_dialogs.dart';

class SalonBottomNavBar extends StatelessWidget {
  final SalonDetailsController controller;

  const SalonBottomNavBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) return const SizedBox.shrink();

    // Only show total price if we have selected something
    if (controller.totalAmount == 0) {
      return const SizedBox.shrink();
    }

    double price = 0.0;
    if (controller.serviceType == ServiceType.wedding &&
        controller.selectedPackage == null) {
      // Show nothing or 'Select a package'
      return const SizedBox.shrink();
    } else {
      // User request: Show ONLY service price in bottom bar (no fees/GST).
      // Fees/GST should only appear in Booking Details.
      if (controller.serviceType == ServiceType.individual) {
        price = controller.subtotal;
      } else {
        price = controller.totalAmount;
      }
    }

    Widget priceWidget(String title) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '₹ ${price.toStringAsFixed(2)}/-',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

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
        children: controller.currentState == SalonDetailsState.dateTime
            ? _buildDateTimeNavBar(context, controller, priceWidget('Total'))
            : controller.currentState == SalonDetailsState.staff
            ? _buildStaffNavBar(context, controller, priceWidget('Total'))
            : _buildServiceNavBar(
                context,
                controller,
                priceWidget('Total Price'),
              ),
      ),
    );
  }

  List<Widget> _buildServiceNavBar(
    BuildContext context,
    SalonDetailsController controller,
    Widget priceWidget,
  ) {
    // If Wedding Package Mode
    if (controller.serviceType == ServiceType.wedding) {
      if (controller.selectedPackages.isNotEmpty) {
        return [
          priceWidget,
          ElevatedButton(
            onPressed: () {
              controller.proceedToDateSelectionFromPackage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4A2C3F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ];
      } else {
        return [const SizedBox.shrink()]; // Show nothing if no package selected
      }
    }

    return [
      priceWidget,
      ElevatedButton(
        onPressed: () {
          if (controller.selectedServices.isNotEmpty) {
            controller.proceedToStaffSelection();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a service first.'),
                backgroundColor: Colors.red,
              ),
            );
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
        child: const Text(
          'Next',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  List<Widget> _buildStaffNavBar(
    BuildContext context,
    SalonDetailsController controller,
    Widget priceWidget,
  ) {
    return [
      OutlinedButton(
        onPressed: () => controller.backToServiceSelection(),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: const Text(
          'Back',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      priceWidget,
      ElevatedButton(
        onPressed: () {
          if (controller.selectedStaff.isNotEmpty) {
            controller.proceedToDateTimeSelection();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a staff member first.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4A2C3F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  List<Widget> _buildDateTimeNavBar(
    BuildContext context,
    SalonDetailsController controller,
    Widget priceWidget,
  ) {
    return [
      OutlinedButton(
        onPressed: () => controller.backToStaffSelection(),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: const Text(
          'Back',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      priceWidget,
      ElevatedButton(
        onPressed: () async {
          if (controller.selectedTime != null) {
            if (controller.serviceType == ServiceType.wedding) {
              BookingDialogs.showLocationPreferenceDialog(context, controller);
            } else {
              if (controller.bookingPreference ==
                  BookingPreference.homeService) {
                // Individual Home Service Flow
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapPickerScreen(),
                  ),
                );

                if (result != null && result is Map) {
                  controller.setUserAddress(
                    address: result['address'] ?? '',
                    city: result['city'] ?? '',
                    state: result['state'] ?? '',
                    pincode: result['pincode'] ?? '',
                    lat: result['lat'] ?? 0.0,
                    lng: result['lng'] ?? 0.0,
                  );
                  if (context.mounted) {
                    BookingDialogs.showBookingConfirmation(context, controller);
                  }
                }
              } else {
                BookingDialogs.showBookingConfirmation(context, controller);
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a time slot.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4A2C3F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text(
          'Book Now',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }
}
