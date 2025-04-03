import 'package:flutter/material.dart';

class FormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;

  const FormFields({
    Key? key,
    required this.nameController,
    required this.amountController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicine Name',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Enter medicine name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter medicine name';
            }
            return null;
          },
        ),
        const SizedBox(height: 20.0),
        const Text(
          'Amount',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        TextFormField(
          controller: amountController,
          decoration: InputDecoration(
            hintText: 'Enter amount (e.g. 1 pill, 5ml)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter amount';
            }
            return null;
          },
        ),
      ],
    );
  }
} 