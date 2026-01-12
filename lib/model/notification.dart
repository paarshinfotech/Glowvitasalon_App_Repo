enum NotificationType {
  appointment,
  review,
  bookingConfirmed,
  deal,
  offer,
  tips,
}

class NotificationModel {
  final NotificationType type;
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;

  NotificationModel({
    required this.type,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
  });
}
