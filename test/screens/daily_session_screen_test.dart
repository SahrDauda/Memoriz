import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoriz/app.dart';
import 'package:memoriz/providers/session_provider.dart';
import 'package:memoriz/data/models/verse.dart';
import 'package:memoriz/data/repositories/verse_repository.dart';

class FakeVerseRepository implements VerseRepository {
  @override
  Future<List<Verse>> getAllVerses() async => [];
  @override
  Future<Verse?> getVerseById(int id) async => null;
  @override
  Future<int> insertVerse(Verse verse) async => 1;
  @override
  Future<int> updateVerse(Verse verse) async => 1;
  @override
  Future<List<Verse>> getWeakestVerses(int limit) async => [];
  @override
  Future<List<Verse>> getOverdueVerses() async => [];
  @override
  Future<List<Verse>> getVersesForTodaySession() async {
    return [
      Verse(id: 1, reference: "John 3:16", book: "John", text: "For God so loved the world...", familiarityScore: 0),
      Verse(id: 2, reference: "Psalm 23:1", book: "Psalms", text: "The Lord is my shepherd...", familiarityScore: 0),
    ];
  }

  @override
  Future<List<Verse>> getRandomVerses(int count) async => [];

  @override
  Future<Map<String, int>> getMasteryStats() async => {
    'confident': 0,
    'inProgress': 0,
    'untouched': 0,
    'total': 0,
  };

  @override
  Future<double> getOverallMasteryPercentage() async => 0.0;
}

void main() {
  testWidgets('DailySessionScreen flow test', (tester) async {
    final fakeRepo = FakeVerseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          verseRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const ScriptureMemorizerApp(),
      ),
    );

    // Initial loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500)); 

    // Verify first verse is shown (reference only)
    expect(find.textContaining("VERSE 1 OF 2"), findsOneWidget);
    expect(find.text("John 3:16"), findsOneWidget);
    expect(find.text("REVEAL VERSE"), findsOneWidget);

    // Tap reveal
    await tester.tap(find.text("REVEAL VERSE"));
    await tester.pumpAndSettle();

    // Verify verse text and rating buttons appear
    expect(find.text("For God so loved the world..."), findsOneWidget);
    expect(find.text("Got It"), findsOneWidget);

    // Tap Got It (next verse)
    await tester.tap(find.text("Got It"));
    await tester.pumpAndSettle();

    // Verify next verse
    expect(find.textContaining("VERSE 2 OF 2"), findsOneWidget);
    expect(find.text("Psalm 23:1"), findsOneWidget);
  });
}
