import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/service/notifi_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool switchValue = false;

  String? reminderHour;
  String? reminderMin;

  @override
  void initState() {
    final isReminderOn =
        PreferenceHelper.getBool(PreferenceHelper.isReminderOn);
    switchValue = isReminderOn;
    reminderHour = PreferenceHelper.getString(PreferenceHelper.reminderHour);
    reminderMin = PreferenceHelper.getString(PreferenceHelper.reminderMin);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Text('Reminder'),
            const SizedBox(height: 20),
            ListTile(
              title: Text('Meditation Habit'),
              subtitle: Text('We will remind you everyday to meditate'),
              trailing: Switch(
                  activeColor: Colors.deepPurple,
                  value: switchValue,
                  onChanged: (v) {
                    setState(() {
                      switchValue = v;
                      PreferenceHelper.setBool(
                          PreferenceHelper.isReminderOn, v);
                      if (v) {
                        setReminder(
                          int.tryParse(PreferenceHelper.getString(
                                      PreferenceHelper.reminderHour) ??
                                  '') ??
                              0,
                          int.tryParse(PreferenceHelper.getString(
                                      PreferenceHelper.reminderMin) ??
                                  '') ??
                              0,
                        );
                      } else {
                        stopReminder();
                      }
                    });
                  }),
            ),
            const SizedBox(height: 5),
            ListTile(
              onTap: () {
                _selectTime(TimeOfDay(
                    hour: int.tryParse(PreferenceHelper.getString(
                                PreferenceHelper.reminderHour) ??
                            '') ??
                        08,
                    minute: int.tryParse(PreferenceHelper.getString(
                                PreferenceHelper.reminderMin) ??
                            '') ??
                        30));
              },
              title: Text('Reminder Time'),
              subtitle: Text(TimeOfDay(
                      hour: int.tryParse(reminderHour ?? '') ?? 0,
                      minute: int.tryParse(reminderMin ?? '') ?? 0)
                  .format(context)),
            ),
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 10),
            Text('Support'),
            const SizedBox(height: 20),
            ListTile(
              onTap: () {},
              title: Text('Donate'),
              subtitle: Text('Help the app touch another million lives'),
            ),
            const SizedBox(height: 5),
            ListTile(
              onTap: () {
                AppUtils.launchInBrowser(Uri.parse('https://www.google.com'));
              },
              title: Text('Contact us'),
              subtitle: Text('Report an issue or suggest features'),
            ),
            const SizedBox(height: 5),
            ListTile(
              onTap: () {
                AppUtils.launchInBrowser(Uri.parse('https://www.google.com'));
              },
              title: Text('Legal'),
              subtitle: Text('Disclaimer and privacy policy'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(selectedTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      PreferenceHelper.setString(
          PreferenceHelper.reminderHour, pickedTime.hour.toString());
      PreferenceHelper.setString(
          PreferenceHelper.reminderMin, pickedTime.minute.toString());
      reminderHour = pickedTime.hour.toString();
      reminderMin = pickedTime.minute.toString();
      if (PreferenceHelper.getBool(PreferenceHelper.isReminderOn)) {
        setReminder(pickedTime.hour, pickedTime.minute);
      }
      setState(() {});
    }
  }

  setReminder(int hour, int min) {
    NotificationService().scheduleNotification(
        scheduledNotificationDateTime: DateTime(DateTime.now().year,
            DateTime.now().month, DateTime.now().day, hour, min));
  }

  stopReminder() {
    NotificationService().cancelNotifications();
  }
}
