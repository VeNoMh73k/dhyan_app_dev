import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/home/view/home_screen.dart';
import 'package:meditationapp/feature/reminder/view/set_reminder_screen.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<bool> selectedDays = List.filled(7, false);
  List<Map<String, dynamic>> reminders = [];

  Future<List<Map<String, dynamic>>> getSavedReminders() async {
    List<String> savedReminders = PreferenceHelper.getStringList('reminders') ?? [];

    return savedReminders.map((reminder) {
      Map<String, dynamic> reminderMap = jsonDecode(reminder);

      List<bool> selectedDays = reminderMap['selectedDays']
          .map<bool>((day) => day == 'true')
          .toList();
      List<String> timeParts = reminderMap['selectedTime'].split(':');

      DateTime selectedTime = DateTime(
        2024,
        1,
        1,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      return {
        'selectedDays': selectedDays,
        'selectedTime': selectedTime,
        'isReminderOn': reminderMap['isReminderOn'] ?? true, // Default to true if missing
      };
    }).toList();
  }


  Future<void> _loadReminders() async {
    List<Map<String, dynamic>> loadedReminders = await getSavedReminders();
    setState(() {
      reminders = loadedReminders;
    });
  }


  Future<void> toggleReminder(int index, bool value) async {
    reminders[index]['isReminderOn'] = value;

    // Serialize DateTime as a string before saving
    List<String> serializedReminders = reminders.map((r) {
      return jsonEncode({
        'selectedDays': r['selectedDays'],
        'selectedTime': (r['selectedTime'] as DateTime).toIso8601String(),
        'isReminderOn': r['isReminderOn'],
      });
    }).toList();

    await PreferenceHelper.setStringList('reminders', serializedReminders);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadReminders();
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
          text: "Reminder",
          textColor: AppColors.blackColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              //Navigate to reminder screen
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  SetReminderScreen(index: null,),
                  )).then((value) {
                _loadReminders();
                  },);
            },
            child: AppUtils.commonContainer(
                margin: EdgeInsets.only(right: 16),
                height: 30,
                width: 30,
                decoration: AppUtils.commonBoxDecoration(
                  color: getPrimaryColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add)),
          )
        ],
      ),
      body: reminders.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Image.asset('assets/bell_icon.png')),
                const SizedBox(height: 10),
                AppUtils.commonTextWidget(
                  text: "No reminders found!",
                  textColor: AppColors.blackColor,
                ),
              ],
            )
          : ListView.builder(
              itemCount: reminders.length,
              padding: EdgeInsets.only(left: 10, right: 10,top: 10,bottom: 10),
              itemBuilder: (context, index) {
                Map<String, dynamic> reminder = reminders[index];
                DateTime reminderTime = reminder['selectedTime'];
                List<bool> reminderDays =
                    List<bool>.from(reminder['selectedDays']);
                bool isReminderOn = reminder['isReminderOn'] ?? true;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  SetReminderScreen(index: index,),
                        )).then((value) {
                      _loadReminders();
                    },);
                  },
                  child: AppUtils.commonContainer(
                    width: double.infinity,
                    padding:
                        EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 16),
                    margin: EdgeInsets.only(bottom: 10 ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppUtils.commonTextWidget(
                                text: AppUtils.getDate(
                                    date: reminderTime.toString(),
                                    format: "HH:mm a"),
                                textColor: AppColors.blackColor,
                                letterSpacing: 0,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                            CupertinoSwitch(
                              activeColor: getPrimaryColor(),
                              value: isReminderOn,
                              onChanged: (value) async {
                                setState(() {
                                  isReminderOn = value;
                                });
                                await toggleReminder(index, value);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(days.length, (index) {
                              bool isSelected = reminderDays[index];

                              return AppUtils.commonContainer(
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
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
