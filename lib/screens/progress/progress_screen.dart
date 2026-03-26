import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      backgroundColor: AppColors.surfaceDim,
      appBar: AppBar(
        title: const Text("ANCESTRY", style: TextStyle(letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            overallAsync.when(
              data: (value) => _buildMasteryWheel(value),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildMasteryWheel(0.0),
            ),
            const SizedBox(height: 48),
            allVersesAsync.when(
              data: (verses) => _buildFamiliarityGrid(verses),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildFamiliarityGrid([]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryWheel(double value) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 4,
            color: AppColors.primary,
            backgroundColor: AppColors.primary.withOpacity(0.1),
          ),
        ),
        Column(
          children: [
            Text("${(value * 100).toInt()}%", style: AppTypography.displayLarge),
            Text("OVERALL MASTERY", style: AppTypography.labelSmall),
          ],
        ),
      ],
    );
  }

  Widget _buildFamiliarityGrid(List<dynamic> verses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("FAMILIARITY MAP", style: AppTypography.labelMedium),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            Color color = AppColors.surfaceMedium;
            if (verse.familiarityScore >= 5) color = AppColors.success;
            else if (verse.familiarityScore >= 3) color = AppColors.primary;
            else if (verse.familiarityScore >= 1) color = AppColors.primary.withOpacity(0.4);
            
            return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ],
    );
  }
}
