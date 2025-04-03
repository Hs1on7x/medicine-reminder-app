import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'app_ar.dart';
import 'app_en.dart';

// Create implementation files for each language
class AppLocalizationsImpl {
  final Locale locale;
  
  AppLocalizationsImpl(this.locale);
  
  static AppLocalizationsImpl of(BuildContext context) {
    return Localizations.of<AppLocalizationsImpl>(context, AppLocalizationsImpl)!;
  }
  
  static const LocalizationsDelegate<AppLocalizationsImpl> delegate = _AppLocalizationsImplDelegate();
  
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizationsImpl.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ar', ''),
  ];
  
  // Cache of localized values
  late Map<String, String> _localizedValues;
  
  Future<void> load() async {
    String jsonString;
    switch (locale.languageCode) {
      case 'ar':
        _localizedValues = AppAr.values;
        break;
      case 'en':
      default:
        _localizedValues = AppEn.values;
        break;
    }
  }
  
  String translate(String key) {
    return _localizedValues[key] ?? key;
  }
  
  // Getters for all localized strings
  String get appTitle => translate('appTitle');
  String get welcomeTitle => translate('welcomeTitle');
  String get welcomeSubtitle => translate('welcomeSubtitle');
  String get getStarted => translate('getStarted');
  String get home => translate('home');
  String get addMedicine => translate('addMedicine');
  String get editMedicine => translate('editMedicine');
  String get medicineName => translate('medicineName');
  String get medicineType => translate('medicineType');
  String get medicineAmount => translate('medicineAmount');
  String get medicineTime => translate('medicineTime');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get taken => translate('taken');
  String get dismiss => translate('dismiss');
  String get pill => translate('pill');
  String get syrup => translate('syrup');
  String get tablet => translate('tablet');
  String get capsule => translate('capsule');
  String get cream => translate('cream');
  String get drops => translate('drops');
  String get injection => translate('injection');
  String get inhaler => translate('inhaler');
  String get powder => translate('powder');
  String get other => translate('other');
  String get notificationTitle => translate('notificationTitle');
  String notificationBody(String medicineName) => 
      translate('notificationBody').replaceAll('{medicineName}', medicineName);
  String timeToTake(String medicineName) => 
      translate('timeToTake').replaceAll('{medicineName}', medicineName);
  String takeMedicine(String amount, String type, String medicineName) => 
      translate('takeMedicine')
          .replaceAll('{amount}', amount)
          .replaceAll('{type}', type)
          .replaceAll('{medicineName}', medicineName);
  String get noMedicines => translate('noMedicines');
  String get addYourFirstMedicine => translate('addYourFirstMedicine');
  String get enterMedicineName => translate('enterMedicineName');
  String get selectMedicineType => translate('selectMedicineType');
  String get enterAmount => translate('enterAmount');
  String get selectTime => translate('selectTime');
  String get medicineAdded => translate('medicineAdded');
  String get medicineUpdated => translate('medicineUpdated');
  String get medicineDeleted => translate('medicineDeleted');
  String get confirmDelete => translate('confirmDelete');
  String get yes => translate('yes');
  String get no => translate('no');
  String get error => translate('error');
  String get tryAgain => translate('tryAgain');
  String get settings => translate('settings');
  String get language => translate('language');
  String get notifications => translate('notifications');
  String get about => translate('about');
  String get version => translate('version');
  String get today => translate('today');
  String get tomorrow => translate('tomorrow');
  String get yesterday => translate('yesterday');
}

class _AppLocalizationsImplDelegate extends LocalizationsDelegate<AppLocalizationsImpl> {
  const _AppLocalizationsImplDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizationsImpl> load(Locale locale) async {
    final localizations = AppLocalizationsImpl(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsImplDelegate old) => false;
} 