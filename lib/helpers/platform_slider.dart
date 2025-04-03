import 'package:flutter/material.dart';

class PlatformSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;

  const PlatformSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.divisions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: Theme.of(context).primaryColor,
      inactiveColor: Colors.grey.withOpacity(0.3),
    );
  }
} 