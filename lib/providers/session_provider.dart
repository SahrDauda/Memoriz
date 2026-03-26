import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/verse.dart';
import '../data/repositories/verse_repository.dart';
import '../domain/engine/spaced_repetition_engine.dart';
import '../services/alarm_service.dart';

final verseRepositoryProvider = Provider((ref) => VerseRepository());
final alarmServiceProvider = Provider((ref) => AlarmService());

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(
    ref.watch(verseRepositoryProvider),
    ref.watch(alarmServiceProvider),
  );
});

enum ValidationResult { none, correct, incorrect }

class SessionState {
  final List<Verse> verses;
  final int currentIndex;
  final bool isRevealed;
  final bool isComplete;
  final Map<Rating, int> summary;
  final bool isLoading;
  final String currentInput;
  final ValidationResult validationResult;
  final bool isRated;

  SessionState({
    this.verses = const [],
    this.currentIndex = 0,
    this.isRevealed = false,
    this.isComplete = false,
    this.isLoading = false,
    this.currentInput = '',
    this.validationResult = ValidationResult.none,
    this.isRated = false,
    this.summary = const {
      Rating.struggling: 0,
      Rating.almostThere: 0,
      Rating.gotIt: 0,
    },
  });

  Verse? get currentVerse => verses.isNotEmpty && currentIndex < verses.length ? verses[currentIndex] : null;

  SessionState copyWith({
    List<Verse>? verses,
    int? currentIndex,
    bool? isRevealed,
    bool? isComplete,
    bool? isLoading,
    Map<Rating, int>? summary,
    String? currentInput,
    ValidationResult? validationResult,
    bool? isRated,
  }) {
    return SessionState(
      verses: verses ?? this.verses,
      currentIndex: currentIndex ?? this.currentIndex,
      isRevealed: isRevealed ?? this.isRevealed,
      isComplete: isComplete ?? this.isComplete,
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      currentInput: currentInput ?? this.currentInput,
      validationResult: validationResult ?? this.validationResult,
      isRated: isRated ?? this.isRated,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final VerseRepository _repository;
  final AlarmService _alarmService;

  SessionNotifier(this._repository, this._alarmService) : super(SessionState());

  Future<void> startSession() async {
    final verses = await _repository.getVersesForTodaySession();
    state = SessionState(verses: verses);
  }

  void reveal() {
    state = state.copyWith(isRevealed: true);
  }

  void updateInput(String input) {
    state = state.copyWith(currentInput: input);
  }

  void checkAnswer() {
    final currentVerse = state.currentVerse;
    if (currentVerse == null) return;

    // Simple fuzzy matching: lower case, remove punctuation
    final normalizedInput = state.currentInput.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
    final normalizedTarget = currentVerse.text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();

    if (normalizedInput == normalizedTarget) {
      state = state.copyWith(validationResult: ValidationResult.correct, isRevealed: true);
    } else {
      state = state.copyWith(validationResult: ValidationResult.incorrect, isRevealed: true);
    }
  }

  void tryAgain() {
    state = state.copyWith(
      currentInput: '',
      validationResult: ValidationResult.none,
      isRevealed: false,
      isRated: false,
    );
  }

  Future<void> rateVerse(Rating rating) async {
    final currentVerse = state.currentVerse;
    if (currentVerse == null) return;

    final updatedVerse = SpacedRepetitionEngine.applyRating(currentVerse, rating);
    await _repository.updateVerse(updatedVerse);

    final newSummary = Map<Rating, int>.from(state.summary);
    newSummary[rating] = (newSummary[rating] ?? 0) + 1;

    state = state.copyWith(
      isRated: true,
      summary: newSummary,
    );
  }

  void nextVerse() {
    if (state.currentIndex < state.verses.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        isRevealed: false,
        isRated: false,
        validationResult: ValidationResult.none,
        currentInput: '',
      );
    } else {
      state = state.copyWith(
        isComplete: true,
      );
      // Schedule next daily alarm with the first verse of tomorrow's session
      if (state.verses.isNotEmpty) {
        _alarmService.scheduleDailyAlarm(7, 0, state.verses.first);
      }
    }
  }

  Future<void> startMockRecitation() async {
    state = state.copyWith(isLoading: true);
    final verses = await _repository.getRandomVerses(3);
    state = state.copyWith(
      verses: verses,
      currentIndex: 0,
      isRevealed: false,
      isComplete: false,
      isLoading: false,
      summary: const {
        Rating.struggling: 0,
        Rating.almostThere: 0,
        Rating.gotIt: 0,
      },
    );
  }

  void reset() {
    state = SessionState();
  }
}
