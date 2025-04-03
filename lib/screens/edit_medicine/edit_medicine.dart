import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/repository.dart';
import '../../helpers/snack_bar.dart';
import '../../models/medicine_type.dart';
import '../../models/pill.dart';
import '../../notifications/custom_notification_service.dart';
import 'dart:developer' as developer;

class EditMedicineScreen extends StatefulWidget {
  const EditMedicineScreen({Key? key}) : super(key: key);

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final Repository _repository = Repository();
  final CustomNotificationService _notificationService = CustomNotificationService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  String _medicineType = "Pill";
  String _type = "mg";
  int _howManyDays = 1;
  DateTime _time = DateTime.now();
  DateTime _date = DateTime.now();
  String _selectedMedicineForm = "Pill";
  late Pill _pill;
  bool _isLoading = true;
  
  // Map for English to Arabic translations
  final Map<String, String> _translations = {
    'Edit Medicine': 'تعديل الدواء',
    'Pills Name': 'اسم الدواء',
    'Enter medicine name': 'أدخل اسم الدواء',
    'Please enter medicine name': 'الرجاء إدخال اسم الدواء',
    'Pills Amount': 'كمية الدواء',
    'Amount': 'الكمية',
    'Please enter amount': 'الرجاء إدخال الكمية',
    'Type': 'النوع',
    'How long?': 'المدة؟',
    'weeks': 'أسابيع',
    'Medicine form': 'شكل الدواء',
    'Update': 'تحديث',
    'Delete Medicine': 'حذف الدواء',
    'Are you sure you want to delete this medicine?': 'هل أنت متأكد من حذف هذا الدواء؟',
    'Cancel': 'إلغاء',
    'Delete': 'حذف',
    'Medicine updated successfully!': 'تم تحديث الدواء بنجاح!',
    'Medicine deleted successfully!': 'تم حذف الدواء بنجاح!',
  };
  
  String translate(String key) {
    return _translations[key] ?? key;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPill();
  }
  
  Future<void> _loadPill() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('pill')) {
      _pill = args['pill'] as Pill;
      
      // Set form values from pill
      _nameController.text = _pill.name;
      
      // Extract amount and type from description (e.g., "Dose: 500 mg")
      final descriptionParts = _pill.description.split(' ');
      if (descriptionParts.length >= 3 && descriptionParts[0] == 'Dose:') {
        _amountController.text = descriptionParts[1];
        _type = descriptionParts[2];
      } else {
        _amountController.text = '1';
      }
      
      _howManyDays = _pill.days.length;
      
      // Get the first time from the list
      if (_pill.times.isNotEmpty) {
        final timeOfDay = _pill.times.first;
        _time = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          timeOfDay.hour,
          timeOfDay.minute,
        );
      }
      
      _selectedMedicineForm = "Pill"; // Default to Pill
      
      setState(() {
        _isLoading = false;
      });
    } else {
      // If no pill was passed, go back to home screen
      Navigator.pop(context);
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _selectTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );
    
    if (selectedTime != null) {
      setState(() {
        _time = DateTime(
          _time.year,
          _time.month,
          _time.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  void _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (selectedDate != null) {
      setState(() {
        _date = selectedDate;
      });
    }
  }

  void _updatePill() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Generate a notification ID based on the pill
        final notifyId = (_pill.id ?? 0) * 10000 + _time.hour * 100 + _time.minute;
        
        // Cancel old notification
        await _notificationService.cancelNotification(notifyId);
        
        // Create updated pill
        final updatedPill = Pill(
          id: _pill.id,
          name: _nameController.text.trim(),
          description: 'Dose: ${_amountController.text} $_type',
          color: _pill.color,
          times: [TimeOfDay(hour: _time.hour, minute: _time.minute)],
          days: List.generate(_howManyDays, (index) => index + 1),
          isActive: true,
          lastTaken: _pill.lastTaken,
        );
        
        // Debug log to verify the pill data
        developer.log('Updating pill: ${updatedPill.name}, ID: ${updatedPill.id}');
        developer.log('Pill data: ${updatedPill.toMap()}');
        
        // Update in database
        final result = await _repository.updatePill(updatedPill);
        developer.log('Update result: $result');
        
        // Verify the update by reading the pill back from the database
        final updatedPillFromDb = await _repository.getPillById(_pill.id!);
        developer.log('Updated pill from DB: ${updatedPillFromDb?.name}, ID: ${updatedPillFromDb?.id}');
        
        // Create a DateTime that combines the date and time for notification
        final DateTime combinedDateTime = DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        );
        
        // Schedule new notification
        await _notificationService.scheduleNotification(
          notifyId: notifyId,
          title: 'وقت الدواء',
          body: 'حان وقت تناول ${updatedPill.name}',
          scheduledTime: combinedDateTime,
          soundName: 'loud_alarm',
        );
        
        if (mounted) {
          showSnackBar(context, translate('Medicine updated successfully!'));
          Navigator.pop(context, true); // Return true to indicate update was successful
        }
      } catch (e) {
        developer.log('Error updating pill: $e');
        if (mounted) {
          showSnackBar(context, 'Error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          translate('Edit Medicine'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pills Name
                Text(
                  translate('Pills Name'),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: translate('Enter medicine name'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return translate('Please enter medicine name');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                
                // Pills Amount and Type
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translate('Pills Amount'),
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: translate('Amount'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return translate('Please enter amount');
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translate('Type'),
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _type,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: <String>['mg', 'ml', 'g', 'mcg']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _type = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                
                // How long?
                Text(
                  translate('How long?'),
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF00BCD4),
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: const Color(0xFF00BCD4),
                    overlayColor: const Color(0x2900BCD4),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 30.0),
                  ),
                  child: Slider(
                    value: _howManyDays.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    onChanged: (value) {
                      setState(() {
                        _howManyDays = value.toInt();
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$_howManyDays ${translate('weeks')}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                
                // Medicine form
                Text(
                  translate('Medicine form'),
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15.0),
                SizedBox(
                  height: 120.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: MedicineType.medicineTypes.length,
                    itemBuilder: (context, index) {
                      final medicineType = MedicineType.medicineTypes[index];
                      final isSelected = _selectedMedicineForm.toLowerCase() == medicineType.name.toLowerCase();
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMedicineForm = medicineType.name;
                          });
                        },
                        child: Container(
                          width: 100.0,
                          margin: const EdgeInsets.only(right: 15.0),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF00BCD4) : Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Colors.white.withOpacity(0.2) 
                                      : const Color(0xFFE8F5F8),
                                  shape: BoxShape.circle,
                                ),
                                child: _getMedicineIcon(
                                  medicineType.name, 
                                  size: 40.0, 
                                  color: isSelected ? Colors.white : const Color(0xFF00BCD4),
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                _getArabicMedicineType(medicineType.name),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30.0),
                
                // Time and Date
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5F8),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('HH:mm').format(_time),
                                style: const TextStyle(
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00BCD4),
                                ),
                              ),
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF00BCD4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5F8),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('dd.MM').format(_date),
                                style: const TextStyle(
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00BCD4),
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF00BCD4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                
                // Update button
                SizedBox(
                  width: double.infinity,
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: _updatePill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      translate('Update'),
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to get Arabic medicine type
  String _getArabicMedicineType(String type) {
    final Map<String, String> typeMap = {
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
    return typeMap[type] ?? type;
  }
  
  // Helper method to get medicine icon based on type
  Widget _getMedicineIcon(String type, {required double size, required Color color}) {
    switch (type.toLowerCase()) {
      case 'pill':
        return Icon(Icons.medication, size: size, color: color);
      case 'capsule':
        return Icon(Icons.medication_liquid, size: size, color: color);
      case 'tablet':
        return Icon(Icons.local_pharmacy, size: size, color: color);
      case 'syrup':
        return Icon(Icons.local_drink, size: size, color: color);
      case 'cream':
        return Icon(Icons.spa, size: size, color: color);
      case 'drops':
        return Icon(Icons.opacity, size: size, color: color);
      case 'injection':
        return Icon(Icons.vaccines, size: size, color: color);
      case 'inhaler':
        return Icon(Icons.air, size: size, color: color);
      case 'powder':
        return Icon(Icons.grain, size: size, color: color);
      default:
        return Icon(Icons.medication, size: size, color: color);
    }
  }
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('Delete Medicine')),
        content: Text(translate('Are you sure you want to delete this medicine?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate('Cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Generate a notification ID based on the pill
              final notifyId = _pill.times.isNotEmpty 
                  ? (_pill.id ?? 0) * 10000 + _pill.times.first.hour * 100 + _pill.times.first.minute
                  : (_pill.id ?? 0) * 10000;
              
              // Cancel notification
              await _notificationService.cancelNotification(notifyId);
              
              // Delete from database
              await _repository.deletePill(_pill.id!);
              
              if (mounted) {
                showSnackBar(context, translate('Medicine deleted successfully!'));
                Navigator.pop(context, true); // Return to home screen
              }
            },
            child: Text(
              translate('Delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 