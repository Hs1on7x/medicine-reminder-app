import 'package:flutter/material.dart';

class PlatformFlatButton extends StatelessWidget {
  final Widget handler;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  const PlatformFlatButton({
    Key? key,
    required this.handler,
    required this.onPressed,
    required this.color,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onPressed: onPressed,
      child: handler,
    );
  }
} 