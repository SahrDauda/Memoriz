import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int selectedIndex;
  final String? targetVerseReference;
  final String? deepLinkVerseContent;

  NavigationState({
    this.selectedIndex = 0,
    this.targetVerseReference,
    this.deepLinkVerseContent,
  });

  NavigationState copyWith({
    int? selectedIndex,
    String? targetVerseReference,
    String? deepLinkVerseContent,
  }) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      targetVerseReference: targetVerseReference ?? this.targetVerseReference,
      deepLinkVerseContent: deepLinkVerseContent ?? this.deepLinkVerseContent,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index, targetVerseReference: null, deepLinkVerseContent: null);
  }

  void navigateToVerse(String payload) {
    // We now land on Home (0) and show a modal for the verse
    state = state.copyWith(
      selectedIndex: 0, 
      deepLinkVerseContent: payload,
    );
  }

  void clearTargetVerse() {
    state = state.copyWith(targetVerseReference: null, deepLinkVerseContent: null);
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
