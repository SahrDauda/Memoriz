import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/session_provider.dart';
import '../../providers/daily_verse_provider.dart';
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
    final dailyVerse = ref.watch(dailyVerseProvider);

    if (session.isComplete) {
      return _buildCompletionView(context, session);
    }

    if (currentVerse == null) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ── SANCTUM BACKDROP ───────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              dailyVerse.backgroundAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainerHigh),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surface.withOpacity(0.4),
                      AppColors.surface.withOpacity(0.8),
                      AppColors.surface,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── MAIN CONTENT ────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildHeader(session),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        _buildFocusCard(session),
                        const SizedBox(height: 32),
                        _buildActionArea(session),
                        const SizedBox(height: 48),
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

  Widget _buildHeader(SessionState session) {
    final progress = (session.currentIndex + 1) / session.verses.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                "VERSE ${session.currentIndex + 1} OF ${session.verses.length}",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 48), // Spacer for balance
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: AppColors.outlineVariant.withOpacity(0.1),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusCard(SessionState session) {
     final currentVerse = session.currentVerse!;
     final isDone = session.isRevealed || session.validationResult == ValidationResult.correct;

     // Input Synchronization
     if (session.validationResult == ValidationResult.none && !session.isRevealed && _textController.text != session.currentInput) {
        _textController.text = session.currentInput;
     }

     return Container(
       width: double.infinity,
       padding: const EdgeInsets.all(32),
       decoration: BoxDecoration(
         color: Colors.white.withOpacity(0.05),
         borderRadius: BorderRadius.circular(32),
         border: Border.all(color: Colors.white.withOpacity(0.08)),
       ),
       child: Column(
         children: [
           Text(
             currentVerse.reference,
             style: GoogleFonts.montserrat(
               fontSize: 28,
               fontWeight: FontWeight.w800,
               color: AppColors.primary,
             ),
           ),
           const SizedBox(height: 8),
           Text(
             "RECITE FROM MEMORY",
             style: GoogleFonts.inter(
               fontSize: 10,
               fontWeight: FontWeight.w700,
               letterSpacing: 2,
               color: AppColors.onSurfaceVariant.withOpacity(0.6),
             ),
           ),
           const SizedBox(height: 48),
           
           // Typing Area
           TextField(
             controller: _textController,
             onChanged: (val) => ref.read(sessionProvider.notifier).updateInput(val),
             maxLines: null,
             textAlign: TextAlign.center,
             readOnly: isDone,
             style: GoogleFonts.lora(
               fontSize: 20,
               height: 1.6,
               color: isDone && session.validationResult == ValidationResult.incorrect 
                   ? AppColors.error.withOpacity(0.6) 
                   : AppColors.onSurface,
             ),
             cursorColor: AppColors.primary,
             decoration: InputDecoration(
               hintText: "Begin writing...",
               hintStyle: GoogleFonts.lora(
                 fontSize: 20,
                 fontStyle: FontStyle.italic,
                 color: AppColors.onSurfaceVariant.withOpacity(0.3),
               ),
               border: InputBorder.none,
             ),
           ),

           if (isDone) ...[
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 32),
               child: Divider(color: Colors.white10),
             ),
             Text(
               "CORRECT SCRIPTURE",
               style: GoogleFonts.inter(
                 fontSize: 10,
                 fontWeight: FontWeight.w900,
                 color: AppColors.primary,
               ),
             ),
             const SizedBox(height: 16),
             Text(
               currentVerse.text,
               textAlign: TextAlign.center,
               style: GoogleFonts.lora(
                 fontSize: 18,
                 height: 1.6,
                 fontStyle: FontStyle.italic,
                 color: AppColors.onSurface.withOpacity(0.9),
               ),
             ),
           ] else if (session.validationResult == ValidationResult.incorrect) ...[
             const SizedBox(height: 24),
             Text(
               "Check your spelling or reveal verse.",
               style: GoogleFonts.inter(
                 fontSize: 12,
                 color: AppColors.error.withOpacity(0.8),
               ),
             ),
           ],
         ],
       ),
     );
  }

  Widget _buildActionArea(SessionState session) {
    if (session.isRated) {
      return _buildPrimaryButton(
        label: "Next Verse",
        icon: Icons.navigate_next_rounded,
        onTap: () {
           _textController.clear();
           ref.read(sessionProvider.notifier).nextVerse();
        },
      );
    }

    if (session.isRevealed) {
      return Column(
        children: [
          Text(
            "HOW DID YOU DO?",
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          _buildRatingSuite(),
          const SizedBox(height: 24),
          _buildSecondaryButton(
            label: "Try Again",
            onTap: () {
               _textController.clear();
               ref.read(sessionProvider.notifier).tryAgain();
            },
          ),
        ],
      );
    }

    if (session.validationResult == ValidationResult.correct) {
      return Column(
        children: [
          _buildPrimaryButton(
            label: "Verify Perfection",
            icon: Icons.check_circle_rounded,
            onTap: () => ref.read(sessionProvider.notifier).rateVerse(Rating.gotIt),
          ),
          const SizedBox(height: 24),
          _buildSecondaryButton(
            label: "Practice More",
            onTap: () {
               _textController.clear();
               ref.read(sessionProvider.notifier).tryAgain();
            },
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildPrimaryButton(
          label: "Assess Memory",
          onTap: () => ref.read(sessionProvider.notifier).checkAnswer(),
        ),
        const SizedBox(height: 16),
        _buildSecondaryButton(
          label: "Reveal Scripture",
          onTap: () => ref.read(sessionProvider.notifier).reveal(),
        ),
      ],
    );
  }

  Widget _buildRatingSuite() {
    return Row(
      children: [
        Expanded(child: _buildRatingAction("Failed", AppColors.error, Rating.struggling)),
        const SizedBox(width: 12),
        Expanded(child: _buildRatingAction("Partial", AppColors.warning, Rating.almostThere)),
        const SizedBox(width: 12),
        Expanded(child: _buildRatingAction("Success", AppColors.success, Rating.gotIt)),
      ],
    );
  }

  Widget _buildRatingAction(String label, Color color, Rating rating) {
    return InkWell(
      onTap: () => ref.read(sessionProvider.notifier).rateVerse(rating),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onTap, IconData? icon}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 12),
              Icon(icon, color: Colors.white, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context, SessionState session) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 48),
              Text(
                "Sabbath Rest",
                style: GoogleFonts.lora(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "You have hidden the Word in your heart today.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 64),
              _buildPrimaryButton(
                label: "Return to Home",
                onTap: () {
                   ref.read(sessionProvider.notifier).reset();
                   Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
