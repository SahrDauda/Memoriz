import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/stats_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/daily_verse_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey _shareKey = GlobalKey();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    // Check for initial deep-linked verse content after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navState = ref.read(navigationProvider);
      if (navState.deepLinkVerseContent != null) {
        _showInspirationModal(context, navState.deepLinkVerseContent!);
      }
    });
  }

  Future<void> _shareDailyVerse(DailyVerse verse) async {
    setState(() => _isSharing = true);
    
    // Give a frame for the UI to update and hide the share button
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final boundary = _shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/daily_devotion.png').create();
      await file.writeAsBytes(buffer);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "${verse.text}\n\n— ${verse.reference}\n\nShared via Memoriz App",
      );
    } catch (e) {
      debugPrint("Error sharing: $e");
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showInspirationModal(BuildContext context, String content) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Inspiration",
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: AppColors.surfaceContainerHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Column(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 32),
                  const SizedBox(height: 12),
                  Text("BREAD FOR THE SOUL", 
                    style: AppTypography.labelMedium.copyWith(letterSpacing: 2, color: AppColors.primary)),
                ],
              ),
              content: SingleChildScrollView(
                child: Text(
                  content,
                  style: GoogleFonts.lora(
                    fontSize: 18, 
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(navigationProvider.notifier).clearTargetVerse();
                      Navigator.pop(context);
                    },
                    child: const Text("AMEN", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsProvider);
    final pendingCountAsync = ref.watch(pendingVersesCountProvider);
    final dailyVerse = ref.watch(dailyVerseProvider);

    // Listen for deep-linked verses to show the modal
    ref.listen(navigationProvider.select((s) => s.deepLinkVerseContent), (previous, next) {
      if (next != null) {
        _showInspirationModal(context, next);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 520,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(
                    key: _shareKey,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image with error safe-guard
                        Image.asset(
                          dailyVerse.backgroundAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surfaceContainerHigh,
                            child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: AppColors.primary)),
                          ),
                        ),
                        // Dark Vignette Overlays for readability
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                                AppColors.surface.withOpacity(0.7),
                                AppColors.surface,
                              ],
                              stops: const [0.0, 0.4, 0.88, 1.0],
                            ),
                          ),
                        ),
                        // Content (Text & Reference) for the image
                        Padding(
                          padding: const EdgeInsets.fromLTRB(32, 100, 32, 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCategoryBadge("DAILY DEVOTION"),
                              const SizedBox(height: 32),
                              Text(
                                dailyVerse.text,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lora(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 1.6,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 15.0,
                                      color: Colors.black.withOpacity(0.6),
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                dailyVerse.reference,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isSharing) ...[
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _HeroActionButton(
                          icon: Icons.share_rounded,
                          label: "Share",
                          onTap: () => _shareDailyVerse(dailyVerse),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              title: Text(
                "MEMORIZ",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  fontSize: 18,
                  color: AppColors.primary.withOpacity(0.9),
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader("MASTERY HUB"),
                const SizedBox(height: 16),
                _buildStatsGrid(statsAsync),
                const SizedBox(height: 32),
                _buildSectionHeader("ACTIVE COMMITMENT"),
                const SizedBox(height: 16),
                pendingCountAsync.when(
                  data: (count) => _buildActiveSessionCard(context, count),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => _buildActiveSessionCard(context, 0),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: AppColors.onSurfaceVariant.withOpacity(0.6),
      ),
    );
  }

  Widget _buildStatsGrid(AsyncValue<Map<String, int>> statsAsync) {
    return statsAsync.when(
      data: (stats) => Row(
        children: [
          Expanded(child: _buildStatCard("Streak", "7D", Icons.local_fire_department_rounded, Colors.orange)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard("Mastered", "${stats['confident'] ?? 0}", Icons.auto_awesome, AppColors.success)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard("Learning", "${stats['inProgress'] ?? 0}", Icons.menu_book_rounded, AppColors.primary)),
        ],
      ),
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Text("Error loading stats"),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionCard(BuildContext context, int count) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryContainer.withOpacity(0.3),
            AppColors.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/session'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recitation Ready",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "You have $count verses to review today.",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeroActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
