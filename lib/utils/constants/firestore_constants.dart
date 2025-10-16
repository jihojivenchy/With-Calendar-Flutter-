/// Firestore Constants
abstract class FirestoreCollection {
  // 컬렉션 아이디들
  static const String users = 'USERS';
  static const String memo = 'MEMO';
  static const String calendar = 'CALENDAR';
  static const String calendarList = 'CALENDAR_LIST';
  static const String shareCalendar = 'SHARE_CALENDAR';
  static const String shareCalendarInfo = 'SHARE_CALENDAR_INFORMATION';
  static const String feedback = 'FEEDBACK';
  static const String holiday = 'HOLIDAY';

  // 도큐먼트 아이디들
}

/// HOLIDAY 컬렉션에서 사용하는 필드 키
abstract class FirestoreHolidayField {
  static const String year = 'year';
  static const String dates = 'dates';
  static const String title = 'title';
  static const String date = 'date';
}
