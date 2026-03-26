import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'widgets/alarm_dialog.dart';

import 'package:alarm/alarm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  await NotificationService().init();

  // Listen for alarm ringing to show in-app UI
  Alarm.ringStream.stream.listen((settings) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlarmDialog(settings: settings),
      );
    }
  });

  runApp(
    const ProviderScope(
      child: ScriptureMemorizerApp(),
    ),
  );
}
