class ReminderModel {
  Map<int, String>? dayUuidMap;
  String? reminderTime;
  List<dynamic>? selectedDays;
  bool? isReminderOn;

  ReminderModel({this.reminderTime, this.selectedDays, this.isReminderOn,this.dayUuidMap});

  Map<String, dynamic> toJson() {
    return {
      'selectedDays': selectedDays,
      'isReminderOn': isReminderOn,
      'reminderTime': reminderTime,
      'dayUuidMap': dayUuidMap?.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      selectedDays: List<bool>.from(json['selectedDays']),
      isReminderOn: json['isReminderOn'],
      reminderTime: json['reminderTime'],
      dayUuidMap: (json['dayUuidMap'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(int.parse(key), value as String),
      ),
    );
  }

}