import 'package:flutter/material.dart';
import '../../helpers/platform_slider.dart';

class SliderWidget extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const SliderWidget({
    Key? key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformSlider(
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      onChanged: onChanged,
    );
  }
} 