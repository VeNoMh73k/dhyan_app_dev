import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/service/notifi_service.dart';

class SetReminderScreen extends StatefulWidget {
  const SetReminderScreen({super.key});

  @override
  State<SetReminderScreen> createState() => _SetReminderScreenState();
}

class _SetReminderScreenState extends State<SetReminderScreen> {
  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<bool> selectedDays = List.filled(7, false);
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> showTimePickerDialog() async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.dialOnly,
      helpText: "Set Reminder Time",
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return TimePickerTheme(
          data: TimePickerThemeData(
            elevation: 15,
            backgroundColor: AppColors.whiteColor,
            hourMinuteColor: AppColors.whiteThemeBackgroundColor,
            hourMinuteTextColor: AppColors.primaryColor,
            dialBackgroundColor: AppColors.greyColor,
            dayPeriodColor: AppColors.whiteThemeBackgroundColor,
            dayPeriodTextColor: AppColors.primaryColor,
            dialHandColor: AppColors.primaryColor,
            dialTextColor: AppColors.blackColor,
            helpTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.blackColor,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime; // Update the selected time
      });
    }
  }

  Future<void> saveReminderData(
      List<bool> selectedDays, TimeOfDay selectedTime) async {
    List<Map<String, dynamic>> reminders =
        PreferenceHelper.getStringList('reminders').map((reminder) {
              return Map<String, dynamic>.from(jsonDecode(reminder));
            }).toList() ??
            [];

    String timeString = '${selectedTime.hour}:${selectedTime.minute}';

    reminders.add({
      'selectedDays': selectedDays.map((e) => e.toString()).toList(),
      'selectedTime': timeString,
    });

    List<String> serializedReminders =
        reminders.map((r) => jsonEncode(r)).toList();
    await PreferenceHelper.setStringList('reminders', serializedReminders);
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> scheduleNotification(
      int hour, int minute, List<bool> selectedDays) async {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      if (selectedDays[i]) {
        // Calculate the date for the selected day (i.e., Monday, Tuesday, etc.)
        int dayDifference = (i - now.weekday + 7) % 7;
        DateTime scheduledDate = now.add(Duration(days: dayDifference));
        scheduledDate = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          hour,
          minute,
        );

        setReminder(hour, minute,i);
      }
    }
  }

  setReminder(int hour, int min,int i) {
    DateTime now = DateTime.now();
    // Ensure you're using the passed `hour` and `min` values
    DateTime selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      min,
    );

    // Call the NotificationService to schedule the notification
    NotificationService().scheduleNotification(
      selectedDays: selectedDays,
      id: i,
      selectedTime: selectedDateTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        surfaceTintColor: getScaffoldColor(),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: AppUtils.commonContainer(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.blackColor,
            ),
          ),
        ),
        title: AppUtils.commonTextWidget(
          text: "Set Reminder",
          textColor: AppColors.blackColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
            child: Column(
              children: [
                AppUtils.commonContainer(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: AppUtils.commonBoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackColor.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppUtils.commonTextWidget(
                              text: "Select Time",
                              textColor: AppColors.blackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          AppUtils.commonTextWidget(
                              text:
                                  "${selectedTime.hourOfPeriod}:${selectedTime.minute} ${selectedTime.period.name.toUpperCase()}"),
                        ],
                      ),
                      InkWell(
                        onTap: showTimePickerDialog,
                        child: Image.asset(
                          "assets/bell_icon.png",
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                AppUtils.commonContainer(
                  width: double.infinity,
                  padding:
                      EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 16),
                  decoration: AppUtils.commonBoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackColor.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppUtils.commonTextWidget(
                          text: "Select Day",
                          textColor: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(days.length, (index) {
                            bool isSelected = selectedDays[index];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDays[index] =
                                      !selectedDays[index]; // Toggle selection
                                });
                              },
                              child: AppUtils.commonContainer(
                                height: 30,
                                width: 40,
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                decoration: AppUtils.commonBoxDecoration(
                                  color: isSelected
                                      ? getPrimaryColor()
                                      : AppColors.greyColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: AppUtils.commonTextWidget(
                                  text: days[index],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  textColor: AppColors.blackColor,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 16),
                      child: OutlinedButton(
                        onPressed: () {
                          // Add your action when the OutlinedButton is pressed
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(color: AppColors.greyColor)),
                        ),
                        child: AppUtils.commonTextWidget(
                          text: "Cancel",
                          textColor: AppColors.blackColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: AppUtils.commonElevatedButton(
                          backgroundColor: getPrimaryColor(),
                          text: "Save",
                          textColor: AppColors.blackColor,
                          onPressed: () async {
                            await saveReminderData(selectedDays, selectedTime);

                            await scheduleNotification(
                                selectedTime.hourOfPeriod,
                                selectedTime.minute,
                                selectedDays);

                            // Optionally, show a confirmation message or navigate
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Reminder Set!')));
                            Navigator.pop(context);
                          },
                          leftMargin: 10,
                          rightMargin: 16
                          // buttonWidth: 300
                          ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
