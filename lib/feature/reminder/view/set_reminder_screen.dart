import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/reminder/model/reminder_model.dart';
import 'package:meditationapp/service/notifi_service.dart';
import 'package:wheel_picker/wheel_picker.dart';

class SetReminderScreen extends StatefulWidget {
  int? index;

  SetReminderScreen({super.key, this.index});

  @override
  State<SetReminderScreen> createState() => _SetReminderScreenState();
}

class _SetReminderScreenState extends State<SetReminderScreen> {
  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  late TimeOfDay selectedTime;
  List<bool> selectedDays = List.filled(7, true);

  final ValueNotifier<int> selectedHour = ValueNotifier<int>(1);
  final ValueNotifier<int> selectedMinute = ValueNotifier<int>(0);
  final ValueNotifier<String> selectedPeriod = ValueNotifier<String>('AM');

  // model
  ReminderModel? reminderModel;

  Future<void> saveReminder(List<bool> selectedDays, TimeOfDay selectedTime,
      List<int>? selectedDaysInNumbers,
      {int? index}) async {
    String hour = selectedTime.hour.toString().padLeft(2, '0') ?? "";
    String minute = selectedTime.minute.toString().padLeft(2, '0') ?? "";

    String timeOfDay = "$hour:$minute ${selectedPeriod.value}";

    reminderModel = ReminderModel(
      selectedDays: selectedDays,
      isReminderOn: true,
      reminderTime: timeOfDay.toString(),
    );

    String serializedReminder = jsonEncode(reminderModel?.toJson());

    List<String> remindersList =
        PreferenceHelper.getStringList("reminder") ?? [];

    if (widget.index != null &&
        (widget.index ?? 0) >= 0 &&
        (widget.index ?? 0) < remindersList.length) {
      remindersList[widget.index ?? 0] = serializedReminder;
      NotificationService().scheduleWeeklyNotifications(
          selectedDaysInNumbers ?? [], selectedTime, widget.index ?? 0);

    } else {
      remindersList.add(serializedReminder);
      NotificationService().scheduleWeeklyNotifications(
          selectedDaysInNumbers ?? [], selectedTime, remindersList.length);
    }

    await PreferenceHelper.setStringList("reminder", remindersList);


  }

  // Future<void> scheduleNotification(
  //     int hour, int minute, List<bool> selectedDays) async {
  //   final now = DateTime.now();
  //
  //   for (int i = 0; i < 7; i++) {
  //     if (selectedDays[i]) {
  //       int dayDifference = (i - now.weekday + 7) % 7;
  //
  //       if (dayDifference == 0) {
  //         if (hour < now.hour || (hour == now.hour && minute <= now.minute)) {
  //           dayDifference = 1; // Move to tomorrow
  //         }
  //       }
  //
  //       // Calculate the scheduled date and time
  //       DateTime scheduledDate = now.add(Duration(days: dayDifference));
  //       scheduledDate = DateTime(
  //         scheduledDate.year,
  //         scheduledDate.month,
  //         scheduledDate.day,
  //         hour,
  //         minute,
  //       );
  //
  //       // Schedule the reminder
  //       setReminder(hour, minute, i);
  //     }
  //   }
  // }

  // setReminder(int hour, int min, int i) {
  //   DateTime now = DateTime.now();
  //   // Ensure you're using the passed `hour` and `min` values
  //   DateTime selectedDateTime = DateTime(
  //     now.year,
  //     now.month,
  //     now.day,
  //     hour,
  //     min,
  //   );
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.index != null) {
      loadReminderData(widget.index!);
    }
  }

  void loadReminderData(int index) async {
    selectedHour.value = 0;
    selectedMinute.value = 0;
    List<String>? remindersList = PreferenceHelper.getStringList("reminder");
    print("remindersList: $remindersList");
    if (remindersList.isNotEmpty && index < remindersList.length) {
      ReminderModel reminder =
          ReminderModel.fromJson(jsonDecode(remindersList[index]));

      List<String> timeParts = (reminder.reminderTime ?? "").split(':');
      print("timeParts$timeParts");


      selectedHour.value = int.parse(timeParts[0]);


      List<String> minutes = (timeParts[1]).split(' ');
      selectedMinute.value = int.parse(minutes[0]);
      selectedPeriod.value = minutes[1];

      if(selectedPeriod.value == "PM"){
        selectedHour.value = selectedHour.value - 12;
      }
      print("selectedHour${selectedHour.value}");

      selectedDays = reminder.selectedDays?.map<bool>((e) => e == true).toList() ?? [];

      setState(() {});
    }
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
          text: "Set Reminder",
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
                  height: 200,
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(16),
                  decoration: AppUtils.commonBoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: getSetReminderContainerColor(),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackColor.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Hour Picker
                        SizedBox(
                          width: 60,
                          child: ValueListenableBuilder<int>(
                            valueListenable: selectedHour,
                            builder: (context, hour, _) {
                              print("hour$hour");
                              return WheelPicker(
                                looping: false,
                                selectedIndexColor: getPrimaryColor(),
                                style: const WheelPickerStyle(
                                    squeeze: 0.9,
                                    diameterRatio: 0.9,
                                    surroundingOpacity: .4,
                                    magnification: 1.8,
                                    itemExtent: 25),
                                itemCount: 12,
                                enableTap: true,
                                initialIndex: hour - 1  % 12,

                                onIndexChanged: (index) {
                                  selectedHour.value = index + 1;
                                  print("data")
;
                                },
                                builder: (context, index) => Center(
                                    child: AppUtils.commonTextWidget(
                                        text: (index + 1).toString().padLeft(2, '0'),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500)),
                              );
                            },
                          ),
                        ),
                        AppUtils.commonTextWidget(
                            text: ':',
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            textColor: getPrimaryColor()),
                        SizedBox(
                          width: 60,
                          child: ValueListenableBuilder<int>(
                            valueListenable: selectedMinute,
                            builder: (context, minute, _) {
                              String formattedMinute =
                                  minute.toString().padLeft(2, '0');
                              return WheelPicker(
                                style: WheelPickerStyle(
                                    squeeze: 0.9,
                                    diameterRatio: 0.9,
                                    surroundingOpacity: .4,
                                    magnification: 1.8,
                                    itemExtent: 25),
                                itemCount: 60,
                                initialIndex: minute,
                                enableTap: true,
                                looping: false,
                                selectedIndexColor: getPrimaryColor(),
                                onIndexChanged: (index) {
                                  selectedMinute.value = index;
                                },
                                builder: (context, index) => Center(
                                  child: AppUtils.commonTextWidget(
                                      text:
                                          "${index.toString().padLeft(2, '0')}",
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              );
                            },
                          ),
                        ),
                        // AM/PM Picker
                        SizedBox(
                          width: 60,
                          child: ValueListenableBuilder<String>(
                            valueListenable: selectedPeriod,
                            builder: (context, period, _) {
                              return WheelPicker(
                                style: WheelPickerStyle(
                                    squeeze: 0.9,
                                    diameterRatio: 0.9,
                                    surroundingOpacity: .4,
                                    magnification: 1.8,
                                    itemExtent: 25),
                                itemCount: 2,
                                selectedIndexColor: getPrimaryColor(),
                                looping: false,
                                // enableTap: true,
                                initialIndex: period == 'AM' ? 0 : 1,
                                onIndexChanged: (index) {
                                  selectedPeriod.value =
                                      index == 0 ? 'AM' : 'PM';
                                },
                                builder: (context, index) => Center(
                                    child: AppUtils.commonTextWidget(
                                        text: index == 0 ? 'AM' : 'PM',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500)),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AppUtils.commonContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      left: 16, top: 8, bottom: 8, right: 16),
                  decoration: AppUtils.commonBoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: getSetReminderContainerColor(),
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
                    child: AppUtils.commonElevatedButton(
                      text: "Cancel",
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.cancelBtnColor,
                      borderColor: AppColors.cancelBtnColor,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      leftMargin: 16,

                    ),
                  ),
                  Expanded(
                      child: AppUtils.commonElevatedButton(
                          backgroundColor: getPrimaryColor(),
                          text: "Save",
                          textColor: AppColors.blackColor,
                          onPressed: () async {
                            List<int> selectedIntDays = [];
                            for (int i = 0; i < selectedDays.length; i++) {
                              print("index$i");
                              if (selectedDays[i] == true) {
                                // print("selectedDays Data${selectedIntDays}");
                                selectedIntDays.add(i+1);
                              }
                            }
                            print("selectedDays_Data$selectedIntDays");

                            if(selectedPeriod.value == "PM"){
                              if(selectedHour.value != 12){
                                selectedHour.value = selectedHour.value + 12;
                                setState(() {});
                              }

                            }else{
                              if(selectedHour.value == 12){
                                selectedHour.value = 0;
                              }
                            }

                            selectedTime = TimeOfDay(
                              hour: selectedHour.value,
                              minute: selectedMinute.value,
                            );

                            await saveReminder(
                                selectedDays, selectedTime, selectedIntDays);

                           AppUtils.snackBarFnc(ctx: context,contentText: widget.index == null
                               ? 'Reminder Added!'
                               : 'Reminder Updated!');

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
}
