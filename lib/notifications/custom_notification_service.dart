import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// Global navigator key to access context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class CustomNotificationService {
  // Singleton pattern
  static final CustomNotificationService _instance = CustomNotificationService._internal();
  
  // Platform channel for native notifications
  final MethodChannel _channel = const MethodChannel('com.example.app_md/notifications');
  
  // Notification tap callback
  Function(int notifyId)? onNotificationTap;
  
  // Dialog visibility tracking
  bool _isDialogShowing = false;
  bool _isInitialized = false;
  
  // Channel configuration
  final String _channelId = 'medicine_reminder_channel';
  
  factory CustomNotificationService() => _instance;

  CustomNotificationService._internal();

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize timezone
    tz_data.initializeTimeZones();
    
    // Set up method call handler for notification taps
    _channel.setMethodCallHandler(_handleMethodCall);
    
    // Create notification channel on Android
    if (Platform.isAndroid) {
      await _channel.invokeMethod('createNotificationChannel', {
        'channelId': _channelId,
        'channelName': 'Medicine Reminders',
        'channelDescription': 'Notifications for medicine reminders',
        'importance': 4, // IMPORTANCE_HIGH
        'enableVibration': true,
        'playSound': true,
        'soundName': 'loud_alarm',
      });
    }
    
    _isInitialized = true;
    debugPrint('CustomNotificationService initialized');
  }
  
  // Handle method calls from the platform
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'notificationTapped':
        final int notifyId = call.arguments['notifyId'];
        _handleNotificationTap(notifyId);
        break;
      default:
        print('Unknown method ${call.method}');
    }
  }
  
  // Handle notification taps
  void _handleNotificationTap(int notifyId) {
    // Call the callback if set
    if (onNotificationTap != null) {
      onNotificationTap!(notifyId);
    }
    
    // Show a dialog if no other dialog is showing
    if (!_isDialogShowing) {
      _showNotificationDialog(notifyId);
    }
  }
  
  // Show a dialog when a notification is tapped
  Future<void> _showNotificationDialog(int notifyId) async {
    _isDialogShowing = true;
    
    // Get the navigator context
    final context = _getGlobalContext();
    if (context != null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Medicine Reminder'),
            content: const Text('Time to take your medicine!'),
            actions: <Widget>[
              TextButton(
                child: const Text('Dismiss'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Take Now'),
                onPressed: () {
                  // Handle medicine taken action
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    
    _isDialogShowing = false;
  }
  
  // Get the global context
  BuildContext? _getGlobalContext() {
    return navigatorKey.currentContext;
  }
  
  // Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API level 33+), request notification permission
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        return status.isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      // For iOS, use the platform channel
      final bool? result = await _channel.invokeMethod('requestPermissions');
      return result ?? false;
    }
    return false;
  }
  
  // Schedule a notification
  Future<void> scheduleNotification({
    required int notifyId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool fullScreenIntent = true,
    bool autoCancel = false,
    int badgeCount = 0,
    String soundName = 'loud_alarm',
  }) async {
    if (!_isInitialized) await initialize();
    
    try {
      debugPrint('Scheduling notification with sound: $soundName');
      
      await _channel.invokeMethod('scheduleNotification', {
        'notifyId': notifyId,
        'title': title,
        'body': body,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
        'channelId': _channelId,
        'fullScreenIntent': fullScreenIntent,
        'autoCancel': autoCancel,
        'badgeCount': badgeCount,
        'soundName': soundName,
      });
      debugPrint('Notification scheduled for $title at $scheduledTime');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }
  
  // Cancel a specific notification
  Future<void> cancelNotification(int notifyId) async {
    await _channel.invokeMethod('cancelNotification', {
      'notifyId': notifyId,
    });
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _channel.invokeMethod('cancelAllNotifications');
  }
  
  // Set the badge count (iOS only)
  Future<void> setBadgeCount(int count) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('setBadgeCount', {
        'count': count,
      });
    }
  }
} 