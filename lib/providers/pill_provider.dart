import 'package:flutter/material.dart';
import '../models/pill.dart';
import '../database/pill_database.dart';
import '../notifications/custom_notification_service.dart';

class PillProvider extends ChangeNotifier {
  final PillDatabase _database = PillDatabase();
  final CustomNotificationService _notificationService = CustomNotificationService();
  
  List<Pill> _pills = [];
  bool _isLoading = false;
  
  List<Pill> get pills => _pills;
  bool get isLoading => _isLoading;
  
  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    await _loadPills();
    _setLoading(false);
  }
  
  // Load pills from database
  Future<void> _loadPills() async {
    try {
      _pills = await _database.getAllPills();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pills: $e');
    }
  }
  
  // Add a new pill
  Future<void> addPill(Pill pill) async {
    _setLoading(true);
    try {
      // Add to database
      final int id = await _database.insertPill(pill);
      
      // Create a copy with the generated ID
      final newPill = pill.copyWith(id: id);
      
      // Schedule notifications
      await _scheduleNotifications(newPill);
      
      // Add to local list
      _pills.add(newPill);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding pill: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Update an existing pill
  Future<void> updatePill(Pill pill) async {
    _setLoading(true);
    try {
      // Update in database
      await _database.updatePill(pill);
      
      // Cancel existing notifications
      await _cancelNotifications(pill);
      
      // Schedule new notifications
      await _scheduleNotifications(pill);
      
      // Update in local list
      final index = _pills.indexWhere((p) => p.id == pill.id);
      if (index != -1) {
        _pills[index] = pill;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating pill: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete a pill
  Future<void> deletePill(int id) async {
    _setLoading(true);
    try {
      // Find the pill
      final pill = _pills.firstWhere((p) => p.id == id);
      
      // Cancel notifications
      await _cancelNotifications(pill);
      
      // Delete from database
      await _database.deletePill(id);
      
      // Remove from local list
      _pills.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting pill: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Mark a pill as taken for a specific time
  Future<void> markPillAsTaken(int pillId, DateTime time) async {
    try {
      // Find the pill
      final index = _pills.indexWhere((p) => p.id == pillId);
      if (index == -1) return;
      
      // Update the pill's taken status
      final pill = _pills[index];
      final updatedPill = pill.markAsTaken(time);
      
      // Update in database
      await _database.updatePill(updatedPill);
      
      // Update in local list
      _pills[index] = updatedPill;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking pill as taken: $e');
    }
  }
  
  // Schedule notifications for a pill
  Future<void> _scheduleNotifications(Pill pill) async {
    if (!pill.isActive) return;
    
    for (final time in pill.times) {
      final notifyId = _generateNotificationId(pill.id, time);
      
      // Schedule the notification
      await _notificationService.scheduleNotification(
        notifyId: notifyId,
        title: 'وقت الدواء',
        body: 'حان وقت تناول ${pill.name}',
        scheduledTime: _getNextOccurrence(time),
      );
    }
  }
  
  // Cancel notifications for a pill
  Future<void> _cancelNotifications(Pill pill) async {
    for (final time in pill.times) {
      final notifyId = _generateNotificationId(pill.id, time);
      await _notificationService.cancelNotification(notifyId);
    }
  }
  
  // Generate a unique notification ID for a pill and time
  int _generateNotificationId(int? pillId, TimeOfDay time) {
    return (pillId ?? 0) * 10000 + time.hour * 100 + time.minute;
  }
  
  // Get the next occurrence of a specific time
  DateTime _getNextOccurrence(TimeOfDay time) {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
  
  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
} 