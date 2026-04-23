import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static const MethodChannel _timezoneChannel = MethodChannel('com.example.memoriz/timezone');
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  String? _lastPayload;
  final _onNotificationTap = StreamController<String?>.broadcast();
  Stream<String?> get onNotificationTap => _onNotificationTap.stream;

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final String? timeZoneName = await _timezoneChannel.invokeMethod('getNativeTimezone');
      if (timeZoneName != null) {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      }
    } catch (e) {
      // Fallback to UTC or guess if needed, but native should work
    }
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print("DEBUG: Notification tapped. Payload: ${details.payload}");
        if (details.payload != null) {
          _lastPayload = details.payload;
          _onNotificationTap.add(details.payload);
        }
      },
    );

    // Give the system a moment to settle before checking initial launch
    await Future.delayed(const Duration(milliseconds: 200));
    await handleInitialLaunch();

    // Request permissions for Android 13+ and Exact Alarms
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    
    // Explicitly check for exact alarm permission for Android 12+
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> handleInitialLaunch() async {
    try {
      final details = await _notificationsPlugin.getNotificationAppLaunchDetails();
      print("DEBUG: handleInitialLaunch. Details: $details, didLaunch: ${details?.didNotificationLaunchApp}");
      if (details != null && details.didNotificationLaunchApp && details.notificationResponse?.payload != null) {
        _lastPayload = details.notificationResponse!.payload;
        print("DEBUG: Set initial launch payload: $_lastPayload");
      }
    } catch (e) {
      print("ERROR in handleInitialLaunch: $e");
    }
  }

  String? consumePayload() {
    final payload = _lastPayload;
    _lastPayload = null;
    return payload;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'study_alarms',
      'Study Alarms',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(id, title, body, platformDetails, payload: payload);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Defensive check for past scheduling
    if (scheduledDate.isBefore(DateTime.now())) {
        return;
    }

    try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'scheduled_alarms_v2', // New channel ID for fresh start
              'Scheduled Alarms',
              channelDescription: 'Bible verse notifications',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
            ),
            iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
    } catch (e) {
        print("ERROR: Could not schedule notification: $e");
    }
  }

  Future<void> schedulePersistentAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final ringtonePath = prefs.getString('selected_ringtone') ?? 'assets/sounds/alarm.mp3';

    print("DEBUG: Scheduling persistent alarm at $scheduledTime with ringtone $ringtonePath");

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: scheduledTime,
      assetAudioPath: ringtonePath,
      loopAudio: true,
      vibrate: true,
      fadeDuration: 3.0,
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'STOP',
        icon: 'ic_launcher',
      ),
      androidFullScreenIntent: true,
    );

    try {
      final success = await Alarm.set(alarmSettings: alarmSettings);
      print("DEBUG: Alarm.set returned $success for ID $id");
    } catch (e) {
      print("ERROR: Alarm.set threw exception: $e");
    }
  }

  Future<void> stopAlarm(int id) async {
    await Alarm.stop(id);
  }

  Future<void> snoozeAlarm(int id, {int minutes = 5}) async {
    final alarm = await Alarm.getAlarm(id);
    if (alarm != null) {
      await Alarm.stop(id);
      final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
      final newAlarmSettings = alarm.copyWith(
        dateTime: snoozeTime,
      );
      await Alarm.set(alarmSettings: newAlarmSettings);
    }
  }

  Future<void> scheduleIntervalNotifications({
    required List<String> verses,
  }) async {
    // Schedule 8 notifications (every 3 hours for 24 hours)
    final now = DateTime.now();
    final random = math.Random();

    for (int i = 1; i <= 8; i++) {
        final scheduledTime = now.add(Duration(hours: i * 3));
        
        // Pick 3 random verses
        final selection = <String>[];
        if (verses.isNotEmpty) {
            for (int j = 0; j < 3; j++) {
                selection.add(verses[random.nextInt(verses.length)]);
            }
        }

        final body = selection.join("\n");
        final payload = body; // Pass the entire body for the Home Screen modal

        await scheduleNotification(
            id: 1000 + i,
            title: "Daily Bread",
            body: body,
            scheduledDate: scheduledTime,
            payload: payload,
        );
    }
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    final alarms = await Alarm.getAlarms();
    for (final alarm in alarms) {
      await Alarm.stop(alarm.id);
    }
  }
}
