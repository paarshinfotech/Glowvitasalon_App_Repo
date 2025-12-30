import 'package:flutter/material.dart';
import 'package:glow_vita_salon/controller/notification_controller.dart';
import 'package:glow_vita_salon/model/notification.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationController(),
      child: Consumer<NotificationController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF4A2C3F),
              title: const Text('Notifications', style: TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Column(
              children: [
                _buildFilterTabs(context, controller),
                _buildSearchBar(context, controller),
                Expanded(child: _buildNotificationList(context, controller)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, NotificationController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildFilterChip(context, controller, text: 'All (${controller.allCount})', isSelected: !controller.filteredAppointments.any((element) => !element.isRead), onSelected: () => controller.toggleFilter(false)),
          const SizedBox(width: 12),
          _buildFilterChip(context, controller, text: 'Unread (${controller.unreadCount})', isSelected: controller.filteredAppointments.every((element) => !element.isRead), onSelected: () => controller.toggleFilter(true)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, NotificationController controller, {required String text, required bool isSelected, required VoidCallback onSelected}) {
    return ChoiceChip(
      label: Text(text),
      selected: isSelected,
      onSelected: (selected) => onSelected(),
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF4A2C3F).withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF4A2C3F) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }


  Widget _buildSearchBar(BuildContext context, NotificationController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        onChanged: (value) => controller.search(value),
        decoration: InputDecoration(
          hintText: 'Search',
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

  Widget _buildNotificationList(BuildContext context, NotificationController controller) {
    if (controller.filteredNotifications.isEmpty) {
      return const Center(
        child: Text('No notifications found.', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: controller.filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = controller.filteredNotifications[index];
        return _buildNotificationCard(context, controller, notification);
      },
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationController controller, NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: notification.isRead ? Colors.blue[50] : Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(notification.type),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(controller.getIconForType(notification.type), color: _getIconColor(notification.type), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(notification.message, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(notification.timeAgo, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Colors.green.shade100;
      case NotificationType.review:
        return Colors.yellow.shade100;
      case NotificationType.bookingConfirmed:
        return Colors.green.shade100;
      case NotificationType.deal:
        return Colors.blue.shade100;
      case NotificationType.offer:
        return Colors.orange.shade100;
      case NotificationType.tips:
        return Colors.red.shade100;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Colors.green.shade700;
      case NotificationType.review:
        return Colors.yellow.shade800;
      case NotificationType.bookingConfirmed:
        return Colors.green.shade700;
      case NotificationType.deal:
        return Colors.blue.shade700;
      case NotificationType.offer:
        return Colors.orange.shade700;
      case NotificationType.tips:
        return Colors.red.shade700;
    }
  }
}
