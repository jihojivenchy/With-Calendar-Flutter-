import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/calendar/share_calendar_service.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/domain/entities/calendar/share/share_calendar_creation.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/create/create_share_calendar_screen_state.dart';

mixin class CreateShareCalendarEvent {
  final ShareCalendarService _service = ShareCalendarService();

  ///
  /// 내 정보 조회 후 달력 참여 리스트에 추가
  ///
  Future<void> fetchMyProfile(WidgetRef ref) async {
    try {
      final myProfile = await _service.fetchProfile();
      // 달력 생성 정보 설정
      _setCreation(
        ref,
        Fetched(ShareCalendarCreation(title: '', participantList: [myProfile])),
      );
    } catch (e) {
      log('내 정보 조회 실패: ${e.toString()}');

      // 화면 이동
      if (ref.context.mounted) {
        SnackBarService.showSnackBar('내 정보 조회 실패: ${e.toString()}');
        ref.context.pop();
      }
    }
  }

  ///
  /// 제목 변경
  ///
  void updateTitle(WidgetRef ref, String title) {
    final creation = _getCreation(ref);
    _setCreation(ref, Fetched(creation.copyWith(title: title)));
  }

  ///
  /// 유저 제거
  ///
  void removeUser(WidgetRef ref, int targetIndex) {
    final creation = _getCreation(ref);

    // 참여 중인 멤버 리스트 복사
    List<CalendarParticipant> currentList = List.from(creation.participantList);

    // 참여 중인 멤버 리스트에서 제거
    currentList.removeAt(targetIndex);

    // 참여 중인 멤버 리스트 업데이트
    _setCreation(ref, Fetched(creation.copyWith(participantList: currentList)));
  }

  ///
  /// 공유달력 생성
  ///
  Future<void> create(WidgetRef ref) async {
    final creation = _getCreation(ref);

    if (creation.title.isEmpty) {
      SnackBarService.showSnackBar('제목을 입력해주세요');
      return;
    }

    if (creation.participantList.length <= 1) {
      SnackBarService.showSnackBar('달력을 공유할 멤버를 추가해주세요');
      return;
    }

    try {
      await _service.createCalendar(creation);
      if (ref.context.mounted) {
        _showCreateSuccessDialog(ref, '${creation.title} 달력 생성 완료');
      }
    } catch (e) {
      log('공유달력 생성 실패: ${e.toString()}');
      SnackBarService.showSnackBar('달력 생성에 실패했습니다. ${e.toString()}');
    }
  }

  ///
  /// 달력 생성 완료 다이얼로그
  ///
  void _showCreateSuccessDialog(WidgetRef ref, String title) {
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
  ShareCalendarCreation _getCreation(WidgetRef ref) =>
      ref.read(CreateShareCalendarState.creationProvider.notifier).state.value;

  void _setCreation(WidgetRef ref, Ds<ShareCalendarCreation> creation) =>
      ref.read(CreateShareCalendarState.creationProvider.notifier).state =
          creation;
}
