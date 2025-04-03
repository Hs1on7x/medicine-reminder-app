package com.example.app_md

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Calendar

class NotificationPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: MainActivity? = null
    private lateinit var notificationManager: NotificationManager
    
    private val NOTIFICATION_CHANNEL_ID = "medicine_reminder_channel"
    private val NOTIFICATION_ACTION = "com.example.app_md.NOTIFICATION_CLICKED"
    private val notificationReceiver = NotificationReceiver()
    
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.app_md/notifications")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "createNotificationChannel" -> {
                val channelId = call.argument<String>("channelId") ?: NOTIFICATION_CHANNEL_ID
                val channelName = call.argument<String>("channelName") ?: "Medicine Reminders"
                val channelDescription = call.argument<String>("channelDescription") ?: "Notifications for medicine reminders"
                val importance = call.argument<Int>("importance") ?: NotificationManager.IMPORTANCE_HIGH
                val enableVibration = call.argument<Boolean>("enableVibration") ?: true
                val playSound = call.argument<Boolean>("playSound") ?: true
                val soundName = call.argument<String>("soundName") ?: "loud_alarm"
                
                createNotificationChannel(channelId, channelName, channelDescription, importance, enableVibration, playSound, soundName)
                result.success(true)
            }
            "scheduleNotification" -> {
                val notifyId = call.argument<Int>("notifyId") ?: 0
                val title = call.argument<String>("title") ?: ""
                val body = call.argument<String>("body") ?: ""
                val scheduledTime = call.argument<Long>("scheduledTime") ?: System.currentTimeMillis()
                val channelId = call.argument<String>("channelId") ?: NOTIFICATION_CHANNEL_ID
                val fullScreenIntent = call.argument<Boolean>("fullScreenIntent") ?: true
                val autoCancel = call.argument<Boolean>("autoCancel") ?: false
                val badgeCount = call.argument<Int>("badgeCount") ?: 0
                val soundName = call.argument<String>("soundName") ?: "loud_alarm"
                
                scheduleNotification(notifyId, title, body, scheduledTime, channelId, fullScreenIntent, autoCancel, badgeCount, soundName)
                result.success(true)
            }
            "cancelNotification" -> {
                val notifyId = call.argument<Int>("notifyId") ?: 0
                cancelNotification(notifyId)
                result.success(true)
            }
            "cancelAllNotifications" -> {
                cancelAllNotifications()
                result.success(true)
            }
            "requestPermissions" -> {
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    private fun createNotificationChannel(
        channelId: String,
        channelName: String,
        channelDescription: String,
        importance: Int,
        enableVibration: Boolean,
        playSound: Boolean,
        soundName: String
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                enableVibration(enableVibration)
                
                if (playSound) {
                    val soundUri = Uri.parse("android.resource://${context.packageName}/raw/${soundName}")
                    val audioAttributes = AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .build()
                    setSound(soundUri, audioAttributes)
                }
            }
            
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun scheduleNotification(
        notifyId: Int,
        title: String,
        body: String,
        scheduledTime: Long,
        channelId: String,
        fullScreenIntent: Boolean,
        autoCancel: Boolean,
        badgeCount: Int,
        soundName: String
    ) {
        val intent = Intent(context, NotificationPluginAlarmReceiver::class.java).apply {
            putExtra("notifyId", notifyId)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("channelId", channelId)
            putExtra("fullScreenIntent", fullScreenIntent)
            putExtra("autoCancel", autoCancel)
            putExtra("badgeCount", badgeCount)
            putExtra("soundName", soundName)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            notifyId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, scheduledTime, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, scheduledTime, pendingIntent)
        }
    }
    
    private fun cancelNotification(notifyId: Int) {
        // Cancel any scheduled alarms
        val intent = Intent(context, NotificationPluginAlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            notifyId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent)
        
        // Cancel any active notifications
        NotificationManagerCompat.from(context).cancel(notifyId)
    }
    
    private fun cancelAllNotifications() {
        NotificationManagerCompat.from(context).cancelAll()
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
    
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as MainActivity
        
        // Register notification receiver
        val intentFilter = IntentFilter(NOTIFICATION_ACTION)
        context.registerReceiver(notificationReceiver, intentFilter)
    }
    
    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
    
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as MainActivity
    }
    
    override fun onDetachedFromActivity() {
        activity = null
        
        // Unregister notification receiver
        try {
            context.unregisterReceiver(notificationReceiver)
        } catch (e: Exception) {
            // Receiver might not be registered
        }
    }
    
    inner class NotificationReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val notifyId = intent.getIntExtra("notifyId", 0)
            
            // Send notification tap event to Flutter
            activity?.runOnUiThread {
                channel.invokeMethod("notificationTapped", mapOf("notifyId" to notifyId))
            }
        }
    }
}

// Receiver for scheduled notifications
class NotificationPluginAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notifyId = intent.getIntExtra("notifyId", 0)
        val title = intent.getStringExtra("title") ?: "Medicine Reminder"
        val body = intent.getStringExtra("body") ?: "Time to take your medicine"
        val payload = intent.getStringExtra("payload") ?: ""
        val channelId = intent.getStringExtra("channelId") ?: "medicine_reminder_channel"
        val fullScreenIntent = intent.getBooleanExtra("fullScreenIntent", true)
        val autoCancel = intent.getBooleanExtra("autoCancel", false)
        val badgeCount = intent.getIntExtra("badgeCount", 0)
        val soundName = intent.getStringExtra("soundName") ?: "loud_alarm"
        
        // Log the sound name for debugging
        android.util.Log.d("NotificationPlugin", "Using sound: $soundName")
        
        // Play sound directly using MediaPlayer
        try {
            val mediaPlayer = android.media.MediaPlayer()
            val soundUri = Uri.parse("android.resource://${context.packageName}/raw/loud_alarm")
            android.util.Log.d("NotificationPlugin", "Playing sound directly: $soundUri")
            mediaPlayer.setDataSource(context, soundUri)
            mediaPlayer.setAudioAttributes(
                android.media.AudioAttributes.Builder()
                    .setContentType(android.media.AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(android.media.AudioAttributes.USAGE_ALARM)
                    .build()
            )
            mediaPlayer.setVolume(1.0f, 1.0f)
            mediaPlayer.prepare()
            mediaPlayer.start()
        } catch (e: Exception) {
            android.util.Log.e("NotificationPlugin", "Error playing sound: ${e.message}")
        }
        
        // Create an intent for when the notification is tapped
        val tapIntent = Intent(context, MainActivity::class.java).apply {
            action = "com.example.app_md.NOTIFICATION_CLICKED"
            putExtra("notifyId", notifyId)
            putExtra("payload", payload)
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        
        val pendingTapIntent = PendingIntent.getActivity(
            context,
            notifyId,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Create a full screen intent for high priority notifications
        val fullScreenPendingIntent = if (fullScreenIntent) {
            val fullScreenActivityIntent = Intent(context, MainActivity::class.java).apply {
                action = "com.example.app_md.NOTIFICATION_CLICKED"
                putExtra("notifyId", notifyId)
                putExtra("payload", payload)
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            
            PendingIntent.getActivity(
                context,
                notifyId + 1000, // Use a different request code to avoid conflicts
                fullScreenActivityIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } else {
            null
        }
        
        // Build the notification
        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher) // Use your app icon
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(pendingTapIntent)
            .setAutoCancel(autoCancel)
            .setSound(null)
            .setVibrate(longArrayOf(0, 500, 250, 500))
            .setNumber(badgeCount)
        
        // Add full screen intent for high priority notifications
        if (fullScreenIntent) {
            builder.setFullScreenIntent(fullScreenPendingIntent, true)
        }
        
        // Show the notification
        with(NotificationManagerCompat.from(context)) {
            try {
                notify(notifyId, builder.build())
            } catch (e: SecurityException) {
                // Handle permission issues
                e.printStackTrace()
            }
        }
    }
} 