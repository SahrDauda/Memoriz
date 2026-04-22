import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bible_service.dart';

enum BibleViewMode { books, chapters, verses }

class BibleState {
  final BibleViewMode viewMode;
  final List<Map<String, dynamic>> availableBibles;
  final String? selectedBibleId;
  final String? selectedBibleName;
  final String? selectedBookId;
  final String? selectedBookName;
  final String? selectedChapterId;
  final List<dynamic>? currentChapterVerses;
  final bool isLoading;
  final String? errorMessage;

  BibleState({
    this.viewMode = BibleViewMode.books,
    this.availableBibles = const [],
    this.selectedBibleId,
    this.selectedBibleName,
    this.selectedBookId,
    this.selectedBookName,
    this.selectedChapterId,
    this.currentChapterVerses,
    this.isLoading = false,
    this.errorMessage,
  });

  BibleState copyWith({
    BibleViewMode? viewMode,
    List<Map<String, dynamic>>? availableBibles,
    String? selectedBibleId,
    String? selectedBibleName,
    String? selectedBookId,
    String? selectedBookName,
    String? selectedChapterId,
    List<dynamic>? currentChapterVerses,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BibleState(
      viewMode: viewMode ?? this.viewMode,
      availableBibles: availableBibles ?? this.availableBibles,
      selectedBibleId: selectedBibleId ?? this.selectedBibleId,
      selectedBibleName: selectedBibleName ?? this.selectedBibleName,
      selectedBookId: selectedBookId ?? this.selectedBookId,
      selectedBookName: selectedBookName ?? this.selectedBookName,
      selectedChapterId: selectedChapterId ?? this.selectedChapterId,
      currentChapterVerses: currentChapterVerses ?? this.currentChapterVerses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BibleNotifier extends StateNotifier<BibleState> {
  final BibleService _bibleService;

  BibleNotifier(this._bibleService) : super(BibleState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final allBibles = await _bibleService.getBibles();
      if (allBibles.isEmpty) {
        state = state.copyWith(isLoading: false, errorMessage: "No Bibles available for this key.");
        return;
      }

      // Filter to exactly the 10 requested translations
      final requestedAbbreviations = [
        'KJV', 'NKJV', 'ESV', 'NIV', 'NLT', 'RSV', 'CJB', 'MSG', 'GNT', 'AMP', 'KRI', 'KRIO'
      ];
      final requestedNames = [
        'King James', 'New King James', 'English Standard', 'New International', 
        'New Living', 'Revised Standard', 'Complete Jewish', 'The Message', 
        'Good News', 'Amplified', 'Krio', 'Sierra Leone'
      ];

      final filteredBibles = allBibles.where((bible) {
        final abbr = (bible['abbreviation'] ?? '').toString().toUpperCase();
        final name = (bible['name'] ?? '').toString().toUpperCase();
        final lang = (bible['language'] != null && bible['language']['id'] != null) 
            ? bible['language']['id'].toString().toLowerCase() 
            : '';
        
        return requestedAbbreviations.any((req) => abbr.contains(req)) ||
               requestedNames.any((req) => name.contains(req.toUpperCase())) ||
               lang == 'kri';
      }).toList();

      if (filteredBibles.isEmpty) {
        // If filtering fails, fallback to all (or show error), but user wants strictly these.
        // For now, we take what we found or just use KJV if found.
        state = state.copyWith(
          availableBibles: allBibles, // Fallback to all if filter returns nothing (safe)
          isLoading: false,
          errorMessage: filteredBibles.isEmpty ? "Requested translations not found on this API key." : null,
        );
      }
      
      final defaultBible = filteredBibles.isNotEmpty 
        ? filteredBibles.firstWhere((b) => b['abbreviation'] == 'KJV', orElse: () => filteredBibles.first)
        : allBibles.first;
      
      state = state.copyWith(
        availableBibles: filteredBibles.isNotEmpty ? filteredBibles : allBibles,
        selectedBibleId: defaultBible['id'],
        selectedBibleName: defaultBible['name'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "API Error: $e");
    }
  }

  Future<void> setBible(String id, String name) async {
    final prevChapterId = state.selectedChapterId;
    final prevBookId = state.selectedBookId;
    final prevBookName = state.selectedBookName;
    final prevViewMode = state.viewMode;

    state = state.copyWith(
      selectedBibleId: id,
      selectedBibleName: name,
      isLoading: true,
    );

    if (prevChapterId != null && prevViewMode == BibleViewMode.verses) {
      // Sync to the same chapter in the new translation
      await selectChapter(prevChapterId);
    } else if (prevBookId != null) {
      // Stay in chapter selection for the same book
      state = state.copyWith(
        selectedBookId: prevBookId,
        selectedBookName: prevBookName,
        viewMode: BibleViewMode.chapters,
        isLoading: false,
      );
    } else {
      // Reset to book browser
      state = state.copyWith(
        selectedBookId: null,
        selectedChapterId: null,
        viewMode: BibleViewMode.books,
        isLoading: false,
      );
    }
  }

  void selectBook(String bookId, String bookName) {
    state = state.copyWith(
      selectedBookId: bookId,
      selectedBookName: bookName,
      viewMode: BibleViewMode.chapters,
    );
  }

  Future<void> selectChapter(String chapterId) async {
    if (state.selectedBibleId == null) return;
    
    state = state.copyWith(isLoading: true, selectedChapterId: chapterId);
    
    try {
      final data = await _bibleService.getChapterContent(state.selectedBibleId!, chapterId);
      final String htmlContent = data['content'] ?? "";
      
      // Parse verses from HTML
      // Typically: <span data-number="1" class="v">Text...</span>
      // We use a regex to find verse spans and their numbers
      final List<Map<String, String>> parsedVerses = [];
      
      // Find all verse numbers and their starting positions
      final verseRegex = RegExp(r'<span data-number="(\d+)"[^>]*>');
      final matches = verseRegex.allMatches(htmlContent).toList();
      
      for (int i = 0; i < matches.length; i++) {
        final currentMatch = matches[i];
        final verseNumber = currentMatch.group(1)!;
        
        // Find the start of the next verse or the end of the content
        final startPos = currentMatch.end;
        final endPos = (i + 1 < matches.length) ? matches[i + 1].start : htmlContent.length;
        
        String verseText = htmlContent.substring(startPos, endPos);
        // Strip all HTML tags and common HTML entities
        verseText = verseText.replaceAll(RegExp(r'<[^>]*>'), '');
        verseText = verseText.replaceAll(RegExp(r'&nbsp;'), ' ');
        verseText = verseText.replaceAll(RegExp(r'&amp;'), '&');
        verseText = verseText.replaceAll(RegExp(r'&lt;'), '<');
        verseText = verseText.replaceAll(RegExp(r'&gt;'), '>');
        verseText = verseText.replaceAll(RegExp(r'&[^;]+;'), '');
        
        // The API embeds the verse number inside the span as text.
        // After stripping HTML, text looks like "1In the beginning..."
        // We remove any leading digit(s) left behind by the span content.
        verseText = verseText.replaceFirst(RegExp(r'^\d+\s*'), '').trim();
        
        // Normalise whitespace
        verseText = verseText.replaceAll(RegExp(r'\s+'), ' ').trim();
        
        parsedVerses.add({
          'id': "$chapterId.$verseNumber",
          'number': verseNumber,
          'text': verseText,
          'reference': "${state.selectedBookName} ${chapterId.split('.').last}:$verseNumber",
        });
      }

      state = state.copyWith(
        currentChapterVerses: parsedVerses,
        viewMode: BibleViewMode.verses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Parsing Error: $e");
    }
  }

  void goBack() {
    if (state.viewMode == BibleViewMode.verses) {
      state = state.copyWith(viewMode: BibleViewMode.chapters, currentChapterVerses: null);
    } else if (state.viewMode == BibleViewMode.chapters) {
      state = state.copyWith(viewMode: BibleViewMode.books, selectedBookId: null);
    }
  }

  void reset() {
    state = BibleState(
      availableBibles: state.availableBibles,
      selectedBibleId: state.selectedBibleId,
      selectedBibleName: state.selectedBibleName,
    );
  }
}

final bibleServiceProvider = Provider((ref) => BibleService());

final bibleProvider = StateNotifierProvider<BibleNotifier, BibleState>((ref) {
  return BibleNotifier(ref.watch(bibleServiceProvider));
});
