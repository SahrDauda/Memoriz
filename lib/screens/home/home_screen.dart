import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/stats_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final pendingCountAsync = ref.watch(pendingVersesCountProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: AppColors.surfaceDim,
            flexibleSpace: FlexibleSpaceBar(
              title: Hero(
                tag: 'app_title',
                child: Material(
                  color: Colors.transparent,
                  child: Text("MEMORIZ", style: AppTypography.displayLarge.copyWith(fontSize: 24, letterSpacing: 4)),
                ),
              ),
              centerTitle: true,
              background: Center(
                child: Hero(
                  tag: 'app_icon',
                  child: Image.asset(
                    'assets/images/logo_no_text.png',
                    width: 120,
                    height: 120,
                    color: AppColors.primary.withOpacity(0.1), // Subtle watermark effect
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("RECITATION READY"),
                  const SizedBox(height: 16),
                  pendingCountAsync.when(
                    data: (count) => _buildDailySessionCard(context, count),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => _buildDailySessionCard(context, 0),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader("MASTERY STATUS"),
                  const SizedBox(height: 16),
                  statsAsync.when(
                    data: (stats) => _buildStatsGrid(stats),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => _buildStatsGrid({'confident': 0, 'inProgress': 0, 'untouched': 0}),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.labelMedium.copyWith(letterSpacing: 2, color: AppColors.primary),
    );
  }

  Widget _buildDailySessionCard(BuildContext context, int pendingCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceMedium,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text("TODAY'S DISCIPLINE", style: AppTypography.labelSmall),
          const SizedBox(height: 12),
          Text("$pendingCount Verses Pending", style: AppTypography.displayMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surfaceDim,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("BEGIN SESSION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats) {
    return Row(
      children: [
        Expanded(child: _buildStatTile("Confident", "${stats['confident']}", AppColors.success)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatTile("In Progress", "${stats['inProgress']}", AppColors.primary)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatTile("Untouched", "${stats['untouched']}", AppColors.onSurface.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMedium,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.displayMedium.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

}
