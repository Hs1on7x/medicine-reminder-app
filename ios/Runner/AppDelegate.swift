import Flutter
import UIKit
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register method channel
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let notificationChannel = FlutterMethodChannel(name: "com.example.app_md/notifications",
                                                   binaryMessenger: controller.binaryMessenger)
    
    // Handle method calls
    notificationChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      
      switch call.method {
      case "initializeNotifications":
        self.initializeNotifications(result: result)
      case "showNotification":
        if let args = call.arguments as? [String: Any],
           let notifyId = args["notifyId"] as? Int,
           let title = args["title"] as? String,
           let body = args["body"] as? String {
          self.showNotification(notifyId: notifyId, title: title, body: body, result: result)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        }
      case "scheduleNotification":
        if let args = call.arguments as? [String: Any],
           let notifyId = args["notifyId"] as? Int,
           let title = args["title"] as? String,
           let body = args["body"] as? String,
           let timeInMillis = args["timeInMillis"] as? Int64 {
          self.scheduleNotification(notifyId: notifyId, title: title, body: body, timeInMillis: timeInMillis, result: result)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        }
      case "cancelNotification":
        if let args = call.arguments as? [String: Any],
           let notifyId = args["notifyId"] as? Int {
          self.cancelNotification(notifyId: notifyId, result: result)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        }
      case "cancelAllNotifications":
        self.cancelAllNotifications(result: result)
      case "setBadgeCount":
        if let args = call.arguments as? [String: Any],
           let count = args["count"] as? Int {
          self.setBadgeCount(count: count, result: result)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle notification when app is launched from a notification
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if let notifyId = userInfo["notifyId"] as? Int {
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let notificationChannel = FlutterMethodChannel(name: "com.example.app_md/notifications",
                                                     binaryMessenger: controller.binaryMessenger)
      notificationChannel.invokeMethod("notificationTapped", arguments: ["notifyId": notifyId])
    }
    completionHandler(.noData)
  }
  
  // Initialize notifications
  private func initializeNotifications(result: @escaping FlutterResult) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        result(FlutterError(code: "NOTIFICATION_ERROR", message: error.localizedDescription, details: nil))
        return
      }
      
      if granted {
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
        result(true)
      } else {
        result(false)
      }
    }
  }
  
  // Show a notification immediately
  private func showNotification(notifyId: Int, title: String, body: String, result: @escaping FlutterResult) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    content.userInfo = ["notifyId": notifyId]
    
    // Set the thread identifier to ensure proper RTL display for Arabic text
    content.threadIdentifier = "medicine_reminder"
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: "notification_\(notifyId)", content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        result(FlutterError(code: "NOTIFICATION_ERROR", message: error.localizedDescription, details: nil))
      } else {
        result(true)
      }
    }
  }
  
  // Schedule a notification for a future time
  private func scheduleNotification(notifyId: Int, title: String, body: String, timeInMillis: Int64, result: @escaping FlutterResult) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    content.userInfo = ["notifyId": notifyId]
    
    // Set the thread identifier to ensure proper RTL display for Arabic text
    content.threadIdentifier = "medicine_reminder"
    
    // Convert milliseconds to date
    let date = Date(timeIntervalSince1970: TimeInterval(timeInMillis) / 1000.0)
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    let request = UNNotificationRequest(identifier: "notification_\(notifyId)", content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        result(FlutterError(code: "NOTIFICATION_ERROR", message: error.localizedDescription, details: nil))
      } else {
        result(true)
      }
    }
  }
  
  // Cancel a specific notification
  private func cancelNotification(notifyId: Int, result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["notification_\(notifyId)"])
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["notification_\(notifyId)"])
    result(true)
  }
  
  // Cancel all notifications
  private func cancelAllNotifications(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    result(true)
  }
  
  // Set the app badge count
  private func setBadgeCount(count: Int, result: @escaping FlutterResult) {
    DispatchQueue.main.async {
      UIApplication.shared.applicationIconBadgeNumber = count
    }
    result(true)
  }
}
