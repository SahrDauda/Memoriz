import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../services/notification_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class AlarmDialog extends StatelessWidget {
  final AlarmSettings settings;

  const AlarmDialog({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        settings.notificationSettings.title,
        textAlign: TextAlign.center,
        style: AppTypography.labelMedium.copyWith(color: AppColors.primary, letterSpacing: 2),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.alarm_on, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            settings.notificationSettings.body,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () {
            NotificationService().snoozeAlarm(settings.id);
            Navigator.pop(context);
          },
          child: const Text("SNOOZE (5M)", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
          ),
          onPressed: () {
            NotificationService().stopAlarm(settings.id);
            Navigator.pop(context);
          },
          child: const Text("STOP"),
        ),
      ],
    );
  }
}
