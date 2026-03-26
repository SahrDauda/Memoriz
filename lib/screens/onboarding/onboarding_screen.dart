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
      description: "Master 85 KJV verses with a system designed for devotional focus and uniform mastery.",
      icon: Icons.auto_awesome,
    ),
    OnboardingStep(
      title: "DISCIPLINED",
      subtitle: "The Thursday Prep",
      description: "Every Wednesday night, we prepare. Every Thursday morning, we are ready for recitation.",
      icon: Icons.history_edu,
    ),
    OnboardingStep(
      title: "CONSISTENT",
      subtitle: "Set Your Hour",
      description: "Choose a daily time for your 10-verse session. Consistency is the key to mastery.",
      icon: Icons.alarm,
      isTimePicker: true,
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
      // Save the selected time to SettingsProvider
      await ref.read(settingsProvider.notifier).updateStudyTime(_selectedTime.format(context));
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(step.icon, size: 80, color: AppColors.primary),
                    const SizedBox(height: 48),
                    Text(step.title, style: AppTypography.displayLarge.copyWith(letterSpacing: 8)),
                    Text(step.subtitle, style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 24),
                    Text(
                      step.description,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(height: 1.6),
                    ),
                    if (step.isTimePicker) ...[
                      const SizedBox(height: 40),
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedTime.format(context),
                            style: AppTypography.displayMedium.copyWith(color: AppColors.primary),
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
                    (index) => Container(
                      margin: const EdgeInsets.all(4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage == _steps.length - 1 ? "BEGIN DISCIPLINE" : "NEXT",
                    style: AppTypography.labelMedium.copyWith(letterSpacing: 2),
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
  final bool isTimePicker;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.isTimePicker = false,
  });
}
