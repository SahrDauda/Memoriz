import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/stats_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallAsync = ref.watch(overallMasteryProvider);
    final allVersesAsync = ref.watch(allVersesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "LEGACY",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  overallAsync.when(
                    data: (value) => _buildIlluminatedGauge(value),
                    loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
                    error: (_, __) => _buildIlluminatedGauge(0.0),
                  ),
                  const SizedBox(height: 48),
                  _buildSectionHeader("SPIRITUAL MILESTONES"),
                  const SizedBox(height: 20),
                  _buildMilestonesRow(),
                  const SizedBox(height: 48),
                  _buildSectionHeader("FAMILIARITY MAP"),
                  const SizedBox(height: 20),
                  allVersesAsync.when(
                    data: (verses) => _buildHeatMap(verses),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text("Error loading map"),
                  ),
                  const SizedBox(height: 48),
                  _buildSectionHeader("RECENT VICTORIES"),
                  const SizedBox(height: 20),
                  allVersesAsync.when(
                    data: (verses) => _buildRecentVictories(verses),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text("Error loading victories"),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: AppColors.outlineVariant.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildIlluminatedGauge(double value) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: _GaugePainter(
              progress: value,
              color: AppColors.primary,
              backgroundColor: AppColors.outlineVariant.withOpacity(0.1),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${(value * 100).toInt()}%",
              style: GoogleFonts.lora(
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              "HEART MASTERY",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestonesRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildMilestoneBadge("Faithful", Icons.auto_awesome_rounded, true),
          _buildMilestoneBadge("Steadfast", Icons.anchor_rounded, true),
          _buildMilestoneBadge("Scholar", Icons.history_edu_rounded, false),
          _buildMilestoneBadge("Evangelist", Icons.share_rounded, false),
        ],
      ),
    );
  }

  Widget _buildMilestoneBadge(String label, IconData icon, bool unlocked) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked ? AppColors.primary.withOpacity(0.3) : AppColors.outlineVariant.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: unlocked ? AppColors.primary : AppColors.onSurfaceVariant.withOpacity(0.4),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: unlocked ? AppColors.onSurface : AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatMap(List<dynamic> verses) {
    if (verses.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text("Start memorizing to build your map.", style: AppTypography.bodySmall),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: verses.map((verse) {
          Color color = AppColors.outlineVariant.withOpacity(0.2);
          if (verse.familiarityScore >= 5) color = AppColors.success;
          else if (verse.familiarityScore >= 3) color = AppColors.primary;
          else if (verse.familiarityScore >= 1) color = AppColors.primary.withOpacity(0.4);

          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              boxShadow: verse.familiarityScore >= 5 ? [
                BoxShadow(color: AppColors.success.withOpacity(0.3), blurRadius: 4)
              ] : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentVictories(List<dynamic> verses) {
    final mastered = verses.where((v) => v.familiarityScore >= 4).toList();
    if (mastered.isEmpty) {
      return const Text("No recent victories yet. Keep reciting!");
    }

    return Column(
      children: mastered.take(3).map((verse) => _buildVictoryCard(verse)).toList(),
    );
  }

  Widget _buildVictoryCard(dynamic verse) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
              const SizedBox(width: 8),
              Text(
                verse.reference,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            verse.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.2;
    const strokeWidth = 12.0;

    // Background Arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.75,
        math.pi * 1.5 * progress,
        false,
        progressPaint,
      );
    }

    // Tick Marks
    final tickPaint = Paint()
      ..color = backgroundColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i <= 30; i++) {
       final angle = math.pi * 0.75 + (math.pi * 1.5 * (i / 30));
       final start = Offset(
         center.dx + (radius + 15) * math.cos(angle),
         center.dy + (radius + 15) * math.sin(angle),
       );
       final end = Offset(
         center.dx + (radius + 20) * math.cos(angle),
         center.dy + (radius + 20) * math.sin(angle),
       );
       canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
