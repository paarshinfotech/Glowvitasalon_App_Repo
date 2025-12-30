import 'package:flutter/material.dart';
import '../model/notification.dart';

class NotificationController extends ChangeNotifier {
  NotificationController() {
    _filteredNotifications = _allNotifications;
  }

  final List<NotificationModel> _allNotifications = [
    NotificationModel(
      type: NotificationType.appointment,
      title: 'Appointment Reminder',
      message: 'You have a haircut appointment tomorrow at 3:00 PM.',
      timeAgo: '15m ago',
      isRead: false,
    ),
    NotificationModel(
      type: NotificationType.review,
      title: 'Review Request',
      message: 'Please rate your recent manicure experience with us!',
      timeAgo: '1h ago',
      isRead: false,
    ),
    NotificationModel(
      type: NotificationType.bookingConfirmed,
      title: 'Your Booking is Confirmed!',
      message: 'Your spa package is confirmed for April 25th at 2:00 PM.',
      timeAgo: 'Yesterday',
      isRead: true,
    ),
    NotificationModel(
      type: NotificationType.deal,
      title: 'Limited Time Deal',
      message: 'Enjoy a free hair spa with any color treatment this week.',
      timeAgo: '2d ago',
      isRead: true,
    ),
    NotificationModel(
      type: NotificationType.offer,
      title: 'Special Offer Just For You!',
      message: 'Get 20% off on all facials this weekend! Book now!',
      timeAgo: '3d ago', 
      isRead: true,
    ),
    NotificationModel(
      type: NotificationType.tips,
      title: 'New Beauty Tips',
      message: 'Discover our top summer skincare tips on our blog!',
      timeAgo: '5d ago',
      isRead: true,
    ),
  ];

  List<NotificationModel> _filteredNotifications = [];
  List<NotificationModel> get filteredNotifications => _filteredNotifications;

  bool _showUnread = false;
  String _searchTerm = '';

  int get allCount => _allNotifications.length;
  int get unreadCount => _allNotifications.where((n) => !n.isRead).length;

  void toggleFilter(bool showUnread) {
    _showUnread = showUnread;
    _filterNotifications();
  }

  void search(String term) {
    _searchTerm = term.toLowerCase();
    _filterNotifications();
  }

  void _filterNotifications() {
    _filteredNotifications = _allNotifications.where((notification) {
      final matchesFilter = !_showUnread || !notification.isRead;
      final matchesSearch = notification.title.toLowerCase().contains(_searchTerm) ||
                            notification.message.toLowerCase().contains(_searchTerm);
      return matchesFilter && matchesSearch;
    }).toList();
    notifyListeners();
  }

  IconData getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.review:
        return Icons.star;
      case NotificationType.bookingConfirmed:
        return Icons.check_circle;
      case NotificationType.deal:
        return Icons.timer;
      case NotificationType.offer:
        return Icons.card_giftcard;
      case NotificationType.tips:
        return Icons.favorite;
    }
  }
}
