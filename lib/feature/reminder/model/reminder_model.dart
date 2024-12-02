class ReminderModel {
  String? reminderTime;
  List<dynamic>? selectedDays;
  bool? isReminderOn;

  ReminderModel({this.reminderTime, this.selectedDays, this.isReminderOn});

  ReminderModel.fromJson(Map<String, dynamic> json) {
    reminderTime = json['reminder_time'];
    selectedDays = json['selected_days'];
    isReminderOn = json['isReminderOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reminder_time'] = this.reminderTime;
    data['selected_days'] = this.selectedDays;
    data['isReminderOn'] = this.isReminderOn;
    return data;
  }
}