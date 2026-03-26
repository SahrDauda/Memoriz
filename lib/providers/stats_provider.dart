import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'session_provider.dart';

final statsProvider = FutureProvider((ref) async {
  final repository = ref.watch(verseRepositoryProvider);
  return repository.getMasteryStats();
});

final overallMasteryProvider = FutureProvider((ref) async {
  final repository = ref.watch(verseRepositoryProvider);
  return repository.getOverallMasteryPercentage();
});

final allVersesProvider = FutureProvider((ref) async {
  final repository = ref.watch(verseRepositoryProvider);
  return repository.getAllVerses();
});

final pendingVersesCountProvider = FutureProvider((ref) async {
  final repository = ref.watch(verseRepositoryProvider);
  final session = await repository.getVersesForTodaySession();
  return session.length;
});
