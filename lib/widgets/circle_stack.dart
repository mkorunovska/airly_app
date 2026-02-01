import 'package:flutter/material.dart';

class CircleStack extends StatelessWidget {
  final IconData icon;

  const CircleStack({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        CircleAvatar(
          radius: 90,
          backgroundColor: const Color.fromARGB(255, 159, 164, 181),
        ),
        CircleAvatar(
          radius: 70,
          backgroundColor: const Color.fromARGB(255, 206, 210, 221),
        ),
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color.fromARGB(255, 228, 231, 237),
        ),
        Icon(icon, size: 50, color: Color.fromARGB(255, 8, 9, 42)),
      ],
    );
  }
}
