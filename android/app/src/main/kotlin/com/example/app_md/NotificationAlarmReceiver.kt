package com.example.app_md

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class NotificationAlarmReceiver : BroadcastReceiver() {
    
    private val NOTIFICATION_ACTION = "com.example.app_md.NOTIFICATION_CLICKED"
    
    override fun onReceive(context: Context, intent: Intent) {
        val notifyId = intent.getIntExtra("notifyId", 0)
        val title = intent.getStringExtra("title") ?: ""
        val body = intent.getStringExtra("body") ?: ""
        val channelId = intent.getStringExtra("channelId") ?: "medicine_reminder_channel"
        val fullScreenIntent = intent.getBooleanExtra("fullScreenIntent", true)
        val autoCancel = intent.getBooleanExtra("autoCancel", false)
        val badgeCount = intent.getIntExtra("badgeCount", 0)
        val soundName = intent.getStringExtra("soundName") ?: "loud_alarm"
        
        showNotification(context, notifyId, title, body, channelId, fullScreenIntent, autoCancel, badgeCount, soundName)
    }
    
    private fun showNotification(
        context: Context,
        notifyId: Int,
        title: String,
        body: String,
        channelId: String,
        fullScreenIntent: Boolean,
        autoCancel: Boolean,
        badgeCount: Int,
        soundName: String
    ) {
        // Create an intent for when the notification is tapped
        val tapIntent = Intent(context, MainActivity::class.java).apply {
            action = NOTIFICATION_ACTION
            putExtra("notifyId", notifyId)
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
                action = NOTIFICATION_ACTION
                putExtra("notifyId", notifyId)
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
        
        // Get the sound URI
        val soundUri = Uri.parse("android.resource://${context.packageName}/raw/${soundName}")
        
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
            .setSound(soundUri)
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