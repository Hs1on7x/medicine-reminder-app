import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('ar', ''),
  ];

  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode == null || locale.countryCode!.isEmpty
        ? locale.languageCode
        : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    Intl.defaultLocale = localeName;
    return Future.value(AppLocalizations());
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Arabic translations
  String get appTitle => 'مذكر الدواء';
  String get welcomeTitle => 'مرحبًا بك في مذكر الدواء';
  String get welcomeSubtitle => 'تطبيق يساعدك على تذكر أدويتك في الوقت المناسب';
  String get getStarted => 'ابدأ الآن';
  String get home => 'الرئيسية';
  String get addMedicine => 'إضافة دواء';
  String get editMedicine => 'تعديل الدواء';
  String get medicineName => 'اسم الدواء';
  String get medicineType => 'نوع الدواء';
  String get medicineAmount => 'كمية الدواء';
  String get medicineTime => 'وقت التذكير';
  String get save => 'حفظ';
  String get cancel => 'إلغاء';
  String get delete => 'حذف';
  String get taken => 'تم أخذه';
  String get dismiss => 'تجاهل';
  String get pill => 'حبة';
  String get syrup => 'شراب';
  String get tablet => 'قرص';
  String get capsule => 'كبسولة';
  String get cream => 'كريم';
  String get drops => 'قطرات';
  String get injection => 'حقنة';
  String get inhaler => 'بخاخ';
  String get powder => 'بودرة';
  String get other => 'أخرى';
  String get notificationTitle => 'وقت الدواء';
  String notificationBody(String medicineName) => 'حان وقت تناول $medicineName';
  String timeToTake(String medicineName) => 'حان وقت تناول $medicineName';
  String takeMedicine(String amount, String type, String medicineName) => 'تناول $amount $type من $medicineName الآن';
  String get noMedicines => 'لا توجد أدوية مضافة';
  String get addYourFirstMedicine => 'أضف أول دواء لك';
  String get enterMedicineName => 'أدخل اسم الدواء';
  String get selectMedicineType => 'اختر نوع الدواء';
  String get enterAmount => 'الكمية';
  String get selectTime => 'اختر الوقت';
  String get medicineAdded => 'تمت إضافة الدواء بنجاح';
  String get medicineUpdated => 'تم تحديث الدواء بنجاح';
  String get medicineDeleted => 'تم حذف الدواء بنجاح';
  String get confirmDelete => 'هل أنت متأكد من حذف هذا الدواء؟';
  String get yes => 'نعم';
  String get no => 'لا';
  String get error => 'خطأ';
  String get tryAgain => 'حاول مرة أخرى';
  String get settings => 'الإعدادات';
  String get language => 'اللغة';
  String get notifications => 'الإشعارات';
  String get about => 'حول';
  String get version => 'الإصدار';
  String get today => 'اليوم';
  String get tomorrow => 'غدًا';
  String get yesterday => 'أمس';
  String get noNotifications => 'لا توجد إشعارات نشطة';
  String get activeNotifications => 'الإشعارات النشطة';
  String get close => 'إغلاق';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 