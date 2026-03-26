import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/session_provider.dart';
import '../../domain/engine/spaced_repetition_engine.dart';

class DailySessionScreen extends ConsumerStatefulWidget {
  const DailySessionScreen({super.key});

  @override
  ConsumerState<DailySessionScreen> createState() => _DailySessionScreenState();
}

class _DailySessionScreenState extends ConsumerState<DailySessionScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    Future.microtask(() => ref.read(sessionProvider.notifier).startSession());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final currentVerse = session.currentVerse;

    if (session.isComplete) {
      return _buildCompletionView(context, session);
    }

    if (currentVerse == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Decorative Elements
          _buildBackground(),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, session),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        _buildReference(currentVerse.reference),
                        const SizedBox(height: 60),
                        _buildMeditationArea(session),
                        const SizedBox(height: 48),
                        _buildActionArea(context, session),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(color: AppColors.surfaceDim),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
              child: const SizedBox.shrink(),
            ),
          ),
          // Blur effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.02),
                    Colors.transparent,
                  ],
                  center: Alignment.center,
                  radius: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SessionState session) {
    final progress = (session.currentIndex + 1) / session.verses.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          Text(
            "VERSE ${session.currentIndex + 1} OF ${session.verses.length}",
            style: AppTypography.labelSmall,
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReference(String reference) {
    return Column(
      children: [
        Text(
          reference,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            fontSize: 48,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "RECITE THIS VERSE FROM MEMORY",
          style: AppTypography.labelMedium.copyWith(
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMeditationArea(SessionState session) {
    // Clear controller if it's a new verse or we just clicked try again
    if (session.validationResult == ValidationResult.none && !session.isRevealed && _textController.text != session.currentInput) {
       _textController.text = session.currentInput;
    }

    final isDone = session.isRevealed || session.validationResult == ValidationResult.correct;

    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            onChanged: (val) => ref.read(sessionProvider.notifier).updateInput(val),
            maxLines: null,
            textAlign: TextAlign.center,
            readOnly: isDone,
            style: AppTypography.scripture.copyWith(
              color: isDone && session.validationResult == ValidationResult.incorrect 
                  ? AppColors.danger.withOpacity(0.7) 
                  : null,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: "TYPE THE VERSE HERE...",
              hintStyle: AppTypography.labelLarge.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.3)),
              border: InputBorder.none,
            ),
          ),
          if (isDone) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(
                    "CORRECT SCRIPTURE:",
                    style: AppTypography.labelSmall.copyWith(color: AppColors.primary, letterSpacing: 2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    session.currentVerse!.text,
                    textAlign: TextAlign.center,
                    style: AppTypography.scripture,
                  ),
                ],
              ),
            ),
          ] else if (session.validationResult == ValidationResult.incorrect) ...[
            const SizedBox(height: 16),
            Text(
              "NOT QUITE. CHECK YOUR SPELLING OR TRY AGAIN.",
              style: AppTypography.labelSmall.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionArea(BuildContext context, SessionState session) {
    if (session.isRated) {
      return Column(
        children: [
          _buildPrimaryButton(
            label: "CONTINUE TO NEXT",
            onTap: () {
               _textController.clear();
               ref.read(sessionProvider.notifier).nextVerse();
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
               _textController.clear();
               ref.read(sessionProvider.notifier).tryAgain();
            },
            child: Text("TRY TYPING AGAIN", style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
          ),
        ],
      );
    }

    if (session.isRevealed) {
      return Column(
        children: [
          _buildRatingButtons(context),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
               _textController.clear();
               ref.read(sessionProvider.notifier).tryAgain();
            },
            child: Text("TRY TYPING AGAIN", style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
          ),
        ],
      );
    }

    if (session.validationResult == ValidationResult.correct) {
      return Column(
        children: [
          _buildRatingButton(
            "Got It Perfectly",
            Icons.task_alt_rounded,
            AppColors.success,
            Rating.gotIt,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
               _textController.clear();
               ref.read(sessionProvider.notifier).tryAgain();
            },
            child: Text("PRACTICE AGAIN", style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildPrimaryButton(
          label: "CHECK ANSWER",
          onTap: () => ref.read(sessionProvider.notifier).checkAnswer(),
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildSecondaryButton(
          label: "FORGOT? REVEAL VERSE",
          onTap: () => ref.read(sessionProvider.notifier).reveal(),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: color == null ? AppColors.goldGradient : null,
          color: color,
          boxShadow: [
            if (color != null) BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: color == null ? AppColors.onPrimaryFixed : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelLarge,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingButtons(BuildContext context) {
    return Column(
      children: [
        Text(
          "HOW DID YOU DO?",
          style: AppTypography.labelSmall.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 20),
        _buildRatingButton(
          "Struggling",
          Icons.heart_broken_rounded,
          AppColors.danger,
          Rating.struggling,
        ),
        const SizedBox(height: 12),
        _buildRatingButton(
          "Almost There",
          Icons.hourglass_top_rounded,
          AppColors.warning,
          Rating.almostThere,
        ),
        const SizedBox(height: 12),
        _buildRatingButton(
          "Got It",
          Icons.task_alt_rounded,
          AppColors.success,
          Rating.gotIt,
        ),
      ],
    );
  }

  Widget _buildRatingButton(String label, IconData icon, Color color, Rating rating) {
    return InkWell(
      onTap: () => ref.read(sessionProvider.notifier).rateVerse(rating),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Icon(icon, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context, SessionState session) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Well done.",
                    style: AppTypography.headline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "\"The Word is taking root.\"",
                    style: AppTypography.scripture.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 48),
                  _buildSummaryRow(session),
                  const SizedBox(height: 48),
                  InkWell(
                    onTap: () {
                      ref.read(sessionProvider.notifier).reset();
                      // Navigate back or home
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: AppColors.goldGradient,
                      ),
                      child: Center(
                        child: Text(
                          "RETURN HOME",
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.onPrimaryFixed,
                          ),
                        ),
                      ),
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

  Widget _buildSummaryRow(SessionState session) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryStat(session.summary[Rating.gotIt] ?? 0, "Got It", AppColors.success),
        _buildSummaryStat(session.summary[Rating.almostThere] ?? 0, "Almost", AppColors.warning),
        _buildSummaryStat(session.summary[Rating.struggling] ?? 0, "Struggled", AppColors.danger),
      ],
    );
  }

  Widget _buildSummaryStat(int count, String label, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: AppTypography.headline.copyWith(color: color),
        ),
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall,
        ),
      ],
    );
  }
}
