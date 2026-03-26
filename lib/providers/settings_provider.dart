import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsState {
  final String studyTime;
  final String selectedRingtone;
  final bool remindersEnabled;

  SettingsState({
    required this.studyTime,
    required this.selectedRingtone,
    required this.remindersEnabled,
  });

  SettingsState copyWith({
    String? studyTime,
    String? selectedRingtone,
    bool? remindersEnabled,
  }) {
    return SettingsState(
      studyTime: studyTime ?? this.studyTime,
      selectedRingtone: selectedRingtone ?? this.selectedRingtone,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(
    studyTime: '07:00 AM',
    selectedRingtone: 'assets/sounds/alarm.mp3',
    remindersEnabled: true,
  )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      studyTime: prefs.getString('study_time') ?? '07:00 AM',
      selectedRingtone: prefs.getString('selected_ringtone') ?? 'assets/sounds/alarm.mp3',
      remindersEnabled: prefs.getBool('reminders_enabled') ?? true,
    );
    _scheduleNextAlarm();
  }

  Future<void> updateStudyTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('study_time', time);
    state = state.copyWith(studyTime: time);
    _scheduleNextAlarm();
  }

  Future<void> updateRingtone(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_ringtone', path);
    state = state.copyWith(selectedRingtone: path);
    _scheduleNextAlarm();
  }

  Future<void> toggleReminders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders_enabled', enabled);
    state = state.copyWith(remindersEnabled: enabled);
    if (enabled) {
      _scheduleNextAlarm();
    } else {
      NotificationService().cancelAll();
    }
  }

  Future<void> _scheduleNextAlarm() async {
    if (!state.remindersEnabled) return;

    try {
      final match = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false).firstMatch(state.studyTime);
      if (match == null) throw FormatException("Could not parse time: ${state.studyTime}");

      int hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final amPm = match.group(3)!.toUpperCase();

      if (amPm == 'PM' && hour < 12) hour += 12;
      if (amPm == 'AM' && hour == 12) hour = 0;

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
      
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      print("DEBUG: Next alarm scheduled for $scheduledDate (ID 42)");

      await NotificationService().schedulePersistentAlarm(
        id: 42,
        title: "TIME FOR MEMORIZ",
        body: "Your daily scripture session is ready.",
        scheduledTime: scheduledDate,
      );
    } catch (e) {
      print("ERROR: Failed to schedule alarm: $e");
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
