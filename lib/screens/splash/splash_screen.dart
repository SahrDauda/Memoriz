import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/settings_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    
    _controller.forward();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final settings = ref.read(settingsProvider);
    final hasCompletedOnboarding = settings.hasCompletedOnboarding;

    if (hasCompletedOnboarding) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/bg_devotion.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: AppColors.surfaceDim),
          ),
          // Dark Overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 180,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.auto_awesome, size: 100, color: AppColors.primary),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "MEMORIZ",
                    style: AppTypography.displayLarge.copyWith(
                      letterSpacing: 12,
                      fontSize: 32,
                      color: AppColors.primary,
                      shadows: [
                        Shadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "ILLUMINATED CODEX",
                    style: AppTypography.labelMedium.copyWith(
                      letterSpacing: 6,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
