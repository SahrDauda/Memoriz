import 'notification_service.dart';
import '../data/models/verse.dart';

class AlarmService {
  final NotificationService _notificationService = NotificationService();

  static const int dailyAlarmId = 1001;
  static const int wednesdayAlarmId = 2001;
  static const int thursdayAlarmId = 3001;
  static const int repeatAlarmId = 4001;

  Future<void> scheduleDailyAlarm(int hour, int minute, Verse focusVerse) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final first8Words = focusVerse.text.split(' ').take(8).join(' ');

    await _notificationService.scheduleNotification(
      id: dailyAlarmId,
      title: focusVerse.reference,
      body: first8Words,
      scheduledDate: scheduledDate,
    );
  }

  Future<void> scheduleWednesdayPrep(int hour, int minute) async {
    final now = DateTime.now();
    int daysUntilWednesday = (DateTime.wednesday - now.weekday + 7) % 7;
    if (daysUntilWednesday == 0 && now.hour >= hour) daysUntilWednesday = 7;

    final nextWednesday = DateTime(now.year, now.month, now.day, hour, minute)
        .add(Duration(days: daysUntilWednesday));

    await _notificationService.scheduleNotification(
      id: wednesdayAlarmId,
      title: "Thursday is coming",
      body: "Complete your Thursday Prep Session tonight",
      scheduledDate: nextWednesday,
    );
  }

  Future<void> scheduleThursdayMorning(int hour, int minute) async {
    final now = DateTime.now();
    int daysUntilThursday = (DateTime.thursday - now.weekday + 7) % 7;
    if (daysUntilThursday == 0 && now.hour >= hour) daysUntilThursday = 7;

    final nextThursday = DateTime(now.year, now.month, now.day, hour, minute)
        .add(Duration(days: daysUntilThursday));

    await _notificationService.scheduleNotification(
      id: thursdayAlarmId,
      title: "Today is Thursday",
      body: "You are ready. Go bless your congregation.",
      scheduledDate: nextThursday,
    );
  }

  Future<void> scheduleRepeatAlarm() async {
    // Fires 10 minutes after daily alarm if session incomplete
    // Maximum 3 fires then rest until tomorrow
    // This logic might need background tasks to check session completion, 
    // but here we just schedule one 10 mins from now.
    
    await _notificationService.scheduleNotification(
      id: repeatAlarmId,
      title: "Still waiting for you",
      body: "Your session is ready.",
      scheduledDate: DateTime.now().add(const Duration(minutes: 10)),
    );
  }

  Future<void> cancelRepeatAlarm() async {
    // Cancel the repeat alarm if session is completed
  }
}
