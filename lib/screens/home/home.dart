import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pill.dart';
import '../../database/repository.dart';
import '../../notifications/custom_notification_service.dart';
import '../settings/settings.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Repository _repository = Repository();
  final CustomNotificationService _notificationService = CustomNotificationService();
  List<Pill> _pills = [];
  DateTime _selectedDay = DateTime.now();
  int _notificationCount = 0;
  
  @override
  void initState() {
    super.initState();
    _loadPills();
    _updateNotificationCount();
    
    // Set notification tap callback
    _notificationService.onNotificationTap = (notifyId) {
      setState(() {
        // Update UI when notification is tapped
        _updateNotificationCount();
      });
    };
  }

  Future<void> _loadPills() async {
    final pills = await _repository.getAllPills();
    setState(() {
      _pills = pills;
    });
    
    // Update notification count after loading pills
    _updateNotificationCount();
  }

  Future<void> _updateNotificationCount() async {
    // Get all pills and count those that have times today
    final pills = await _repository.getAllPills();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int count = 0;
    for (final pill in pills) {
      for (final timeOfDay in pill.times) {
        final pillDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          timeOfDay.hour,
          timeOfDay.minute,
        );
        
        // Count pills that are scheduled for today and the time is in the future
        if (pillDateTime.isAfter(now)) {
          count++;
          break; // Count each pill only once
        }
      }
    }
    
    setState(() {
      _notificationCount = count;
    });
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
  }

  List<Pill> _getPillsForSelectedDay() {
    return _pills.where((pill) {
      // Check if any of the pill's times are on the selected day
      if (pill.times.isEmpty) return false;
      
      // Get the first time for simplicity
      final timeOfDay = pill.times.first;
      final pillDateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      
      return pillDateTime.day == _selectedDay.day &&
             pillDateTime.month == _selectedDay.month &&
             pillDateTime.year == _selectedDay.year;
    }).toList();
  }
  
  void _showNotifications() {
    final localizations = AppLocalizations.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.noMedicines),
        backgroundColor: const Color(0xFF00BCD4),
      ),
    );
  }

  // Show active notifications dialog
  void _showNotificationsDialog() {
    final localizations = AppLocalizations.of(context);
    
    // Get all pills scheduled for today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Find pills with upcoming times today
    final activePills = _pills.where((pill) {
      if (pill.times.isEmpty) return false;
      
      for (final timeOfDay in pill.times) {
        final pillDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          timeOfDay.hour,
          timeOfDay.minute,
        );
        
        // Include pills that are scheduled for today
        if (pillDateTime.isAfter(now) || 
            (pillDateTime.hour == now.hour && pillDateTime.minute == now.minute)) {
          return true;
        }
      }
      return false;
    }).toList();
    
    if (activePills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.noNotifications),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Show dialog with active notifications
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.notifications),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: activePills.length,
            itemBuilder: (context, index) {
              final pill = activePills[index];
              final timeOfDay = pill.times.first;
              final time = DateTime(
                today.year,
                today.month,
                today.day,
                timeOfDay.hour,
                timeOfDay.minute,
              );
              final formattedTime = DateFormat('HH:mm').format(time);
              
              return ListTile(
                leading: Icon(Icons.medication, color: pill.color),
                title: Text(pill.name),
                subtitle: Text(pill.description),
                trailing: Text(
                  formattedTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: pill.color,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(Pill pill) async {
    final result = await Navigator.pushNamed(
      context, 
      '/edit_medicine',
      arguments: {'pill': pill},
    );
    
    // Reload pills if edit was successful or if result is null (user pressed back)
    if (result == true || result == null) {
      _loadPills();
    }
  }

  void _navigateToAddNewMedicine() async {
    final result = await Navigator.pushNamed(context, '/add_medicine');
    
    // Reload pills if add was successful or if result is null (user pressed back)
    if (result == true || result == null) {
      _loadPills();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pillsForSelectedDay = _getPillsForSelectedDay();
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Journal title and notification icon
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.appTitle,
                    style: const TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications),
                            onPressed: () {
                              // Show active notifications
                              _showNotificationsDialog();
                            },
                          ),
                          if (_notificationCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  _notificationCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Calendar days
            SizedBox(
              height: 100.0,
              child: _buildCalendar(),
            ),
            
            // Medicine list
            Expanded(
              child: pillsForSelectedDay.isEmpty
                  ? Center(
                      child: Text(
                        localizations.noMedicines,
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(15.0),
                      itemCount: pillsForSelectedDay.length,
                      itemBuilder: (context, index) {
                        final pill = pillsForSelectedDay[index];
                        return _buildMedicineCard(pill);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddNewMedicine();
        },
        backgroundColor: const Color(0xFF00BCD4),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30.0,
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    // Arabic day abbreviations in correct order (Sunday to Saturday)
    final weekDays = ['أح', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب'];
    
    // Generate 7 days starting from today
    final List<DateTime> days = [];
    final today = DateTime(now.year, now.month, now.day);
    
    // Start with today and add 6 more days
    for (int i = 0; i < 7; i++) {
      days.add(today.add(Duration(days: i)));
    }
    
    return Column(
      children: [
        // Weekday letters
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            // Get the correct day abbreviation for each date
            final dayIndex = days[index].weekday % 7; // Convert to 0-6 (Sun-Sat)
            return SizedBox(
              width: 40.0,
              child: Text(
                weekDays[dayIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18.0,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10.0),
        // Day numbers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((day) {
            final isSelected = day.day == _selectedDay.day &&
                day.month == _selectedDay.month &&
                day.year == _selectedDay.year;
            
            return GestureDetector(
              onTap: () => _onDaySelected(day),
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(Pill pill) {
    // Get the first time from the list of times
    final timeOfDay = pill.times.isNotEmpty ? pill.times.first : TimeOfDay.now();
    final time = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    final formattedTime = DateFormat('HH:mm').format(time);
    
    return GestureDetector(
      onTap: () {
        // Navigate to edit screen
        _navigateToEditScreen(pill);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15.0),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5F8),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Medicine icon
            Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: pill.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                Icons.medication,
                color: pill.color,
                size: 40.0,
              ),
            ),
            const SizedBox(width: 15.0),
            // Medicine details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pill.name,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    pill.description,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD4),
                  ),
                ),
                const SizedBox(height: 5.0),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20.0,
                  ),
                  onPressed: () => _showDeleteConfirmation(pill),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Pill pill) {
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.delete),
        content: Text(localizations.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Generate a notification ID based on the pill
              final notifyId = pill.times.isNotEmpty 
                  ? (pill.id ?? 0) * 10000 + pill.times.first.hour * 100 + pill.times.first.minute
                  : (pill.id ?? 0) * 10000;
              
              // Cancel notification
              await _notificationService.cancelNotification(notifyId);
              
              // Delete from database
              await _repository.deletePill(pill.id!);
              
              // Reload pills
              _loadPills();
            },
            child: Text(
              localizations.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String getMedicineImage(String medicineForm) {
    switch (medicineForm.toLowerCase()) {
      case 'pill':
        return 'assets/images/pill.png';
      case 'capsule':
        return 'assets/images/capsule.png';
      case 'tablet':
        return 'assets/images/tablet.png';
      case 'syrup':
        return 'assets/images/syrup.png';
      case 'cream':
        return 'assets/images/cream.png';
      case 'drops':
        return 'assets/images/drops.png';
      case 'injection':
        return 'assets/images/injection.png';
      case 'inhaler':
        return 'assets/images/inhaler.png';
      case 'powder':
        return 'assets/images/powder.png';
      default:
        return 'assets/images/pills.png';
    }
  }
} 