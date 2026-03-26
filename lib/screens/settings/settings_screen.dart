import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      appBar: AppBar(
        title: const Text("VOWS & SETTINGS", style: TextStyle(letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSettingsSection("DISCIPLINE"),
          _buildSettingsTile(
            "Daily Study Time",
            settings.studyTime,
            Icons.alarm,
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 7, minute: 0),
              );
              if (time != null) {
                settingsNotifier.updateStudyTime(time.format(context));
              }
            },
          ),
          _buildSettingsTile(
            "Selected Ringtone",
            settings.selectedRingtone.split('/').last,
            Icons.music_note,
            onTap: () {
              _showRingtonePicker(context, ref);
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            "Rering Now (10s)",
            "Verify the engine is still alive",
            Icons.timer,
            onTap: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await NotificationService().schedulePersistentAlarm(
                id: 88,
                title: "RERING TEST",
                body: "Testing if the engine is still alive.",
                scheduledTime: DateTime.now().add(const Duration(seconds: 10)),
              );
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text("Test alarm scheduled for 10 seconds.")),
              );
            },
          ),
          const SizedBox(height: 32),
          _buildSettingsSection("NOTIFICATIONS"),
          SwitchListTile(
            value: settings.remindersEnabled,
            onChanged: (v) => settingsNotifier.toggleReminders(v),
            title: Text("Daily Reminders", style: AppTypography.bodySmall),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            value: true,
            onChanged: (v) {},
            title: Text("Wednesday Prep Alerts", style: AppTypography.bodySmall),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            value: true,
            onChanged: (v) {},
            title: Text("Thursday Encouragement", style: AppTypography.bodySmall),
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 48),
          _buildSettingsSection("DATA"),
          _buildSettingsTile(
            "Export Progress",
            "Save your legacy",
            Icons.file_upload,
          ),
          _buildSettingsTile(
            "Reset All Progress",
            "Start from the beginning",
            Icons.refresh,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  void _showRingtonePicker(BuildContext context, WidgetRef ref) {
    final ringtones = [
      {'name': 'Shofar Blast', 'path': 'assets/sounds/shofar.mp3'},
      {'name': 'Temple Bell', 'path': 'assets/sounds/bell.mp3'},
      {'name': 'Angelic Harp', 'path': 'assets/sounds/harp.mp3'},
      {'name': 'System Default', 'path': 'assets/sounds/alarm.mp3'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceMedium,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SELECT RINGTONE", style: AppTypography.labelMedium.copyWith(color: AppColors.primary, letterSpacing: 2)),
            const SizedBox(height: 16),
            ...ringtones.map((r) => ListTile(
              title: Text(r['name']!, style: AppTypography.bodySmall),
              trailing: ref.watch(settingsProvider).selectedRingtone == r['path'] 
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
              onTap: () {
                _previewAndSetRingtone(ref, r['path']!, context);
                Navigator.pop(context);
              },
            )),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.add, color: AppColors.primary),
              title: Text("Pick Custom Audio", style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
              onTap: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final status = await Permission.mediaLibrary.request(); // Android 13+
                final storageStatus = await Permission.storage.request(); // Android < 13
                
                if (status.isGranted || storageStatus.isGranted || await Permission.audio.request().isGranted) {
                  try {
                    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
                    if (result != null && result.files.single.path != null) {
                      _previewAndSetRingtone(ref, result.files.single.path!, context);
                    }
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(SnackBar(content: Text("Error picking file: $e")));
                  }
                } else {
                  scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Storage permission denied")));
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _previewAndSetRingtone(WidgetRef ref, String path, BuildContext context) async {
    final player = AudioPlayer();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      if (path.startsWith('assets/')) {
        await player.play(AssetSource(path.replaceFirst('assets/', '')));
      } else {
        await player.play(DeviceFileSource(path));
      }
      ref.read(settingsProvider.notifier).updateRingtone(path);
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Ringtone set and previewing..."), duration: Duration(seconds: 2)));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("Error playing preview: $e")));
    }
  }

  Widget _buildSettingsSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(color: AppColors.primary, letterSpacing: 2),
      ),
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, IconData icon, {VoidCallback? onTap, bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.onSurface.withOpacity(0.5)),
      title: Text(title, style: AppTypography.bodySmall.copyWith(color: isDestructive ? AppColors.error : AppColors.onSurface)),
      subtitle: Text(subtitle, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
      trailing: const Icon(Icons.chevron_right, size: 16),
      contentPadding: EdgeInsets.zero,
    );
  }
}
