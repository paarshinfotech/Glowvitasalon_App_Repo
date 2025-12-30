enum AppointmentStatus { upcoming, completed, missed, cancelled }

class Appointment {
  final String salonName;
  final String serviceName;
  final DateTime dateTime;
  final double totalAmount;
  final AppointmentStatus status;

  Appointment({
    required this.salonName,
    required this.serviceName,
    required this.dateTime,
    required this.totalAmount,
    required this.status,
  });
}
