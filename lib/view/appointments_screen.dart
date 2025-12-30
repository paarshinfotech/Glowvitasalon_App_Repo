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
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF4A2C3F),
              title: const Text('My Appointments', style: TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Column(
              children: [
                _buildTabBar(context, controller),
                _buildSearchBar(context, controller),
                Expanded(child: _buildAppointmentList(context, controller)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, AppointmentController controller) {
    return Container(
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: AppointmentStatus.values.map((status) {
          final isSelected = controller.selectedStatus == status;
          return GestureDetector(
            onTap: () => controller.changeTab(status),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    status.name.substring(0, 1).toUpperCase() + status.name.substring(1),
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF4A2C3F) : Colors.grey[600],
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

  Widget _buildSearchBar(BuildContext context, AppointmentController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) => controller.search(value),
        decoration: InputDecoration(
          hintText: 'Search Salon or Service',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A2C3F)),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(BuildContext context, AppointmentController controller) {
    if (controller.filteredAppointments.isEmpty) {
      return const Center(
        child: Text('No appointments found.', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: controller.filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = controller.filteredAppointments[index];
        return _buildAppointmentCard(context, controller, appointment);
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, AppointmentController controller, Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.salonName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(appointment.serviceName, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                if (appointment.status == AppointmentStatus.upcoming)
                  OutlinedButton(
                    onPressed: () => controller.cancelAppointment(appointment),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
                  ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.calendar_today_outlined, 'Date and Time', DateFormat('EEEE, d MMM yyyy - hh:mm a').format(appointment.dateTime)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹ ${appointment.totalAmount.toStringAsFixed(2)}/-', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.missed:
        return Colors.orange;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }
}
