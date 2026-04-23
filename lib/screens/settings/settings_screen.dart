import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../providers/bible_provider.dart';
import '../../data/database/database_helper.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "VOWS & SETTINGS",
          style: AppTypography.displayMedium.copyWith(letterSpacing: 4),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/bg_water.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceDim),
          ),
          // Dark Gradient Overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                _buildSettingsSection(
                  title: "DISCIPLINE",
                  children: [
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
                    const Divider(color: Colors.white10, indent: 48),
                    _buildSettingsTile(
                      "Selected Ringtone",
                      settings.selectedRingtone.split('/').last,
                      Icons.music_note,
                      onTap: () {
                        _showRingtonePicker(context, ref);
                      },
                    ),
                    const Divider(color: Colors.white10, indent: 48),
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
                  ],
                ),
                const SizedBox(height: 32),
                _buildSettingsSection(
                  title: "NOTIFICATIONS",
                  children: [
                    SwitchListTile(
                      value: settings.remindersEnabled,
                      onChanged: (v) => settingsNotifier.toggleReminders(v),
                      title: Text("Daily Reminders", style: AppTypography.bodySmall),
                      activeColor: AppColors.primary,
                      inactiveTrackColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    const Divider(color: Colors.white10, indent: 16, endIndent: 16),
                    SwitchListTile(
                      value: settings.wednesdayPrepEnabled,
                      onChanged: (v) => settingsNotifier.toggleWednesdayPrep(v),
                      title: Text("Wednesday Prep Alerts", style: AppTypography.bodySmall),
                      activeColor: AppColors.primary,
                      inactiveTrackColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    const Divider(color: Colors.white10, indent: 16, endIndent: 16),
                    SwitchListTile(
                      value: settings.thursdayEncouragementEnabled,
                      onChanged: (v) => settingsNotifier.toggleThursdayEncouragement(v),
                      title: Text("Thursday Encouragement", style: AppTypography.bodySmall),
                      activeColor: AppColors.primary,
                      inactiveTrackColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSettingsSection(
                  title: "DATA & LEGACY",
                  children: [
                    _buildSettingsTile(
                      "Export Progress",
                      "Save your legacy",
                      Icons.file_upload,
                    ),
                    const Divider(color: Colors.white10, indent: 48),
                    _buildSettingsTile(
                      "Reset All Progress",
                      "Start from the beginning",
                      Icons.refresh,
                      isDestructive: true,
                      onTap: () => _showResetConfirmation(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("WIPE ALL PROGRESS?", 
            style: AppTypography.labelMedium.copyWith(color: AppColors.primary, letterSpacing: 2)),
          content: Text(
            "This will delete all your mastery data, settings, and vows. This action cannot be undone.",
            style: AppTypography.bodySmall.copyWith(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("REMAIN", style: AppTypography.labelSmall.copyWith(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                final settingsNotifier = ref.read(settingsProvider.notifier);
                await settingsNotifier.resetAllSettings();
                await DatabaseHelper().resetAllVerses();
                ref.read(bibleProvider.notifier).reset();
                
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacementNamed('/splash');
                }
              },
              child: Text("PURGE", style: AppTypography.labelSmall.copyWith(color: AppColors.error)),
            ),
          ],
        ),
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
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceDim.withOpacity(0.9),
                  AppColors.surfaceMedium.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
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

  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            title,
            style: AppTypography.labelMedium.copyWith(color: AppColors.primary, letterSpacing: 2),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Column(
                children: children,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, IconData icon, {VoidCallback? onTap, bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.onSurface.withOpacity(0.7)),
      ),
      title: Text(title, style: AppTypography.bodySmall.copyWith(color: isDestructive ? AppColors.error : AppColors.onSurface)),
      subtitle: Text(subtitle, style: AppTypography.labelSmall.copyWith(fontSize: 10, color: Colors.white54)),
      trailing: const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Icon(Icons.chevron_right, size: 16, color: Colors.white54),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
