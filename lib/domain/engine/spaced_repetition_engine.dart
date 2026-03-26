import '../../data/models/verse.dart';

enum Rating { struggling, almostThere, gotIt }

class SpacedRepetitionEngine {
  // Review intervals by familiarity score
  static const Map<int, int> intervals = {
    0: 1,
    1: 2,
    2: 5,
    3: 10,
    4: 21,
    5: 30,
  };

  static Verse applyRating(Verse verse, Rating rating, {DateTime? customNow}) {
    DateTime now = customNow ?? DateTime.now();
    int newScore = verse.familiarityScore;
    int newConsecutiveCorrect = verse.consecutiveCorrect;
    int newTimesStruggled = verse.timesStruggled;
    DateTime nextReview;

    switch (rating) {
      case Rating.struggling:
        newScore = 0;
        newConsecutiveCorrect = 0;
        newTimesStruggled++;
        nextReview = now.add(const Duration(days: 1));
        break;
      case Rating.almostThere:
        // familiarityScore unchanged
        newConsecutiveCorrect = 0;
        nextReview = now.add(const Duration(days: 2));
        break;
      case Rating.gotIt:
        newScore = (verse.familiarityScore + 1).clamp(0, 5);
        newConsecutiveCorrect++;
        nextReview = now.add(Duration(days: intervals[newScore] ?? 1));
        break;
    }

    return verse.copyWith(
      familiarityScore: newScore,
      consecutiveCorrect: newConsecutiveCorrect,
      timesStruggled: newTimesStruggled,
      lastReviewed: now,
      nextReviewDue: nextReview,
    );
  }

  // Score decay rule
  // If today > nextReviewDue * 1.5, reduce familiarityScore by 1 (minimum 0)
  static List<Verse> applyScoreDecay(List<Verse> allVerses, {DateTime? customNow}) {
    DateTime now = customNow ?? DateTime.now();
    return allVerses.map((verse) {
      if (verse.lastReviewed != null && verse.nextReviewDue != null) {
        final intervalDays = verse.nextReviewDue!.difference(verse.lastReviewed!).inDays;
        final decayThreshold = verse.lastReviewed!.add(Duration(days: (intervalDays * 1.5).toInt()));
        
        if (now.isAfter(decayThreshold)) {
          return verse.copyWith(
            familiarityScore: (verse.familiarityScore - 1).clamp(0, 5),
            // Reset dates potentially? The spec says "reduce familiarityScore by 1"
          );
        }
      }
      return verse;
    }).toList();
  }
}
