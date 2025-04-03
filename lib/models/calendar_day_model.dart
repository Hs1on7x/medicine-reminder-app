class CalendarDayModel {
  final String dayLetter;
  final int dayNumber;
  final int month;
  final int year;
  final bool isChecked;

  CalendarDayModel({
    required this.dayLetter,
    required this.dayNumber,
    required this.month,
    required this.year,
    this.isChecked = false,
  });
} 