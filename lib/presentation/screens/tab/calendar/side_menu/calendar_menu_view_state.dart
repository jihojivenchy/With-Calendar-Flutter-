import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';

abstract class CalendarMenuState {
  /// 프로필 데이터
  static final profileProvider = StateProvider<Profile>((ref) {
    return const Profile(id: '', name: '', email: '', createdAt: '', code: '');
  });

  /// 전체 캘린더 리스트
  static final calendarListProvider = StateProvider<List<CalendarInformation>>((
    ref,
  ) {
    return [];
  });

  /// 개인 캘린더 리스트
  static final privateListProvider = Provider<List<CalendarInformation>>((ref) {
    final calendarList = ref.watch(calendarListProvider);
    return calendarList
        .where((element) => element.type == CalendarType.private)
        .toList();
  });

  /// 공유 캘린더 리스트
  static final sharedListProvider = Provider<List<CalendarInformation>>((ref) {
    final calendarList = ref.watch(calendarListProvider);
    return calendarList
        .where((element) => element.type == CalendarType.shared)
        .toList();
  });

  /// 현재 선택된 캘린더 ID
  static final currentCalendarIDProvider = StateProvider<String>((ref) {
    return '';
  });
}
