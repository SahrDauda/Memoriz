import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/verse_repository.dart';
import '../services/notification_service.dart';
import 'session_provider.dart';

final intervalNotificationProvider = Provider((ref) {
  return IntervalNotificationNotifier(ref.watch(verseRepositoryProvider));
});

class IntervalNotificationNotifier {
  final VerseRepository _repository;

  IntervalNotificationNotifier(this._repository);

  Future<void> scheduleDailyIntervals() async {
    final allVerses = await _repository.getAllVerses();
    if (allVerses.isEmpty) return;

    // Pick 3 random verses for the day
    final shuffled = List.of(allVerses)..shuffle();
    final selection = shuffled.take(3).map((v) => "${v.reference}: ${v.text}").toList();

    await NotificationService().scheduleIntervalNotifications(verses: selection);
  }
}
