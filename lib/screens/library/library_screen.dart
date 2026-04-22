import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/session_provider.dart';
import '../../providers/bible_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../services/tts_service.dart';

class BibleScreen extends ConsumerStatefulWidget {
  const BibleScreen({super.key});

  @override
  ConsumerState<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends ConsumerState<BibleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TtsService _ttsService = TtsService();
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentVerseIndex = 0;
  final ScrollController _verseScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ttsService.init();
    _ttsService.onVerseChanged = (index) {
      if (mounted) {
        setState(() => _currentVerseIndex = index);
        _scrollToVerse(index);
      }
    };
    _ttsService.onComplete = () {
      if (mounted) setState(() { _isPlaying = false; _isPaused = false; });
    };
  }

  void _scrollToVerse(int index) {
    if (_verseScrollController.hasClients) {
      _verseScrollController.animateTo(
        index * 110.0, // Consistent with card height
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    _tabController.dispose();
    _verseScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bibleState = ref.watch(bibleProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(bibleState),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildArchiveBrowser(bibleState),
                _buildMemorizedGallery(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BibleState bibleState) {
    String title = "THE ARCHIVE";
    if (bibleState.viewMode == BibleViewMode.chapters) title = bibleState.selectedBookName ?? "CHAPTERS";
    if (bibleState.viewMode == BibleViewMode.verses) {
       final chapterNum = bibleState.selectedChapterId?.split('.').last ?? '';
       title = "${bibleState.selectedBookName ?? ""} $chapterNum";
    }

    return SliverAppBar(
      expandedHeight: 160,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: bibleState.viewMode != BibleViewMode.books
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () {
                _ttsService.stop();
                ref.read(bibleProvider.notifier).goBack();
              },
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.language_rounded, color: AppColors.primary),
          onPressed: () => _showTranslationPicker(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 64),
        expandedTitleScale: 1.2,
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurface.withOpacity(0.4),
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 10),
          tabs: const [
            Tab(text: "BROWSE"),
            Tab(text: "MEMORIZED"),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveBrowser(BibleState bibleState) {
    if (bibleState.isLoading) return const Center(child: CircularProgressIndicator());

    switch (bibleState.viewMode) {
      case BibleViewMode.books:
        return _buildBookGrid(bibleState);
      case BibleViewMode.chapters:
        return _buildChapterSelection(bibleState);
      case BibleViewMode.verses:
        return _buildVerseArchive(bibleState);
    }
  }

  Widget _buildBookGrid(BibleState bibleState) {
    final bibleService = ref.read(bibleServiceProvider);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: bibleService.getBooks(bibleState.selectedBibleId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final book = snapshot.data![index];
            final name = (book['name'] as String?) ?? "Unknown";
            final initial = name.isNotEmpty ? name.substring(0, 1) : "B";
            return _buildBookCard(name, initial, book['id'] ?? "");
          },
        );
      },
    );
  }

  Widget _buildBookCard(String name, String initial, String id) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerHigh,
            AppColors.surfaceContainerLow,
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(bibleProvider.notifier).selectBook(id, name),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -10, bottom: -10,
                child: Text(
                  initial,
                  style: GoogleFonts.montserrat(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary.withOpacity(0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        initial,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterSelection(BibleState bibleState) {
    final bibleService = ref.read(bibleServiceProvider);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: bibleService.getChapters(bibleState.selectedBibleId!, bibleState.selectedBookId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final chapters = snapshot.data!.where((c) => c['number'] != 'intro').toList();
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return InkWell(
              onTap: () {
                _ttsService.stop();
                setState(() { _isPlaying = false; _isPaused = false; _currentVerseIndex = 0; });
                ref.read(bibleProvider.notifier).selectChapter(chapter['id']);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${chapter['number'] ?? index + 1}",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVerseArchive(BibleState bibleState) {
    final verses = List<Map<String, String>>.from(
      (bibleState.currentChapterVerses ?? []).map((v) {
        final map = v as Map<dynamic, dynamic>;
        return {
          'number': (map['number'] ?? "").toString(),
          'text': (map['text'] ?? "").toString(),
          'reference': (map['reference'] ?? "").toString(),
        };
      })
    );
    return Column(
      children: [
        _buildAudioBar(verses),
        Expanded(
          child: ListView.builder(
            controller: _verseScrollController,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            itemCount: verses.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final verseData = verses[index];
              final isActive = _isPlaying && _currentVerseIndex == index;
              return _buildVerseCard(verseData, index, isActive);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerseCard(Map<String, String> verse, int index, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.2),
          width: isActive ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 32, height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
             color: isActive ? AppColors.primary : AppColors.primary.withOpacity(0.1),
             shape: BoxShape.circle,
          ),
          child: Text(
            verse['number'] ?? "${index + 1}",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isActive ? Colors.white : AppColors.primary,
            ),
          ),
        ),
        title: Text(
          verse['text'] ?? "",
          style: GoogleFonts.inter(
            fontSize: 15,
            height: 1.6,
            color: isActive ? AppColors.onSurface : AppColors.onSurface.withOpacity(0.8),
          ),
        ),
        onTap: () => _showVerseDetails(context, verse, isFullBible: true),
      ),
    );
  }

  Widget _buildAudioBar(List<Map<String, String>> verses) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.headphones_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _isPlaying ? "Reading Verse ${_currentVerseIndex + 1}..." : "Listen to Chapter",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded, 
                 color: AppColors.primary, size: 32),
            onPressed: () async {
              if (!_isPlaying && !_isPaused) {
                final bibleState = ref.read(bibleProvider);
                final chapterNum = bibleState.selectedChapterId?.split('.').last ?? '';
                final label = "${bibleState.selectedBookName}, Chapter $chapterNum";
                setState(() { _isPlaying = true; _currentVerseIndex = 0; });
                await _ttsService.readChapter(verses, chapterLabel: label);
              } else if (_isPlaying) {
                await _ttsService.pause();
                setState(() { _isPlaying = false; _isPaused = true; });
              } else {
                setState(() { _isPlaying = true; _isPaused = false; });
                await _ttsService.resume();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemorizedGallery() {
    final repository = ref.watch(verseRepositoryProvider);
    return FutureBuilder(
      future: repository.getAllVerses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final verses = snapshot.data!;
        if (verses.isEmpty) {
          return Center(
            child: Text("No verses recorded in your archive.", 
              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant.withOpacity(0.5))),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                title: Text(verse.reference ?? "", style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primary)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(verse.text ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, 
                    style: GoogleFonts.lora(fontStyle: FontStyle.italic)),
                ),
                trailing: _buildMiniStatus(verse.familiarityScore ?? 0),
                onTap: () => _showVerseDetails(context, verse),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniStatus(int score) {
     Color color = AppColors.outlineVariant;
     if (score >= 5) color = AppColors.success;
     else if (score >= 3) color = AppColors.primary;
     return Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }

  void _showTranslationPicker(BuildContext context) {
    final state = ref.read(bibleProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text("THE TRANSLATIONS", style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12, color: AppColors.primary)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.availableBibles.length,
                itemBuilder: (context, index) {
                  final bible = state.availableBibles[index];
                  final isSelected = bible['id'] == state.selectedBibleId;
                  return ListTile(
                    title: Text(
                      (bible['name'] ?? "Unknown Translation").toString(), 
                      style: GoogleFonts.inter(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400, 
                        color: isSelected ? AppColors.primary : AppColors.onSurface
                      )
                    ),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                    onTap: () {
                      ref.read(bibleProvider.notifier).setBible(bible['id'], bible['name']);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerseDetails(BuildContext context, dynamic verse, {bool isFullBible = false}) {
     // Already fairly immersive, just ensuring color consistency
     showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Text(isFullBible ? (verse['reference'] ?? "").toString() : (verse.reference ?? ""), 
              style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 24),
            Text(isFullBible ? (verse['text'] ?? "").toString() : (verse.text ?? ""), textAlign: TextAlign.center,
              style: GoogleFonts.lora(fontSize: 18, height: 1.6, fontStyle: FontStyle.italic)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
