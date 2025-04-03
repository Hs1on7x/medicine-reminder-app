import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calendar_day.dart';
import '../../models/calendar_day_model.dart';

class Calendar extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const Calendar({
    Key? key,
    required this.selectedDay,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late List<CalendarDayModel> _calendarDays;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _generateCalendarDays();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateCalendarDays() {
    final DateTime now = DateTime.now();
    _calendarDays = List.generate(30, (index) {
      final day = now.add(Duration(days: index - 15));
      return CalendarDayModel(
        dayLetter: DateFormat('E').format(day)[0],
        dayNumber: day.day,
        month: day.month,
        year: day.year,
        isChecked: day.day == widget.selectedDay.day &&
                   day.month == widget.selectedDay.month &&
                   day.year == widget.selectedDay.year,
      );
    });
  }

  @override
  void didUpdateWidget(Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDay != widget.selectedDay) {
      setState(() {
        _generateCalendarDays();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _calendarDays.length,
        itemBuilder: (context, index) {
          return CalendarDay(
            calendarDay: _calendarDays[index],
            onTap: () {
              final selectedDay = DateTime(
                _calendarDays[index].year,
                _calendarDays[index].month,
                _calendarDays[index].dayNumber,
              );
              widget.onDaySelected(selectedDay);
            },
          );
        },
      ),
    );
  }
} 