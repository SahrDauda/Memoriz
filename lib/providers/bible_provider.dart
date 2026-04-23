import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final int currentVerseIndex;
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
    this.currentVerseIndex = 0,
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
    int? currentVerseIndex,
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
      currentVerseIndex: currentVerseIndex ?? this.currentVerseIndex,
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
      final prefs = await SharedPreferences.getInstance();
      final allBibles = await _bibleService.getBibles();
      
      if (allBibles.isEmpty) {
        state = state.copyWith(isLoading: false, errorMessage: "No Bibles available.");
        return;
      }

      final validSignatures = ['KJV', 'ENGKJV', 'NKJV', 'NLT', 'NIV11', 'NIV'];
      final Map<String, Map<String, dynamic>> uniqueBibles = {};
      
      for (var bible in allBibles) {
        final abbr = (bible['abbreviation'] ?? '').toString().toUpperCase();
        if (validSignatures.contains(abbr)) {
           String name = (bible['name'] ?? "").toString();
           if (name.contains("King James (Authorised)")) name = "KJV - King James Version";
           if (name.contains("New King James")) name = "NKJV - New King James";
           if (name.contains("New Living Translation")) name = "NLT - New Living Translation";
           if (name.contains("New International Version")) name = "NIV - New International Version";
           bible['name'] = name;
           uniqueBibles[name] = bible;
        }
      }
      
      final finalBiblesList = uniqueBibles.values.toList();
      
      // Load persisted IDs
      final savedBibleId = prefs.getString('bible_selected_bible_id');
      final savedBibleName = prefs.getString('bible_selected_bible_name');
      final savedBookId = prefs.getString('bible_selected_book_id');
      final savedBookName = prefs.getString('bible_selected_book_name');
      final savedChapterId = prefs.getString('bible_selected_chapter_id');
      final savedVerseIndex = prefs.getInt('bible_current_verse_index') ?? 0;
      final savedViewModeStr = prefs.getString('bible_view_mode') ?? 'books';
      
      BibleViewMode savedViewMode = BibleViewMode.books;
      if (savedViewModeStr == 'chapters') savedViewMode = BibleViewMode.chapters;
      if (savedViewModeStr == 'verses') savedViewMode = BibleViewMode.verses;

      final defaultBible = finalBiblesList.firstWhere(
        (b) => b['id'] == savedBibleId,
        orElse: () => finalBiblesList.firstWhere(
          (b) => b['name'].toString().contains('KJV'), 
          orElse: () => finalBiblesList.first
        )
      );
      
      state = state.copyWith(
        availableBibles: finalBiblesList,
        selectedBibleId: defaultBible['id'],
        selectedBibleName: defaultBible['name'],
        selectedBookId: savedBookId,
        selectedBookName: savedBookName,
        selectedChapterId: savedChapterId,
        currentVerseIndex: savedVerseIndex,
        viewMode: savedViewMode,
        isLoading: false,
      );

      // If we were in verse mode, restore the content
      if (savedViewMode == BibleViewMode.verses && savedChapterId != null) {
        await selectChapter(savedChapterId, saveToPrefs: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "API Error: $e");
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (state.selectedBibleId != null) await prefs.setString('bible_selected_bible_id', state.selectedBibleId!);
    if (state.selectedBibleName != null) await prefs.setString('bible_selected_bible_name', state.selectedBibleName!);
    if (state.selectedBookId != null) {
      await prefs.setString('bible_selected_book_id', state.selectedBookId!);
    } else {
      await prefs.remove('bible_selected_book_id');
    }
    if (state.selectedBookName != null) {
      await prefs.setString('bible_selected_book_name', state.selectedBookName!);
    } else {
      await prefs.remove('bible_selected_book_name');
    }
    if (state.selectedChapterId != null) {
      await prefs.setString('bible_selected_chapter_id', state.selectedChapterId!);
    } else {
      await prefs.remove('bible_selected_chapter_id');
    }
    await prefs.setInt('bible_current_verse_index', state.currentVerseIndex);
    await prefs.setString('bible_view_mode', state.viewMode.name);
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
    await _saveToPrefs();

    if (prevChapterId != null && prevViewMode == BibleViewMode.verses) {
      await selectChapter(prevChapterId);
    } else if (prevBookId != null) {
      state = state.copyWith(
        selectedBookId: prevBookId,
        selectedBookName: prevBookName,
        viewMode: BibleViewMode.chapters,
        isLoading: false,
      );
      await _saveToPrefs();
    } else {
      state = state.copyWith(
        selectedBookId: null,
        selectedChapterId: null,
        viewMode: BibleViewMode.books,
        isLoading: false,
      );
      await _saveToPrefs();
    }
  }

  void selectBook(String bookId, String bookName) {
    state = state.copyWith(
      selectedBookId: bookId,
      selectedBookName: bookName,
      viewMode: BibleViewMode.chapters,
      currentVerseIndex: 0,
    );
    _saveToPrefs();
  }

  Future<void> selectChapter(String chapterId, {bool saveToPrefs = true, int? verseIndex}) async {
    if (state.selectedBibleId == null) return;
    
    state = state.copyWith(
      isLoading: true, 
      selectedChapterId: chapterId,
      currentVerseIndex: verseIndex ?? 0,
    );
    if (saveToPrefs) await _saveToPrefs();
    
    try {
      final data = await _bibleService.getChapterContent(state.selectedBibleId!, chapterId);
      final String htmlContent = data['content'] ?? "";
      
      final List<Map<String, String>> parsedVerses = [];
      final verseRegex = RegExp(r'<span data-number="(\d+)"[^>]*>');
      final matches = verseRegex.allMatches(htmlContent).toList();
      
      for (int i = 0; i < matches.length; i++) {
        final currentMatch = matches[i];
        final verseNumber = currentMatch.group(1)!;
        final startPos = currentMatch.end;
        final endPos = (i + 1 < matches.length) ? matches[i + 1].start : htmlContent.length;
        
        String verseText = htmlContent.substring(startPos, endPos);
        verseText = verseText.replaceAll(RegExp(r'<[^>]*>'), '');
        verseText = verseText.replaceAll(RegExp(r'&nbsp;'), ' ');
        verseText = verseText.replaceAll(RegExp(r'&amp;'), '&');
        verseText = verseText.replaceAll(RegExp(r'&lt;'), '<');
        verseText = verseText.replaceAll(RegExp(r'&gt;'), '>');
        verseText = verseText.replaceAll(RegExp(r'&[^;]+;'), '');
        verseText = verseText.replaceFirst(RegExp(r'^\d+\s*'), '').trim();
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
      if (saveToPrefs) await _saveToPrefs();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Parsing Error: $e");
    }
  }

  void setVerseIndex(int index) {
    state = state.copyWith(currentVerseIndex: index);
    _saveToPrefs();
  }

  void goBack() {
    if (state.viewMode == BibleViewMode.verses) {
      state = state.copyWith(viewMode: BibleViewMode.chapters, currentChapterVerses: null, currentVerseIndex: 0);
    } else if (state.viewMode == BibleViewMode.chapters) {
      state = state.copyWith(viewMode: BibleViewMode.books, selectedBookId: null, selectedChapterId: null, currentVerseIndex: 0);
    }
    _saveToPrefs();
  }

  void reset() {
    state = BibleState(
      availableBibles: state.availableBibles,
      selectedBibleId: state.selectedBibleId,
      selectedBibleName: state.selectedBibleName,
    );
    _saveToPrefs();
  }
}

final bibleServiceProvider = Provider((ref) => BibleService());

final bibleProvider = StateNotifierProvider<BibleNotifier, BibleState>((ref) {
  return BibleNotifier(ref.watch(bibleServiceProvider));
});
