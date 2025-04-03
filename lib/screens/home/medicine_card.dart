import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pill.dart';

class MedicineCard extends StatelessWidget {
  final Pill pill;
  final VoidCallback onDelete;

  const MedicineCard({
    Key? key,
    required this.pill,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the first time from the list of times
    final timeOfDay = pill.times.isNotEmpty ? pill.times.first : TimeOfDay.now();
    final time = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    final formattedTime = DateFormat.jm().format(time);

    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F8),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              color: pill.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Icon(
                Icons.medication,
                color: pill.color,
                size: 40.0,
              ),
            ),
          ),
          const SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pill.name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  pill.description,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String getMedicineImage(String medicineForm) {
    switch (medicineForm.toLowerCase()) {
      case 'pill':
        return 'assets/images/pills.png';
      case 'syrup':
        return 'assets/images/drops.png';
      case 'capsule':
        return 'assets/images/pills.png';
      case 'cream':
        return 'assets/images/cream.png';
      case 'syringe':
        return 'assets/images/syringe.png';
      default:
        return 'assets/images/pills.png';
    }
  }
} 