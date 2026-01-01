import 'package:flutter/material.dart';
import 'package:glow_vita_salon/controller/appointment_controller.dart';
import 'package:glow_vita_salon/model/appointment.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppointmentController(),
      child: Consumer<AppointmentController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              _buildTabBar(controller),
              _buildSearchBar(controller),
              Expanded(child: _buildAppointmentList(controller)),
            ],
          );
        },
      ),
    );
  }

  /// TAB BAR
  Widget _buildTabBar(AppointmentController controller) {
    return Container(
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: AppointmentStatus.values.map((status) {
          final isSelected = controller.selectedStatus == status;
          return GestureDetector(
            onTap: () => controller.changeTab(status),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    status.name[0].toUpperCase() + status.name.substring(1),
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF4A2C3F) : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isSelected)
                    Container(
                      height: 2,
                      width: 40,
                      color: const Color(0xFF4A2C3F),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// SEARCH BAR
  Widget _buildSearchBar(AppointmentController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: controller.search,
        decoration: InputDecoration(
          hintText: 'Search Salon or Service',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A2C3F)),
          ),
        ),
      ),
    );
  }

  /// APPOINTMENT LIST
  Widget _buildAppointmentList(AppointmentController controller) {
    if (controller.filteredAppointments.isEmpty) {
      return const Center(
        child: Text('No appointments found', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = controller.filteredAppointments[index];
        return _buildAppointmentCard(controller, appointment);
      },
    );
  }

  /// APPOINTMENT CARD
  Widget _buildAppointmentCard(AppointmentController controller, Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 6, backgroundColor: Colors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.salonName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(appointment.serviceName, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                if (appointment.status == AppointmentStatus.upcoming)
                  OutlinedButton(
                    onPressed: () => controller.cancelAppointment(appointment),
                    child: const Text('Cancel'),
                  ),
                if (appointment.status == AppointmentStatus.completed)
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Write Review'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow(
                  Icons.calendar_today,
                  'Date & Time',
                  DateFormat('EEEE, d MMM yyyy - hh:mm a').format(appointment.dateTime),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '₹ ${appointment.totalAmount.toStringAsFixed(2)}/-',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
