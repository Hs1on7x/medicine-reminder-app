package com.example.app_md

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.content.Intent
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private val NOTIFICATION_ACTION = "com.example.app_md.NOTIFICATION_CLICKED"
    private val notificationPlugin = NotificationPlugin()
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the notification plugin
        flutterEngine.plugins.add(notificationPlugin)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        
        // Handle notification click from intent
        if (intent.action == NOTIFICATION_ACTION) {
            setIntent(intent)
        }
    }
} 