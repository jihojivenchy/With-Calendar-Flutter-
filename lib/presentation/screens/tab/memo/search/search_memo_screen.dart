import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/domain/entities/schedule/request/create_schedule_request.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_search_bar.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/component/view/empty_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/search/search_user_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/search/search_user_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/search/widgets/guide_view.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/search/widgets/searched_user_item.dart';
import 'package:with_calendar/presentation/screens/tab/memo/search/search_memo_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/memo/search/search_memo_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/memo/search/widgets/search_memo_guide_view.dart';
import 'package:with_calendar/presentation/screens/tab/memo/search/widgets/searched_memo_item.dart';
import 'package:with_calendar/presentation/screens/tab/memo/widgets/memo_item.dart';
import 'package:with_calendar/utils/constants/image_paths.dart';

/// 메모 검색 화면
class SearchMemoScreen extends BaseScreen with SearchMemoScreenEvent {
  SearchMemoScreen({super.key});

  ///
  /// 앱 바
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(
      title: '메모 검색',
      backgroundColor: context.backgroundColor,
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    // 검색 컨트롤러
    final searchController = useTextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSearchBar(
            controller: searchController,
            onSearch: (keyword) => search(ref, keyword),
            placeholder: '검색어를 입력하세요',
          ),
          const SizedBox(height: 24),
          _buildSearchedMemoList(ref, searchController.text),
        ],
      ),
    );
  }

  ///
  /// 검색 결과 리스트
  ///
  Widget _buildSearchedMemoList(WidgetRef ref, String keyword) {
    final memoList = ref.watch(SearchMemoState.memoListProvider);

    if (memoList.isEmpty) {
      return const SearchMemoGuideView();
    }

    return Expanded(
      child: ListView.separated(
        itemCount: memoList.length,
        padding: const EdgeInsets.only(top: 10, bottom: 30),
        itemBuilder: (context, index) {
          final memo = memoList[index];
          return SearchedMemoItem(
            keyword: keyword,
            memo: memo,
            onTapped: () {
              context.push(UpdateMemoRoute().location, extra: memo);
            },
            onLongPressed: () => _showDeleteDialog(ref, memo.id),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 10);
        },
      ),
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
