import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _isFirstLaunchKey = 'is_first_launch';
  
  Locale _currentLocale = const Locale('en');
  bool _isFirstLaunch = true;
  
  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('de'), // German
    Locale('hi'), // Hindi
    Locale('gu'), // Gujarati
    Locale('mr'), // Marathi
    Locale('bn'), // Bengali
    Locale('ta'), // Tamil
    Locale('te'), // Telugu
    Locale('ml'), // Malayalam
    Locale('pa'), // Punjabi
    Locale('kn'), // Kannada
    Locale('or'), // Odia
    Locale('as'), // Assamese
  ];
  
  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'hi': 'हिन्दी',
    'gu': 'ગુજરાતી',
    'mr': 'मराठी',
    'bn': 'বাংলা',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'ml': 'മലയാളം',
    'pa': 'ਪੰਜਾਬੀ',
    'kn': 'ಕನ್ನಡ',
    'or': 'ଓଡିଆ',
    'as': 'অসমীয়া',
  };
  
  static const Map<String, String> languageFlags = {
    'en': '🇺🇸',
    'es': '🇪🇸',
    'fr': '🇫🇷',
    'de': '🇩🇪',
    'hi': '🇮🇳',
    'gu': '🇮🇳',
    'mr': '🇮🇳',
    'bn': '🇮🇳',
    'ta': '🇮🇳',
    'te': '🇮🇳',
    'ml': '🇮🇳',
    'pa': '🇮🇳',
    'kn': '🇮🇳',
    'or': '🇮🇳',
    'as': '🇮🇳',
  };
  
  Locale get currentLocale => _currentLocale;
  bool get isFirstLaunch => _isFirstLaunch;
  
  String get currentLanguageCode => _currentLocale.languageCode;
  String get currentLanguageName => languageNames[currentLanguageCode] ?? 'English';
  String get currentLanguageFlag => languageFlags[currentLanguageCode] ?? '🇺🇸';
  
  Future<void> initLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if this is the first launch
      _isFirstLaunch = prefs.getBool(_isFirstLaunchKey) ?? true;
      
      // Get saved language or default to system language
      final savedLanguageCode = prefs.getString(_languageKey);
      
      if (savedLanguageCode != null) {
        _currentLocale = Locale(savedLanguageCode);
      } else {
        // Try to use system language if supported
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        if (supportedLocales.any((locale) => locale.languageCode == systemLocale.languageCode)) {
          _currentLocale = Locale(systemLocale.languageCode);
        } else {
          _currentLocale = const Locale('en'); // Default to English
        }
      }
      
      notifyListeners();
    } catch (e) {
      // Default to English if there's an error
      _currentLocale = const Locale('en');
      _isFirstLaunch = true;
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    try {
      if (supportedLocales.any((locale) => locale.languageCode == languageCode)) {
        _currentLocale = Locale(languageCode);
        notifyListeners();
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
      }
    } catch (e) {
      // Handle error silently
    }
  }
  
  Future<void> completeFirstLaunch() async {
    try {
      _isFirstLaunch = false;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isFirstLaunchKey, false);
    } catch (e) {
      // Handle error silently
    }
  }
  
  bool isLanguageSupported(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode);
  }
  
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? 'Unknown';
  }
  
  String getLanguageFlag(String languageCode) {
    return languageFlags[languageCode] ?? '🌐';
  }
}
