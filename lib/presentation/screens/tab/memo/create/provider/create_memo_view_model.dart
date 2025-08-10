import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/data/services/memo/memo_service.dart';
import 'package:with_calendar/data/services/menu/menu_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';
import 'package:with_calendar/domain/entities/memo/memo_creation.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/presentation/common/type/screen_state.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';

/// 프로필 수정 뷰모델 provider
final createMemoViewModelProvider =
    StateNotifierProvider.autoDispose<
      CreateMemoViewModel,
      CreateMemoScreenState
    >((ref) {
      return CreateMemoViewModel();
    });

/// 프로필 업데이트 화면 상태
class CreateMemoScreenState {
  final MemoCreation memo;

  CreateMemoScreenState({required this.memo});

  CreateMemoScreenState copyWith({MemoCreation? memo}) {
    return CreateMemoScreenState(memo: memo ?? this.memo);
  }

  bool get isValidate => memo.content.isNotEmpty;

  /// 초기 상태
  static CreateMemoScreenState get initialState =>
      CreateMemoScreenState(memo: MemoCreation.initialState);
}

/// 프로필 업데이트 뷰모델
class CreateMemoViewModel extends StateNotifier<CreateMemoScreenState> {
  CreateMemoViewModel() : super(CreateMemoScreenState.initialState);

  /// 핀 상태 업데이트
  void updatePinState({bool? isPinned, Color? pinColor}) {
    state = state.copyWith(
      memo: state.memo.copyWith(
        isPinned: isPinned,
        pinColor: pinColor,
      ),
    );
  }

  /// 메모 내용 업데이트
  void updateContent(String content) {
    state = state.copyWith(memo: state.memo.copyWith(content: content));
  }

  /// 메모 생성
  Future<bool> createMemo() async {
    final memo = state.memo;

    try {
      await MemoService().create(memo);
      SnackBarService.showSnackBar('생성 완료');
      return true;
    } catch (e) {
      log('메모 생성 실패: ${e.toString()}');
      SnackBarService.showSnackBar('생성 실패: ${e.toString()}');
      return false;
    }
  }
}
