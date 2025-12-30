import 'package:flutter/material.dart';
import 'package:glow_vita_salon/view/select_datetime_screen.dart';

class SelectStaffScreen extends StatefulWidget {
  final List<String> selectedServices;

  const SelectStaffScreen({super.key, required this.selectedServices});

  @override
  _SelectStaffScreenState createState() => _SelectStaffScreenState();
}

class _SelectStaffScreenState extends State<SelectStaffScreen> {
  final Map<String, String> _selectedStaff = {};

  final Map<String, List<String>> _staffOptions = {
    'Haircut & Style': ['Alex', 'Jordan', 'Taylor'],
    'Manicure & Pedicure': ['Casey', 'Morgan'],
    'Facial Treatments': ['Riley', 'Jamie'],
    'Bridal Makeup': ['Alex', 'Jordan', 'Taylor'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Staff'),
        backgroundColor: Colors.pink.shade300,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.selectedServices.length,
        itemBuilder: (context, index) {
          final service = widget.selectedServices[index];
          final staffList = _staffOptions[service] ?? [];

          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                   SizedBox(height: 8.0),
                  ...staffList.map((staff) {
                    return RadioListTile<String>(
                      title: Text(staff),
                      value: staff,
                      groupValue: _selectedStaff[service],
                      onChanged: (value) {
                        setState(() {
                          _selectedStaff[service] = value!;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _selectedStaff.length == widget.selectedServices.length
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectDateTimeScreen(
                        selectedServices: widget.selectedServices,
                        selectedStaff: _selectedStaff,
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            backgroundColor: Colors.pink,
          ),
          child: const Text('Next', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
