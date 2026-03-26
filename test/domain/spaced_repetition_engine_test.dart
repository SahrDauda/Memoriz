import 'package:flutter_test/flutter_test.dart';
import 'package:memoriz/data/models/verse.dart';
import 'package:memoriz/domain/engine/spaced_repetition_engine.dart';

void main() {
  group('SpacedRepetitionEngine Tests', () {
    late Verse testVerse;

    setUp(() {
      testVerse = Verse(
        id: 1,
        reference: "John 3:16",
        book: "John",
        text: "For God so loved the world...",
        familiarityScore: 0,
        consecutiveCorrect: 0,
        timesStruggled: 0,
      );
    });

    test('Rating.struggling resets score and increments timesStruggled', () {
      testVerse = testVerse.copyWith(familiarityScore: 3, consecutiveCorrect: 2);
      final result = SpacedRepetitionEngine.applyRating(testVerse, Rating.struggling);
      
      expect(result.familiarityScore, 0);
      expect(result.consecutiveCorrect, 0);
      expect(result.timesStruggled, 1);
      expect(result.nextReviewDue != null, true);
    });

    test('Rating.almostThere keeps score and resets consecutiveCorrect', () {
      testVerse = testVerse.copyWith(familiarityScore: 3, consecutiveCorrect: 2);
      final result = SpacedRepetitionEngine.applyRating(testVerse, Rating.almostThere);
      
      expect(result.familiarityScore, 3);
      expect(result.consecutiveCorrect, 0);
      expect(result.nextReviewDue != null, true);
    });

    test('Rating.gotIt increases score and consecutiveCorrect', () {
      testVerse = testVerse.copyWith(familiarityScore: 2, consecutiveCorrect: 1);
      final result = SpacedRepetitionEngine.applyRating(testVerse, Rating.gotIt);
      
      expect(result.familiarityScore, 3);
      expect(result.consecutiveCorrect, 2);
      expect(result.nextReviewDue != null, true);
    });

    test('Score decay applies correctly when past 1.5x interval', () {
      final now = DateTime.now();
      final lastReviewed = now.subtract(const Duration(days: 20));
      final nextReviewDue = now.subtract(const Duration(days: 10)); 
      // Interval = 10 days. 1.5x = 15 days. 
      // Today (now) is 20 days since lastReviewed. 20 > 15, so decay should happen.

      final verse = testVerse.copyWith(
        familiarityScore: 4,
        lastReviewed: lastReviewed,
        nextReviewDue: nextReviewDue,
      );

      final results = SpacedRepetitionEngine.applyScoreDecay([verse], customNow: now);
      expect(results.first.familiarityScore, 3);
    });

    test('Score decay does not apply when within 1.5x interval', () {
      final now = DateTime.now();
      final lastReviewed = now.subtract(const Duration(days: 12));
      final nextReviewDue = now.subtract(const Duration(days: 2)); 
      // Interval = 10 days. 1.5x = 15 days.
      // Today (now) is 12 days since lastReviewed. 12 < 15, so no decay.

      final verse = testVerse.copyWith(
        familiarityScore: 4,
        lastReviewed: lastReviewed,
        nextReviewDue: nextReviewDue,
      );

      final results = SpacedRepetitionEngine.applyScoreDecay([verse], customNow: now);
      expect(results.first.familiarityScore, 4);
    });
  });
}
