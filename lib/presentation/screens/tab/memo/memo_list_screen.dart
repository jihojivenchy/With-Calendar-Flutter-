import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/view/empty_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/error_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/memo/memo_list_view_model.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import '../../../../domain/entities/memo/memo.dart';
import 'widgets/memo_item.dart';

class MemoListScreen extends ConsumerStatefulWidget {
  const MemoListScreen({super.key});

  @override
  ConsumerState<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends ConsumerState<MemoListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    text: '메모',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.search,
                            size: 24,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          CreateMemoRoute().push(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.add,
                            size: 24,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildMemoList(),
            ],
          ),
        ),
      ),
    );
  }

  ///
  /// 메모 리스트
  ///
  Widget _buildMemoList() {
    final memoListAsync = ref.watch(memoListStateProvider);

    return memoListAsync.when(
      data: (memoList) {
        if (memoList.isEmpty) {
          return Expanded(child: EmptyView(title: '작성된 메모가 없습니다. 메모를 작성해보세요.'));
        }
        return Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 16, bottom: 30),
            itemCount: memoList.length,
            itemBuilder: (BuildContext context, int index) {
              final Memo memo = memoList[index];
              return MemoItem(
                memo: memo,
                onTapped: () {
                  context.push(UpdateMemoRoute().location, extra: memo);
                },
                onLongPressed: () => _showDeleteDialog(index),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
        );
      },
      loading: () =>
          Expanded(child: const LoadingView(title: '메모 목록을 불러오는 중입니다.')),
      error: (error, _) {
        log('메모 조회 실패: ${error.toString()}');
        return Expanded(child: ErrorView(title: '불러오는 중 오류가 발생했습니다.'));
      },
    );
  }

  // ------------------------------- Dialog ------------------------------------
  ///
  /// 메모 삭제 다이얼로그
  ///
  void _showDeleteDialog(int index) {
    DialogService.show(
      dialog: AppDialog.doubleBtn(
        title: '메모 삭제',
        subTitle: '정말 이 메모를 삭제할까요?',
        leftBtnContent: '취소',
        rightBtnContent: '삭제',
        rightBtnColor: const Color(0xFFEF4444),
        onRightBtnClicked: () {
          context.pop();
          // setState(() {
          //   _memoList.removeAt(index);
          // });
        },
        onLeftBtnClicked: () => context.pop(),
      ),
    );
  }
}
