import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/settings_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: "ILLUMINATED",
      subtitle: "A Sacred Discipline",
      description: "Master 10 verses a day with a system designed for devotional focus and uniform mastery.",
      icon: Icons.auto_awesome,
      bgImage: "assets/images/bg_morning.png",
    ),
    OnboardingStep(
      title: "DISCIPLINED",
      subtitle: "The Thursday Prep",
      description: "Every Wednesday night, we prepare. Every Thursday morning, we are ready for recitation.",
      icon: Icons.history_edu,
      bgImage: "assets/images/bg_parchment.png",
    ),
    OnboardingStep(
      title: "CONSISTENT",
      subtitle: "Set Your Hour",
      description: "Choose a daily time for your 10-verse session. Consistency is the key to mastery.",
      icon: Icons.alarm,
      isTimePicker: true,
      bgImage: "assets/images/bg_dunes.png",
    ),
  ];

  void _nextPage() async {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutExpo,
      );
    } else {
      await Permission.notification.request();
      // Save the selected time and mark onboarding as complete
      final settingsNotifier = ref.read(settingsProvider.notifier);
      await settingsNotifier.updateStudyTime(_selectedTime.format(context));
      await settingsNotifier.completeOnboarding();
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated Background
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: Image.asset(
              _steps[_currentPage].bgImage,
              key: ValueKey(_currentPage),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceDim),
            ),
          ),
          // Dark Vignette/Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glassmorphic Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(step.icon, size: 64, color: AppColors.primary),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                step.title,
                                style: AppTypography.displayLarge.copyWith(
                                  letterSpacing: 6,
                                  fontSize: 28,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                step.subtitle,
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                step.description,
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall.copyWith(
                                  height: 1.6,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (step.isTimePicker) ...[
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: AppColors.primary,
                                    onPrimary: AppColors.surfaceDim,
                                    surface: AppColors.surfaceDim,
                                    onSurface: AppColors.onSurface,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) setState(() => _selectedTime = time);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.schedule, color: AppColors.primary, size: 24),
                                  const SizedBox(width: 16),
                                  Text(
                                    _selectedTime.format(context),
                                    style: AppTypography.displayMedium.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index ? AppColors.primary : Colors.white24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.9),
                      foregroundColor: AppColors.surfaceDim,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: Text(
                      _currentPage == _steps.length - 1 ? "BEGIN DISCIPLINE" : "CONTINUE",
                      style: AppTypography.labelMedium.copyWith(
                        letterSpacing: 3,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String bgImage;
  final bool isTimePicker;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.bgImage,
    this.isTimePicker = false,
  });
}
