import 'package:flutter/material.dart';
import 'package:glow_vita_salon/model/specialist.dart';

class SpecialistAvatar extends StatelessWidget {
  final Specialist specialist;

  const SpecialistAvatar({super.key, required this.specialist});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(specialist.imageUrl),
        ),
        const SizedBox(height: 8),
        Text(specialist.name, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
