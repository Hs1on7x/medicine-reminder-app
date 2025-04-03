import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'screens/welcome/welcome.dart';
import 'screens/home/home.dart';
import 'screens/add_new_medicine/add_new_medicine.dart';
import 'screens/edit_medicine/edit_medicine.dart';
import 'screens/settings/settings_screen.dart';
import 'services/audio_service.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/pill_provider.dart';
import 'providers/theme_provider.dart';
import 'notifications/custom_notification_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Initialize services
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // Initialize notification service
  final notificationService = CustomNotificationService();
  await notificationService.initialize();
  
  // Initialize audio service
  final audioService = AudioService();
  await audioService.initialize();
  
  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale _locale = const Locale('ar', ''); // Only Arabic locale

  @override
  void initState() {
    super.initState();
    // Add observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      debugPrint('App resumed - in foreground');
    } else if (state == AppLifecycleState.paused) {
      // App is partially visible (in recent apps)
      debugPrint('App paused - partially visible');
    } else if (state == AppLifecycleState.inactive) {
      // App is inactive
      debugPrint('App inactive');
    } else if (state == AppLifecycleState.detached) {
      // App is e 
      debugPrint('App detached');
    }
  }
  
  @override
  void dispose() {
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PillProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'مذكر الدواء', // Arabic title
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey, // Use the global navigator key
            // Set locale to Arabic only
            locale: _locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('ar', '')], // Only Arabic locale
            // Ensure text direction is set to RTL for Arabic
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl, // Always RTL for Arabic
                child: child!,
              );
            },
            // Set theme
            theme: themeProvider.getTheme(),
            initialRoute: '/',
            routes: {
              '/': (context) => const WelcomeScreen(),
              '/home': (context) => const HomeScreen(),
              '/add_medicine': (context) => const AddNewMedicineScreen(),
              '/edit_medicine': (context) => const EditMedicineScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
