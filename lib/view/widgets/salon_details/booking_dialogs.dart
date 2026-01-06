import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glow_vita_salon/controller/salon_details_controller.dart';
import 'package:glow_vita_salon/view/map_picker_screen.dart';
import 'package:glow_vita_salon/view/home.dart';

class BookingDialogs {
  static void showLocationPreferenceDialog(
    BuildContext context,
    SalonDetailsController controller,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Where would you like the service?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        controller.setBookingPreference(
                          BookingPreference.visitSalon,
                        );
                        showBookingConfirmation(context, controller);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF4A2C3F)),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.store,
                              size: 40,
                              color: Color(0xFF4A2C3F),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'At Salon',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A2C3F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(sheetContext); // Close bottom sheet first
                        controller.setBookingPreference(
                          BookingPreference.homeService,
                        );

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
                            showBookingConfirmation(context, controller);
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF4A2C3F)),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 40,
                              color: Color(0xFF4A2C3F),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'At Wedding Place',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A2C3F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static void showBookingConfirmation(
    BuildContext context,
    SalonDetailsController controller,
  ) {
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
                  child: Text(
                    'Your Booking Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
                      if (controller.selectedPackages.isNotEmpty)
                        ...controller.selectedPackages.map(
                          (p) => _buildDetailRow(
                            Icons.card_giftcard,
                            'Package',
                            p.name,
                            null,
                          ),
                        ),
                      if (controller.selectedPackages.isNotEmpty)
                        const Divider(height: 24),

                      if (controller.selectedServices.isNotEmpty)
                        _buildDetailRow(
                          Icons.cut,
                          'Services',
                          '${controller.selectedServices.length} Selected',
                          controller.selectedServices
                              .map((s) => s.name)
                              .take(3)
                              .join(', '),
                        ),

                      const Divider(height: 24),
                      if (controller.selectedStaff.isNotEmpty)
                        _buildDetailRow(
                          Icons.person_outline,
                          'Staff',
                          controller.selectedStaff.values.first.name,
                          null,
                        )
                      else if (controller.serviceType == ServiceType.wedding)
                        _buildDetailRow(
                          Icons.people_outline,
                          'Persons',
                          '${controller.numberOfPeople} People',
                          null,
                        ),

                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'Date and Time',
                        DateFormat(
                          'EEEE, d MMM yyyy',
                        ).format(controller.selectedDate),
                        controller.selectedTime,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Apply Coupon',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter Coupon Code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2C3F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location Details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        controller.bookingPreference ==
                                BookingPreference.visitSalon
                            ? Icons.store
                            : Icons.location_on,
                        color: const Color(0xFF4A2C3F),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.bookingPreference ==
                                      BookingPreference.visitSalon
                                  ? 'At Salon'
                                  : 'At Wedding Place',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (controller.bookingPreference ==
                                    BookingPreference.homeService &&
                                controller.userAddress != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                controller.userAddress!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (controller.userCity != null)
                                Text(
                                  controller.userCity!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildPriceRow(
                  'Subtotal :',
                  '₹ ${controller.subtotal.toStringAsFixed(2)}/-',
                ),
                if (controller.serviceType == ServiceType.wedding)
                  _buildPriceRow(
                    'Person(s) :',
                    'x ${controller.numberOfPeople}',
                  ),

                if (controller.serviceType != ServiceType.wedding) ...[
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    'Platform Fee :',
                    '₹ ${20.0.toStringAsFixed(2)}/-',
                  ),
                  const SizedBox(height: 8),
                  _buildPriceRow('GST :', '₹ ${2.50.toStringAsFixed(2)}/-'),
                ],

                const Divider(height: 24, thickness: 1.5),
                _buildPriceRow(
                  'Total Amount :',
                  '₹ ${controller.totalAmount.toStringAsFixed(2)}/-',
                  isTotal: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the current modal
                    showPaymentMethod(context, controller);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C3F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showPaymentMethod(
    BuildContext context,
    SalonDetailsController controller,
  ) {
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
                const Text(
                  'Choose Payment Method',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total : ₹ ${controller.totalAmount.toStringAsFixed(2)}/-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPaymentOption(
                  setModalState,
                  controller,
                  controller.bookingPreference == BookingPreference.homeService
                      ? 'Pay At Home'
                      : 'Pay At Salon',
                  controller.bookingPreference == BookingPreference.homeService
                      ? 'Pay comfortably at your home'
                      : 'Pay at the salon during your visit',
                  PaymentMethod.payAtSalon,
                  controller.bookingPreference == BookingPreference.homeService
                      ? Icons.home_outlined
                      : Icons.store_mall_directory_outlined,
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
                      showBookingConfirmedDialog(context, controller);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a payment method.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C3F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static void showBookingConfirmedDialog(
    BuildContext context,
    SalonDetailsController controller,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
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
                const Text('✨', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 16),
                Text(
                  'Your appointment is confirmed.\nEnjoy a seamless experience and\npay at the salon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    controller.reset();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Home(initialIndex: 2),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C3F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Booking Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    controller.reset();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                      (route) => false,
                    );
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

  static Widget _buildPaymentOption(
    StateSetter setModalState,
    SalonDetailsController controller,
    String title,
    String subtitle,
    PaymentMethod value,
    IconData icon,
  ) {
    final isSelected = controller.paymentMethod == value;
    return GestureDetector(
      onTap: () => setModalState(() => controller.selectPaymentMethod(value)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? Colors.green : const Color(0xFF4A2C3F),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
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

  static Widget _buildDetailRow(
    IconData icon,
    String title,
    String value,
    String? subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildPriceRow(
    String title,
    String amount, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
