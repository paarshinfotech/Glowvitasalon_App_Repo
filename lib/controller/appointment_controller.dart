import 'package:flutter/material.dart';
import '../model/appointment.dart';

class AppointmentController extends ChangeNotifier {
  AppointmentController() {
    _filteredAppointments = _allAppointments.where((app) => app.status == _selectedStatus).toList();
  }

  final List<Appointment> _allAppointments = [
    Appointment(
      salonName: 'Nidhi Hair & Nail salon',
      serviceName: 'Straight Cut',
      dateTime: DateTime(2025, 12, 8, 15, 0),
      totalAmount: 272.5,
      status: AppointmentStatus.upcoming,
    ),
    Appointment(
      salonName: 'Beauty Ladies Salon',
      serviceName: 'Facial & Clean-up',
      dateTime: DateTime(2025, 12, 11, 15, 30),
      totalAmount: 550,
      status: AppointmentStatus.upcoming,
    ),
    Appointment(
      salonName: 'Modern Men\'s Parlour',
      serviceName: 'Haircut & Shave',
      dateTime: DateTime(2024, 5, 20, 10, 0),
      totalAmount: 300,
      status: AppointmentStatus.completed,
    ),
    Appointment(
      salonName: 'Style & Smile Salon',
      serviceName: 'Manicure',
      dateTime: DateTime(2024, 4, 15, 14, 0),
      totalAmount: 450,
      status: AppointmentStatus.cancelled,
    ),
     Appointment(
      salonName: 'Nidhi Hair & Nail salon',
      serviceName: 'Layer Cut',
      dateTime: DateTime(2024, 3, 10, 11, 30),
      totalAmount: 600,
      status: AppointmentStatus.missed,
    ),
  ];

  List<Appointment> _filteredAppointments = [];
  List<Appointment> get filteredAppointments => _filteredAppointments;

  AppointmentStatus _selectedStatus = AppointmentStatus.upcoming;
  AppointmentStatus get selectedStatus => _selectedStatus;

  String _searchTerm = '';

  void changeTab(AppointmentStatus status) {
    _selectedStatus = status;
    _filterAppointments();
  }

  void search(String term) {
    _searchTerm = term.toLowerCase();
    _filterAppointments();
  }

  void _filterAppointments() {
    _filteredAppointments = _allAppointments.where((app) {
      final matchesStatus = app.status == _selectedStatus;
      final matchesSearch = app.salonName.toLowerCase().contains(_searchTerm) || 
                            app.serviceName.toLowerCase().contains(_searchTerm);
      return matchesStatus && matchesSearch;
    }).toList();
    notifyListeners();
  }

  void cancelAppointment(Appointment appointment) {
    final index = _allAppointments.indexOf(appointment);
    if (index != -1) {
      _allAppointments[index] = Appointment(
        salonName: appointment.salonName,
        serviceName: appointment.serviceName,
        dateTime: appointment.dateTime,
        totalAmount: appointment.totalAmount,
        status: AppointmentStatus.cancelled,
      );
      _filterAppointments();
    }
  }
}
