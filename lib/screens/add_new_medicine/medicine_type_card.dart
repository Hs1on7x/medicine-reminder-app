import 'package:flutter/material.dart';
import '../../models/medicine_type.dart';

class MedicineTypeCard extends StatelessWidget {
  final MedicineType medicineType;
  final bool isSelected;
  final VoidCallback onTap;

  const MedicineTypeCard({
    Key? key,
    required this.medicineType,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  // Map for English to Arabic medicine type names
  String getArabicName(String englishName) {
    final Map<String, String> nameMap = {
      'Pill': 'حبة',
      'Capsule': 'كبسولة',
      'Tablet': 'قرص',
      'Syrup': 'شراب',
      'Cream': 'كريم',
      'Drops': 'قطرات',
      'Injection': 'حقنة',
      'Inhaler': 'بخاخ',
      'Powder': 'بودرة',
    };
    return nameMap[englishName] ?? englishName;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.0,
        margin: const EdgeInsets.only(right: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? medicineType.color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? medicineType.color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/medicine_types/${medicineType.name}.png',
              width: 40.0,
              height: 40.0,
            ),
            const SizedBox(height: 5.0),
            Text(
              getArabicName(medicineType.name),
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? medicineType.color : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 