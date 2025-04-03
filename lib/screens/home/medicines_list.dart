import 'package:flutter/material.dart';
import '../../models/pill.dart';
import 'medicine_card.dart';

class MedicinesList extends StatelessWidget {
  final List<Pill> pills;
  final Function(int) onDelete;

  const MedicinesList({
    Key? key,
    required this.pills,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return pills.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 80.0,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20.0),
                Text(
                  'No medicines for this day',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            itemCount: pills.length,
            itemBuilder: (context, index) {
              return MedicineCard(
                pill: pills[index],
                onDelete: () => onDelete(pills[index].id!),
              );
            },
          );
  }
} 