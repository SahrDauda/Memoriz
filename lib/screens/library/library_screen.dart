import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/session_provider.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(verseRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      appBar: AppBar(
        title: const Text("LIBRARY", style: TextStyle(letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: repository.getAllVerses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final verses = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: verses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final verse = verses[index];
              return GestureDetector(
                onTap: () => _showVerseDetails(context, verse),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMedium,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(verse.reference, style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                          _buildStatusIndicator(verse.familiarityScore),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        verse.text,
                        style: AppTypography.bodySmall.copyWith(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showVerseDetails(BuildContext context, dynamic verse) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppColors.surfaceDim,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Text(verse.reference, style: AppTypography.displayMedium.copyWith(color: AppColors.primary)),
            const SizedBox(height: 24),
            Text(
              verse.text,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(fontSize: 18, height: 1.6),
            ),
            const SizedBox(height: 40),
            _buildStatusIndicator(verse.familiarityScore),
            const SizedBox(height: 8),
            Text(
              verse.familiarityScore >= 5 ? "MASTERED" : "KEEP RECITING",
              style: AppTypography.labelSmall.copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(int score) {
    Color color = AppColors.onSurface.withOpacity(0.2);
    if (score >= 5) color = AppColors.success;
    else if (score >= 3) color = AppColors.primary;

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
