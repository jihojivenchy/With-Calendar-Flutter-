enum ScheduleType {
  allDay(displayText: '하루종일', queryValue: 'ALL_DAY'),
  time(displayText: '시간', queryValue: 'TIME');

  final String displayText;
  final String queryValue;

  const ScheduleType({required this.displayText, required this.queryValue});

  static ScheduleType fromString(String value) {
    return ScheduleType.values.firstWhere(
      (type) => type.queryValue == value,
      orElse: () => ScheduleType.allDay,
    );
  }
}
