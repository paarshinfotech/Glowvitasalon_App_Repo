import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final List<String> selectedServices;

  const BookingScreen({super.key, required this.selectedServices});

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  final Map<String, String> _selectedStaff = {};
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final Map<String, List<String>> _staffOptions = {
    'Haircut & Style': ['Alex', 'Jordan', 'Taylor'],
    'Manicure & Pedicure': ['Casey', 'Morgan'],
    'Facial Treatments': ['Riley', 'Jamie'],
    'Bridal Makeup': ['Alex', 'Jordan', 'Taylor'],
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final dateText = _selectedDate != null ? DateFormat.yMMMd().format(_selectedDate!) : 'Not Selected';
        final timeText = _selectedTime != null ? _selectedTime!.format(context) : 'Not Selected';

        return AlertDialog(
          title: const Text('Appointment Confirmed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widget.selectedServices.map((service) {
                final staffName = _selectedStaff[service];
                final staffText = staffName ?? "No staff required";
                return Text('$service: $staffText');
              }),
              const SizedBox(height: 8.0),
              Text('Date: $dateText'),
              const SizedBox(height: 8.0),
              Text('Time: $timeText'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  bool _isBookingReady() {
    final servicesWithStaffCount = widget.selectedServices
        .where((service) =>
            _staffOptions.containsKey(service) &&
            _staffOptions[service]!.isNotEmpty)
        .length;
    return _selectedStaff.length == servicesWithStaffCount &&
        _selectedDate != null &&
        _selectedTime != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Appointment'),
        backgroundColor: Colors.pink.shade300,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Staff Selection
            const Text('1. Select Your Stylist', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...widget.selectedServices.map((service) {
              final staffList = _staffOptions[service] ?? [];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8.0),
                      ...staffList.map((staff) {
                        return RadioListTile<String>(
                          title: Text(staff),
                          value: staff,
                          groupValue: _selectedStaff[service],
                          onChanged: (value) {
                            setState(() {
                              if (value != null) {
                                _selectedStaff[service] = value;
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Date & Time Selection
            const Text('2. Select Date & Time', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(_selectedDate == null
                          ? 'Select Date'
                          : 'Date: ${DateFormat.yMMMd().format(_selectedDate!)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(_selectedTime == null
                          ? 'Select Time'
                          : 'Time: ${_selectedTime!.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectTime(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isBookingReady() ? _showConfirmationDialog : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            backgroundColor: Colors.pink,
            disabledBackgroundColor: Colors.grey,
          ),
          child: const Text('Confirm Booking', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
