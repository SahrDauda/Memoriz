import '../database/database_helper.dart';
import '../models/verse.dart';

class VerseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Verse>> getAllVerses() => _dbHelper.getAllVerses();

  Future<Verse?> getVerseById(int id) => _dbHelper.getVerseById(id);

  Future<int> insertVerse(Verse verse) => _dbHelper.insertVerse(verse);

  Future<int> updateVerse(Verse verse) => _dbHelper.updateVerse(verse);

  Future<List<Verse>> getWeakestVerses(int limit) => _dbHelper.getWeakestVerses(limit);

  Future<List<Verse>> getOverdueVerses() => _dbHelper.getOverdueVerses();

  Future<List<Verse>> getVersesForTodaySession() async {
    // Composition rules:
    // Slot A: 3 verses - lowest familiarityScore, due today or overdue
    // Slot B: 4 verses - familiarityScore 2–3, due for review today
    // Slot C: 3 verses - familiarityScore 4–5, scheduled maintenance

    List<Verse> sessionVerses = [];
    
    // Get all active verses to work with
    List<Verse> allVerses = await _dbHelper.getAllVerses();
    allVerses = allVerses.where((v) => v.isActive).toList();

    DateTime now = DateTime.now();

    // Categorize
    List<Verse> slotAItems = allVerses.where((v) => 
      v.familiarityScore <= 1 && (v.nextReviewDue == null || v.nextReviewDue!.isBefore(now) || v.nextReviewDue!.isAtSameMomentAs(now))
    ).toList();
    slotAItems.sort((a, b) => a.familiarityScore.compareTo(b.familiarityScore));

    List<Verse> slotBItems = allVerses.where((v) => 
      (v.familiarityScore == 2 || v.familiarityScore == 3) && (v.nextReviewDue == null || v.nextReviewDue!.isBefore(now) || v.nextReviewDue!.isAtSameMomentAs(now))
    ).toList();

    List<Verse> slotCItems = allVerses.where((v) => 
      (v.familiarityScore == 4 || v.familiarityScore == 5)
    ).toList();
    // For maintenance, we might want to pick those closest to review or random
    slotCItems.sort((a, b) => (a.nextReviewDue ?? now).compareTo(b.nextReviewDue ?? now));

    // Fill Slot A (3)
    sessionVerses.addAll(slotAItems.take(3));
    
    // Fill Slot B (4)
    sessionVerses.addAll(slotBItems.take(4));

    // Fill Slot C (3)
    sessionVerses.addAll(slotCItems.take(3));

    // Rule: if not enough verses exist in a slot category,
    // pull next-most-due verses from adjacent categories
    // to always guarantee exactly 10 verses per session.
    if (sessionVerses.length < 10) {
      Set<int> currentIds = sessionVerses.map((v) => v.id!).toSet();
      List<Verse> remaining = allVerses.where((v) => !currentIds.contains(v.id)).toList();
      
      // Sort remaining by "due-ness" (distance from now)
      remaining.sort((a, b) => (a.nextReviewDue ?? now).compareTo(b.nextReviewDue ?? now));
      
      sessionVerses.addAll(remaining.take(10 - sessionVerses.length));
    }

    // Final check to ensure exactly 10 if we have at least 10 in DB
    if (sessionVerses.length > 10) {
      sessionVerses = sessionVerses.sublist(0, 10);
    }

    return sessionVerses;
  }

  Future<List<Verse>> getRandomVerses(int count) async {
    final List<Verse> allVerses = await _dbHelper.getAllVerses();
    final List<Verse> shuffled = List.from(allVerses)..shuffle();
    return shuffled.take(count).toList();
  }

  Future<Map<String, int>> getMasteryStats() async {
    final verses = await _dbHelper.getAllVerses();
    int confident = verses.where((v) => v.familiarityScore >= 4).length;
    int inProgress = verses.where((v) => v.familiarityScore >= 1 && v.familiarityScore <= 3).length;
    int untouched = verses.where((v) => v.familiarityScore == 0).length;
    return {
      'confident': confident,
      'inProgress': inProgress,
      'untouched': untouched,
      'total': verses.length,
    };
  }

  Future<double> getOverallMasteryPercentage() async {
    final verses = await _dbHelper.getAllVerses();
    if (verses.isEmpty) return 0.0;
    double totalScore = verses.fold(0, (sum, v) => sum + v.familiarityScore);
    // Familiarity score is 0-5. Max total is total * 5.
    return totalScore / (verses.length * 5);
  }
}
