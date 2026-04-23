import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'progress/progress_screen.dart';
import 'settings/settings_screen.dart';
import 'thursday/thursday_prep_screen.dart';
import '../providers/notification_provider.dart';
import '../providers/navigation_provider.dart';
import '../services/notification_service.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule the 3-hour interval notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(intervalNotificationProvider).scheduleDailyIntervals();
      
      // Check for initial notification launch payload
      final initialPayload = NotificationService().consumePayload();
      print("DEBUG: MainScreen consumed initial payload: $initialPayload");
      if (initialPayload != null) {
        ref.read(navigationProvider.notifier).navigateToVerse(initialPayload);
      }
    });

    // Listen for during-session notification taps
    NotificationService().onNotificationTap.listen((payload) {
      print("DEBUG: MainScreen stream received payload: $payload");
      if (payload != null) {
        ref.read(navigationProvider.notifier).navigateToVerse(payload);
      }
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const BibleScreen(), 
    const MemorizScreen(),
    const ProgressScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);

    return Scaffold(
      body: IndexedStack(
        index: navState.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDim.withOpacity(0.9),
          border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
        ),
        child: BottomNavigationBar(
          currentIndex: navState.selectedIndex,
          onTap: (index) => ref.read(navigationProvider.notifier).setSelectedIndex(index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurface.withOpacity(0.4),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          unselectedLabelStyle: const TextStyle(fontSize: 10, letterSpacing: 1),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), 
              activeIcon: Icon(Icons.home), 
              label: "HOME"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined), 
              activeIcon: Icon(Icons.menu_book), 
              label: "BIBLE"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined), 
              activeIcon: Icon(Icons.event_available), 
              label: "MEMORIZ"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_graph_outlined), 
              activeIcon: Icon(Icons.auto_graph), 
              label: "PROGRESS"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), 
              activeIcon: Icon(Icons.settings), 
              label: "SETTINGS"
            ),
          ],
        ),
      ),
    );
  }
}
