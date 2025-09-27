import 'dart:developer';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/calendar/share_calendar_service.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/create/create_share_calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/search/search_user_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/share_calendar_list_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/update/update_share_calendar_screen_state.dart';

mixin class SearchUserScreenEvent {
  final ShareCalendarService _service = ShareCalendarService();

  ///
  /// 유저 검색
  ///
  Future<void> searchUser(WidgetRef ref, String userCode) async {
    // 이미 검색중이면 무시
    final isSearching = ref
        .read(SearchUserScreenState.isSearchingProvider.notifier)
        .state;
    if (isSearching) {
      SnackBarService.showSnackBar('이미 검색중입니다.');
      return;
    }

    // 검색 중 여부 설정
    _setIsSearching(ref, true);

    try {
      final userList = await _service.searchUser(userCode);
      _setSearchedUserList(ref, userList);

      if (userList.isEmpty) {
        SnackBarService.showSnackBar('검색 결과가 없습니다.');
      }
    } catch (e) {
      log('유저 검색 실패: $e');
      SnackBarService.showSnackBar('유저 검색 실패: $e');
    } finally {
      _setIsSearching(ref, false);
    }
  }

  ///
  /// 유저 초대
  ///
  void inviteUserForCreate(WidgetRef ref, CalendarParticipant user) {
    // 달력 생성 정보 가져오기
    final creation = ref
        .read(CreateShareCalendarState.creationProvider.notifier)
        .state
        .value;

    // 달력 생성 정보 업데이트
    List<CalendarParticipant> currentList = creation.participantList;

    // 이미 초대된 유저인 경우 초대 실패
    if (currentList.contains(user)) {
      SnackBarService.showSnackBar('이미 초대된 유저입니다.');
      return;
    }

    // 유저 초대
    currentList.add(user);
    SnackBarService.showSnackBar('${user.userName}님을 초대했습니다.');

    // 달력 생성 정보 업데이트
    ref.read(CreateShareCalendarState.creationProvider.notifier).state =
        Fetched(creation.copyWith(participantList: currentList));
  }

  ///
  /// 유저 초대
  ///
  void inviteUserForUpdate(WidgetRef ref, CalendarParticipant user) {
    // 달력 정보 가져오기
    final calendar = ref
        .read(UpdateShareCalendarState.shareCalendarProvider.notifier)
        .state
        .value;

    List<CalendarParticipant> currentList = calendar.participantList;
    List<CalendarParticipant> deletedList = calendar.deletedParticipantList;

    // 이미 초대된 유저인 경우 초대 실패
    if (currentList.contains(user)) {
      SnackBarService.showSnackBar('이미 초대된 유저입니다.');
      return;
    }

    // 삭제된 유저 리스트에 있을 경우 제거해줌
    if (deletedList.contains(user)) {
      deletedList.remove(user);
    }

    // 유저 초대
    currentList.add(user);
    SnackBarService.showSnackBar('${user.userName}님을 초대했습니다.');

    // 달력 정보 업데이트
    ref
        .read(UpdateShareCalendarState.shareCalendarProvider.notifier)
        .state = Fetched(
      calendar.copyWith(
        participantList: currentList,
        deletedParticipantList: deletedList,
      ),
    );
  }

  // -------------------------------- Helper -----------------------------------
  void _setSearchedUserList(WidgetRef ref, List<CalendarParticipant> userList) {
    ref.read(SearchUserScreenState.searchedUserListProvider.notifier).state =
        userList;
  }

  void _setIsSearching(WidgetRef ref, bool isSearching) {
    ref.read(SearchUserScreenState.isSearchingProvider.notifier).state =
        isSearching;
  }
}
