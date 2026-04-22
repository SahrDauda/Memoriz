import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentVerseIndex = 0;
  List<Map<String, String>> _verses = [];
  Function(int)? onVerseChanged;
  Function()? onComplete;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get currentVerseIndex => _currentVerseIndex;

  Future<void> init() async {
    // English UK generally has a more classical, narrative tone for scripture reading
    await _tts.setLanguage("en-GB");

    // Natural reading pace — deliberate, steady, but not unnaturally slow
    await _tts.setSpeechRate(0.42);

    // Deeper pitch for narrative gravitas
    await _tts.setPitch(0.85);
    await _tts.setVolume(1.0);

    _tts.setCompletionHandler(() {
      _playNextVerse();
    });
  }

  /// Preprocess verse text so the TTS engine reads naturally:
  /// - Respects commas, semicolons, colons = short pause (via comma trick)
  /// - Respects periods, !, ? = full stop pause
  /// - Quoted speech (dialogue / God speaking / first person) gets a slight
  ///   leading pause so the listener recognises a voice shift
  /// - Parenthetical asides get a subtle double-comma pause
  String _preprocessForSpeech(String text) {
    String processed = text;

    // --- Parentheticals: slightly slower, so treat () as mid-pause sections
    processed = processed.replaceAllMapped(
      RegExp(r'\(([^)]+)\)'),
      (m) => ', ${m.group(1)}, ',
    );

    // --- Dialogue / direct speech: insert a breath before the quote
    // Matches both " " and ' ' opening quotation marks
    processed = processed.replaceAllMapped(
      RegExp(r'(?<=[.!?,:;])\s*[""]'),
      (m) => '... "',
    );

    // --- Semicolons → short pause (rendered as comma to TTS)
    processed = processed.replaceAll(';', ',');

    // --- Colons introducing a list or speech → give a breath
    processed = processed.replaceAll(':', ', ');

    // --- Em-dash → treated as a clause break (pause)
    processed = processed.replaceAll('—', ', ');
    processed = processed.replaceAll('–', ', ');

    // --- Clean up consecutive commas or spaces from above replacements
    processed = processed.replaceAll(RegExp(r',\s*,'), ',');
    processed = processed.replaceAll(RegExp(r'\s{2,}'), ' ');
    
    processed = processed.trim();

    // Ensure a clear, deep breath between individual verses.
    // If the verse doesn't end in terminating punctuation, add it.
    if (!processed.endsWith('.') && !processed.endsWith('?') && !processed.endsWith('!')) {
      processed += '.';
    }
    
    // Add artificial pauses to prevent sentences streaming into each other
    processed += ' ... ';

    return processed;
  }

  Future<void> readChapter(
    List<Map<String, String>> verses, {
    int startIndex = 0,
    String? chapterLabel,
  }) async {
    _verses = verses;
    _currentVerseIndex = startIndex;
    _isPlaying = true;
    _isPaused = false;
    
    // Announce the chapter name once before reading begins
    if (chapterLabel != null && startIndex == 0) {
      await _tts.speak(chapterLabel);
      // Wait for announcement to finish, then start verses via completionHandler
      // We'll use a flag approach — set a one-shot intro flag
      _pendingChapterStart = true;
    } else {
      await _speakCurrentVerse();
    }
  }

  bool _pendingChapterStart = false;

  Future<void> _speakCurrentVerse() async {
    if (_currentVerseIndex >= _verses.length) {
      _isPlaying = false;
      onComplete?.call();
      return;
    }

    final verse = _verses[_currentVerseIndex];
    final rawText = verse['text'] ?? '';
    final processed = _preprocessForSpeech(rawText);
    
    onVerseChanged?.call(_currentVerseIndex);
    await _tts.speak(processed);
  }

  void _playNextVerse() {
    if (_pendingChapterStart) {
      _pendingChapterStart = false;
      _speakCurrentVerse();
      return;
    }
    if (!_isPlaying || _isPaused) return;
    _currentVerseIndex++;
    _speakCurrentVerse();
  }

  Future<void> skipToVerse(int index) async {
    await _tts.stop();
    _currentVerseIndex = index;
    if (_isPlaying) {
      await _speakCurrentVerse();
    }
  }

  Future<void> pause() async {
    await _tts.pause();
    _isPaused = true;
    _isPlaying = false;
  }

  Future<void> resume() async {
    _isPaused = false;
    _isPlaying = true;
    await _speakCurrentVerse();
  }

  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
    _isPaused = false;
    _currentVerseIndex = 0;
    _verses = [];
  }

  Future<void> previous() async {
    await _tts.stop();
    if (_currentVerseIndex > 0) _currentVerseIndex--;
    if (_isPlaying) await _speakCurrentVerse();
  }

  Future<void> next() async {
    await _tts.stop();
    _currentVerseIndex++;
    if (_isPlaying) await _speakCurrentVerse();
  }
}
