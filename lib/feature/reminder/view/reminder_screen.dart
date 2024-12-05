import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/icon_path.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/reminder/model/reminder_model.dart';
import 'package:meditationapp/feature/reminder/view/set_reminder_screen.dart';
import 'package:meditationapp/service/notifi_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<bool> selectedDays = List.filled(7, false);
  List<ReminderModel> reminders = [];

  ReminderModel? reminderModel;

  Future<List<ReminderModel>> getSavedReminders() async {
    // Get the reminders list from SharedPreferences
    List<String>? remindersList = PreferenceHelper.getStringList("reminder");
    print("remindersList: $remindersList");

    try {
      List<ReminderModel> reminders = remindersList.map((element) {
        // Decode JSON
        var decodedJson = jsonDecode(element);
        print("decodedJson: $decodedJson");

        // Create ReminderModel from JSON
        ReminderModel reminderModel = ReminderModel.fromJson(decodedJson);
        print("reminderModel isReminderOn: ${reminderModel.isReminderOn}");
        print("reminderModel selectedDays: ${reminderModel.selectedDays}");
        print("reminderModel reminderTime: ${reminderModel.reminderTime}");

        // Map `selectedDays` to a list of booleans (ensure valid values)
        List<bool> selectedDays =
            (reminderModel.selectedDays ?? []).map((e) => e == true).toList();
        print("selectedDays: $selectedDays");

        // Return the updated ReminderModel
        return ReminderModel(
          reminderTime: reminderModel.reminderTime,
          isReminderOn: reminderModel.isReminderOn,
          selectedDays: selectedDays,
        );
      }).toList();

      return reminders;
    } catch (e) {
      print("Error while parsing reminders: $e");
      return [];
    }
    // return reminders;
  }

  Future<void> _loadReminders() async {
    List<ReminderModel> loadedReminders = await getSavedReminders();
    setState(() {
      reminders = loadedReminders;
    });
  }

  Future<void> toggleReminder(int index, bool value) async {
    // Toggle the isReminderOn property of the selected reminder
    reminders[index].isReminderOn = value;

    List<String> serializedReminders =
        reminders.map((reminder) => jsonEncode(reminder.toJson())).toList();

    // Save the serialized reminders list to SharedPreferences
    await PreferenceHelper.setStringList('reminder', serializedReminders);
    if (value == false) {
      print("index$index");
      NotificationService().cancelNotifications(index + 1);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetReminderScreen(
              index: index,
            ),
          )).then(
        (value) {
          _loadReminders();
        },
      );
    }
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
        leading: AppUtils.backButton(
            onTap: () {
              Navigator.pop(context);
            },
            color: AppColors.blackColor
        ), /*GestureDetector(
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
        ),*/
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
                    builder: (context) => SetReminderScreen(
                      index: null,
                    ),
                  )).then(
                (value) {
                  _loadReminders();
                },
              );
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
                Center(child: Image.asset(bellIcon)),
                const SizedBox(height: 10),
                AppUtils.commonTextWidget(
                  text: "No reminders found!",
                  textColor: AppColors.blackColor,
                ),
              ],
            )
          : ListView.builder(
              itemCount: reminders.length,
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              itemBuilder: (context, index) {
                ReminderModel reminder = reminders[index];
                // DateTime reminderTime = DateTime.parse(reminder.reminderTime ?? "");

                List<bool> reminderDays =
                    List<bool>.from(reminder.selectedDays ?? []);
                bool isReminderOn = reminder.isReminderOn ?? true;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetReminderScreen(
                            index: index,
                          ),
                        )).then(
                      (value) {
                        _loadReminders();
                      },
                    );
                  },
                  child: AppUtils.commonContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        left: 16, top: 8, bottom: 8, right: 16),
                    margin: const EdgeInsets.only(bottom: 10),
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
                                text: DateFormat("h:mm a").format(DateTime.parse(
                                    "2000-01-01T${reminder.reminderTime?.replaceAll(" ", "").replaceAll("AM", "").replaceAll("PM", "")}")),
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
                        const SizedBox(height: 8),
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
