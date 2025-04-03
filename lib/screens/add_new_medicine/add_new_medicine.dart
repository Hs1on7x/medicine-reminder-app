import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/repository.dart';
import '../../helpers/snack_bar.dart';
import '../../models/medicine_type.dart';
import '../../models/pill.dart';
import '../../notifications/custom_notification_service.dart';
import '../../l10n/app_localizations.dart';
import 'dart:developer' as developer;

class AddNewMedicineScreen extends StatefulWidget {
  const AddNewMedicineScreen({Key? key}) : super(key: key);

  @override
  State<AddNewMedicineScreen> createState() => _AddNewMedicineScreenState();
}

class _AddNewMedicineScreenState extends State<AddNewMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final Repository _repository = Repository();
  final CustomNotificationService _notificationService = CustomNotificationService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  String _medicineType = "Pill";
  String _type = "mg";
  int _howManyDays = 1;
  TimeOfDay _time = TimeOfDay.now();
  DateTime _date = DateTime.now();
  String _selectedMedicineForm = "Pill";

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _selectTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    
    if (selectedTime != null) {
      setState(() {
        _time = selectedTime;
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

  void _addPill() async {
    if (_formKey.currentState!.validate()) {
      try {
        final int notifyId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
        
        // Create a DateTime that combines the selected date and time
        final DateTime combinedDateTime = DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        );
        
        // Create a pill with the new model structure
        final Pill pill = Pill(
          name: _nameController.text.trim(),
          description: 'Dose: ${_amountController.text} $_type',
          color: const Color(0xFF00BCD4),
          times: [_time],
          days: List.generate(_howManyDays, (index) => index + 1),
          isActive: true,
        );
        
        developer.log('Adding pill: ${pill.name}');
        developer.log('Pill data: ${pill.toMap()}');
        
        final addedPill = await _repository.addPill(pill);
        developer.log('Added pill with ID: ${addedPill.id}');
        
        // Schedule notification with the custom service
        await _notificationService.scheduleNotification(
          notifyId: notifyId,
          title: 'وقت الدواء',
          body: 'حان وقت تناول ${pill.name}',
          scheduledTime: combinedDateTime,
          soundName: 'loud_alarm',
        );
        
        if (mounted) {
          showSnackBar(context, AppLocalizations.of(context).medicineAdded);
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        developer.log('Error adding pill: $e');
        if (mounted) {
          showSnackBar(context, 'Error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          localizations.addMedicine,
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
                  localizations.medicineName,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: localizations.enterMedicineName,
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
                      return 'الرجاء إدخال اسم الدواء';
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
                            localizations.medicineAmount,
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
                              hintText: localizations.enterAmount,
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
                                return 'الرجاء إدخال الكمية';
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
                            localizations.medicineType,
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
                  localizations.medicineTime,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF00BCD4),
                        inactiveTrackColor: Colors.grey[200],
                        thumbColor: Colors.white,
                        overlayColor: const Color(0x2900BCD4),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 30.0),
                        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                        valueIndicatorColor: const Color(0xFF00BCD4),
                        valueIndicatorTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                        trackHeight: 8.0,
                      ),
                      child: Slider(
                        value: _howManyDays.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: '$_howManyDays ${_howManyDays == 1 ? 'أسبوع' : 'أسابيع'}',
                        onChanged: (value) {
                          setState(() {
                            _howManyDays = value.toInt();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'أسبوع واحد',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BCD4),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              '$_howManyDays ${_howManyDays == 1 ? 'أسبوع' : 'أسابيع'}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Text(
                            '30 أسبوع',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                
                // Medicine form
                Text(
                  localizations.medicineType,
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
                      final isSelected = _selectedMedicineForm == medicineType.name;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMedicineForm = medicineType.name;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 95.0,
                          margin: const EdgeInsets.only(right: 10.0),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF00BCD4) : Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected 
                                    ? const Color(0xFF00BCD4).withOpacity(0.3) 
                                    : Colors.grey.withOpacity(0.1),
                                spreadRadius: isSelected ? 2 : 1,
                                blurRadius: isSelected ? 5 : 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: isSelected 
                                ? Border.all(color: const Color(0xFF00BCD4), width: 2) 
                                : Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
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
                                medicineType.arabicName,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.black87,
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
                Text(
                  localizations.medicineTime,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15.0),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5F8),
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                color: Color(0xFF00BCD4),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizations.selectTime,
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _time.format(context),
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00BCD4),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5F8),
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: Color(0xFF00BCD4),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizations.selectTime,
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd.MM').format(_date),
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00BCD4),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                
                // Done button
                SizedBox(
                  width: double.infinity,
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: _addPill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFF00BCD4).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              localizations.addMedicine,
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle_outline,
                              size: 24,
                            ),
                          ],
                        ),
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
} 