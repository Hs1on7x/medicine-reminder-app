import 'package:flutter/material.dart';
import '../../models/calendar_day_model.dart';

class CalendarDay extends StatelessWidget {
  final CalendarDayModel calendarDay;
  final VoidCallback onTap;

  const CalendarDay({
    Key? key,
    required this.calendarDay,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60.0,
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: calendarDay.isChecked ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              calendarDay.dayLetter,
              style: TextStyle(
                color: calendarDay.isChecked ? Theme.of(context).primaryColor : Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5.0),
            Text(
              calendarDay.dayNumber.toString(),
              style: TextStyle(
                color: calendarDay.isChecked ? Theme.of(context).primaryColor : Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 