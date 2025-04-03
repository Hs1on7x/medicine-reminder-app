import Flutter
import UIKit
import UserNotifications
import AVFoundation

@objc class NotificationHandler: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    static var audioPlayer: AVAudioPlayer?
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.example.app_md/notifications", binaryMessenger: registrar.messenger())
        let instance = NotificationHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Set delegate for notification center
        UNUserNotificationCenter.current().delegate = instance
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "createNotificationChannel":
            // iOS doesn't use channels, but we'll implement this for compatibility
            result(true)
            
        case "scheduleNotification":
            guard let args = call.arguments as? [String: Any],
                  let notifyId = args["notifyId"] as? Int,
                  let title = args["title"] as? String,
                  let body = args["body"] as? String,
                  let scheduledTime = args["scheduledTime"] as? Int64,
                  let soundName = args["soundName"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            
            scheduleNotification(notifyId: notifyId, title: title, body: body, scheduledTime: scheduledTime, soundName: soundName)
            result(true)
            
        case "cancelNotification":
            guard let args = call.arguments as? [String: Any],
                  let notifyId = args["notifyId"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            
            cancelNotification(notifyId: notifyId)
            result(true)
            
        case "cancelAllNotifications":
            cancelAllNotifications()
            result(true)
            
        case "requestPermissions":
            requestPermissions { granted in
                result(granted)
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    private func scheduleNotification(notifyId: Int, title: String, body: String, scheduledTime: Int64, soundName: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        // Try to use custom sound if available
        if soundName != "" {
            if let soundPath = Bundle.main.path(forResource: soundName, ofType: "mp3") {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundPath))
            }
        }
        
        // Create trigger
        let date = Date(timeIntervalSince1970: TimeInterval(scheduledTime / 1000))
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(identifier: String(notifyId), content: content, trigger: trigger)
        
        // Add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(date)")
            }
        }
    }
    
    private func cancelNotification(notifyId: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(notifyId)])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [String(notifyId)])
    }
    
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    // Handle notifications when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play sound directly for better control
        playSound(soundName: "loud_alarm")
        
        // Show notification with sound
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notifyId = Int(response.notification.request.identifier) ?? 0
        
        // Send notification tap event to Flutter
        let channel = FlutterMethodChannel(name: "com.example.app_md/notifications", binaryMessenger: UIApplication.shared.delegate?.window??.rootViewController as! FlutterBinaryMessenger)
        channel.invokeMethod("notificationTapped", arguments: ["notifyId": notifyId])
        
        completionHandler()
    }
    
    // Play sound directly
    private func playSound(soundName: String) {
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else {
            print("Sound file not found: \(soundName)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            // Configure audio session
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Create and play audio player
            NotificationHandler.audioPlayer = try AVAudioPlayer(contentsOf: url)
            NotificationHandler.audioPlayer?.prepareToPlay()
            NotificationHandler.audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
} 