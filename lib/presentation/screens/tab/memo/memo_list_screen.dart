import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/view/empty_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/error_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/memo/memo_list_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/memo/memo_list_screen_state.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import '../../../../domain/entities/memo/memo.dart';
import 'widgets/memo_item.dart';

class MemoListScreen extends BaseScreen with MemoListScreenEvent {
  MemoListScreen({super.key});

  ///
  /// Init
  ///
  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      subscribeMemoList(ref); // 메모 리스트 구독
    });
  }

  ///
  /// Dispose
  ///
  @override
  void onDispose(WidgetRef ref) {
    super.onDispose(ref);
    disposeSubscription(ref); // 메모 리스트 구독 해제
  }

  ///
  /// 배경색 설정
  ///
  @override
  Color? get backgroundColor => const Color(0xFFF2F2F7);

  ///
  /// 앱 바 구성
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(
      title: '메모',
      fontSize: 28,
      fontWeight: FontWeight.w800,
      backgroundColor: const Color(0xFFF2F2F7),
      isShowBackButton: false,
      actions: [
        GestureDetector(
          onTap: () {
            SearchMemoRoute().push(ref.context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.search, size: 24, color: Colors.black54),
          ),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () {
            CreateMemoRoute().push(ref.context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.add, size: 24, color: Colors.black54),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  ///
  /// 본문
  ///
  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();
    return _buildMemoList(ref);
  }

  ///
  /// 메모 리스트
  ///
  Widget _buildMemoList(WidgetRef ref) {
    final memoListAsync = ref.watch(MemoListScreenState.memoListProvider);

    return memoListAsync.when(
      data: (memoList) {
        if (memoList.isEmpty) {
          return SizedBox(
            height: double.infinity,
            child: EmptyView(title: '작성된 메모가 없습니다.\n메모를 작성해보세요.'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 30,
          ),
          itemCount: memoList.length,
          itemBuilder: (BuildContext context, int index) {
            final Memo memo = memoList[index];

            return MemoItem(
              memo: memo,
              onTapped: () {
                context.push(UpdateMemoRoute().location, extra: memo);
              },
              onLongPressed: () => _showDeleteDialog(ref, memo.id),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
        );
      },
      loading: () => SizedBox(
        height: double.infinity,
        child: const LoadingView(title: '메모 목록을 불러오는 중입니다.'),
      ),
      error: (error, _) {
        log('메모 조회 실패: ${error.toString()}');

        return SizedBox(
          height: double.infinity,
          child: ErrorView(
            title: '조회 중 오류가 발생했습니다.',
            onRetryBtnTapped: () => retry(ref), // 재시도
          ),
        );
      },
    );
  }

  // ------------------------------- Dialog ------------------------------------
  ///
  /// 메모 삭제 다이얼로그
  ///
  void _showDeleteDialog(WidgetRef ref, String memoID) {
    DialogService.show(
      dialog: AppDialog.doubleBtn(
        title: '메모 삭제',
        subTitle: '정말 이 메모를 삭제할까요?',
        leftBtnContent: '취소',
        rightBtnContent: '삭제',
        rightBtnColor: const Color(0xFFEF4444),
        onRightBtnClicked: () {
          ref.context.pop();
          deleteMemo(ref, memoID);
        },
        onLeftBtnClicked: () => ref.context.pop(),
      ),
    );
  }
}
