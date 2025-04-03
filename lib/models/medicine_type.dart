import 'package:flutter/material.dart';

class MedicineType {
  final String name;
  final Color color;
  final String arabicName;

  const MedicineType({
    required this.name,
    required this.color,
    required this.arabicName,
  });

  static final List<MedicineType> medicineTypes = [
    MedicineType(
      name: 'Pill',
      color: Color(0xFF00BCD4),
      arabicName: 'حبة',
    ),
    MedicineType(
      name: 'Capsule',
      color: Color(0xFF00BCD4),
      arabicName: 'كبسولة',
    ),
    MedicineType(
      name: 'Tablet',
      color: Color(0xFF00BCD4),
      arabicName: 'قرص',
    ),
    MedicineType(
      name: 'Syrup',
      color: Color(0xFF00BCD4),
      arabicName: 'شراب',
    ),
    MedicineType(
      name: 'Cream',
      color: Color(0xFF00BCD4),
      arabicName: 'كريم',
    ),
    MedicineType(
      name: 'Drops',
      color: Color(0xFF00BCD4),
      arabicName: 'قطرات',
    ),
    MedicineType(
      name: 'Injection',
      color: Color(0xFF00BCD4),
      arabicName: 'حقنة',
    ),
    MedicineType(
      name: 'Inhaler',
      color: Color(0xFF00BCD4),
      arabicName: 'بخاخ',
    ),
    MedicineType(
      name: 'Powder',
      color: Color(0xFF00BCD4),
      arabicName: 'بودرة',
    ),
  ];
} 