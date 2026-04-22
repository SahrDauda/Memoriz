import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/session/daily_session_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/thursday/thursday_prep_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/main_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ScriptureMemorizerApp extends StatelessWidget {
  const ScriptureMemorizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memoriz',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/main': (context) => const MainScreen(),
        '/session': (context) => const DailySessionScreen(),
        '/home': (context) => const HomeScreen(),
        '/library': (context) => const BibleScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/thursday': (context) => const MemorizScreen(),
      },
    );
  }
}
