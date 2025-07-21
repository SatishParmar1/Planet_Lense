import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'viewmodels/plant_identification_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'theme/app_theme.dart';
import 'views/main_navigation_view.dart';
import 'views/language_selection_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const PlantLensApp());
}

class PlantLensApp extends StatelessWidget {
  const PlantLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()..initLanguage()),
        ChangeNotifierProvider(create: (context) => PlantIdentificationViewModel()),
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()..initTheme()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'Plant Lens',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode 
                ? ThemeMode.dark 
                : ThemeMode.light,
            locale: languageProvider.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageProvider.supportedLocales,
            routes: {
              '/': (context) => languageProvider.isFirstLaunch 
                  ? const LanguageSelectionView() 
                  : const MainNavigationView(),
              '/main': (context) => const MainNavigationView(),
              '/language-selection': (context) => const LanguageSelectionView(),
            },
            initialRoute: '/',
          );
        },
      ),
    );
  }
}
