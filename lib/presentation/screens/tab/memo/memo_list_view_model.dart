import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/data/services/memo/memo_service.dart';
import 'package:with_calendar/data/services/menu/menu_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/presentation/common/type/screen_state.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';

/// 메모 리스트를 감지하는 StreamProvider
/// 메모 리스트 변경 시 자동으로 상태가 변경됨
final memoListStateProvider = StreamProvider<List<Memo>>((ref) {
  return MemoService().fetchMemoList();
});

/// 프로필 수정 뷰모델 provider
final memoListViewModelProvider =
    StateNotifierProvider.autoDispose<MemoListViewModel, MemoListScreenState>((
      ref,
    ) {
      return MemoListViewModel();
    });

/// 프로필 업데이트 화면 상태
class MemoListScreenState {
  final ScreenState screenState;
  final List<Memo> memoList;

  MemoListScreenState({required this.screenState, required this.memoList});

  MemoListScreenState copyWith({
    ScreenState? screenState,
    List<Memo>? memoList,
  }) {
    return MemoListScreenState(
      screenState: screenState ?? this.screenState,
      memoList: memoList ?? this.memoList,
    );
  }

  /// 초기 상태
  static MemoListScreenState get initialState =>
      MemoListScreenState(screenState: ScreenState.loading, memoList: []);
}

/// 프로필 업데이트 뷰모델
class MemoListViewModel extends StateNotifier<MemoListScreenState> {
  MemoListViewModel() : super(MemoListScreenState.initialState);

  /// 메뉴 서비스
  final MemoService _memoService = MemoService();

  ///
  /// 메모 리스트 업데이트
  ///
  void _updateMemoList(List<Memo> memoList) {
    state = state.copyWith(memoList: memoList);
  }
}
