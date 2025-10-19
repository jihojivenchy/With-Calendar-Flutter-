import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/calendar/share_calendar_service.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/domain/entities/calendar/share/share_calendar.dart';
import 'package:with_calendar/domain/entities/calendar/share/share_calendar_creation.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/create/create_share_calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/update/update_share_calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/calendar_menu_view_event.dart';

mixin class UpdateShareCalendarEvent {
  final ShareCalendarService _service = ShareCalendarService();

  ///
  /// 공유 달력 조회
  ///
  Future<void> fetchShareCalendar(WidgetRef ref, String calendarID) async {
    try {
      final calendar = await _service.fetchShareCalendar(calendarID);
      _setShareCalendar(ref, Fetched(calendar));
    } catch (e) {
      log('공유 달력 조회 실패: ${e.toString()}');

      // 화면 이동
      if (ref.context.mounted) {
        SnackBarService.showSnackBar('공유 달력 조회 실패: ${e.toString()}');
        ref.context.pop();
      }
    }
  }

  ///
  /// 제목 변경
  ///
  void updateTitle(WidgetRef ref, String title) {
    final calendar = _getShareCalendar(ref);
    _setShareCalendar(ref, Fetched(calendar.copyWith(title: title)));
  }

  ///
  /// 유저 제거
  ///
  void removeUser(WidgetRef ref, int targetIndex) {
    final calendar = _getShareCalendar(ref);

    // 참여 중인 멤버 리스트 복사
    List<CalendarParticipant> currentList = List.from(calendar.participantList);
    List<CalendarParticipant> deletedList = List.from(
      calendar.deletedParticipantList,
    );

    // 삭제 리스트에 추가
    deletedList.add(currentList[targetIndex]);

    // 참여 중인 멤버 리스트에서 제거
    currentList.removeAt(targetIndex);

    // 참여 중인 멤버 리스트 업데이트
    _setShareCalendar(
      ref,
      Fetched(
        calendar.copyWith(
          participantList: currentList,
          deletedParticipantList: deletedList,
        ),
      ),
    );
  }

  ///
  /// 공유달력 수정
  ///
  Future<void> update(WidgetRef ref) async {
    final calendar = _getShareCalendar(ref);

    if (calendar.title.isEmpty) {
      SnackBarService.showSnackBar('제목을 입력해주세요');
      return;
    }

    if (calendar.participantList.length <= 1) {
      SnackBarService.showSnackBar('달력을 공유할 멤버를 추가해주세요');
      return;
    }

    try {
      await _service.updateCalendar(calendar);

      // 사이드 메뉴 캘린더 리스트 갱신
      await updateCalendarList(ref);

      if (ref.context.mounted) {
        _showDialog(ref, '${calendar.title} 달력 수정 완료');
      }
    } catch (e) {
      log('공유달력 생성 실패: ${e.toString()}');
      SnackBarService.showSnackBar('달력 생성에 실패했습니다. ${e.toString()}');
    }
  }

  ///
  /// 공유달력 삭제
  ///
  Future<void> delete(WidgetRef ref) async {
    try {
      final calendar = _getShareCalendar(ref);
      await _service.deleteCalendar(calendar);

      // 사이드 메뉴 캘린더 리스트 갱신
      await updateCalendarList(ref);

      if (ref.context.mounted) {
        _showDialog(ref, '달력 삭제 완료');
      }
    } catch (e) {
      log('공유달력 삭제 실패: ${e.toString()}');
      SnackBarService.showSnackBar('달력 삭제에 실패했습니다. ${e.toString()}');
    }
  }

  ///
  /// 공유달력 나가기
  ///
  Future<void> exit(WidgetRef ref) async {
    try {
      final calendar = _getShareCalendar(ref);
      await _service.exitCalendar(calendar);

      // 사이드 메뉴 캘린더 리스트 갱신
      await updateCalendarList(ref);

      if (ref.context.mounted) {
        _showDialog(ref, '달력 나가기 완료');
      }
    } catch (e) {
      log('공유달력 생성 실패: ${e.toString()}');
      SnackBarService.showSnackBar('달력 생성에 실패했습니다. ${e.toString()}');
    }
  }

  ///
  /// 사이드메뉴 캘린더 리스트 갱신
  ///
  Future<void> updateCalendarList(WidgetRef ref) async {
    // 기본 캘린더로 선택 전환
    final defaultCalendar = _service.setDefaultCalendar();

    // 사이드 메뉴 캘린더 리스트 갱신
    final calendarEvent = CalendarMenuEvent();
    await calendarEvent.fetchCalendarList(ref);
    await calendarEvent.updateSelectedCalendar(ref, calendar: defaultCalendar);
  }

  ///
  /// 달력 다이얼로그
  ///
  void _showDialog(WidgetRef ref, String title) {
    DialogService.show(
      dialog: AppDialog.singleBtn(
        title: title,
        btnContent: '확인',
        onBtnClicked: () {
          ref.context.pop();
          ref.context.pop();
        },
      ),
    );
  }

  // -------------------------------- Helper 메서드 ------------------------------
  ShareCalendar _getShareCalendar(WidgetRef ref) => ref
      .read(UpdateShareCalendarState.shareCalendarProvider.notifier)
      .state
      .value;

  void _setShareCalendar(WidgetRef ref, Ds<ShareCalendar> shareCalendar) =>
      ref.read(UpdateShareCalendarState.shareCalendarProvider.notifier).state =
          shareCalendar;
}
