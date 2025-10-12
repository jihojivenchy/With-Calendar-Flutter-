import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/domain/entities/schedule/create_schedule_request.dart';
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
import 'package:with_calendar/presentation/screens/tab/calendar/share/search/search_user_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/search/search_user_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/search/widgets/guide_view.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/search/widgets/searched_user_item.dart';
import 'package:with_calendar/utils/constants/image_paths.dart';

enum SearchMode {
  create('CREATE'),
  update('UPDATE'),
  none('NONE');

  final String value;
  const SearchMode(this.value);

  static SearchMode fromValue(String value) {
    return SearchMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SearchMode.none,
    );
  }
}

/// 유저 검색 바텀 시트
class SearchUserScreen extends BaseScreen with SearchUserScreenEvent {
  SearchUserScreen({super.key, required this.mode});

  final SearchMode mode;

  ///
  /// 앱 바
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(
      title: '유저 검색',
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
            placeholder: '유저 코드를 입력하세요',
            controller: searchController,
            onSearch: (userCode) => searchUser(ref, userCode),
          ),
          const SizedBox(height: 24),
          _buildSearchedUserList(ref),
        ],
      ),
    );
  }

  ///
  /// 검색 결과 리스트
  ///
  Widget _buildSearchedUserList(WidgetRef ref) {
    final userList = ref.watch(SearchUserScreenState.searchedUserListProvider);

    if (userList.isEmpty) {
      return const GuideView();
    }

    return Expanded(
      child: ListView.separated(
        itemCount: userList.length,
        padding: const EdgeInsets.only(top: 10, bottom: 30),
        itemBuilder: (context, index) {
          final user = userList[index];
          return SearchedUserItem(
            user: user,
            onTapped: () {
              _showInviteDialog(ref, user);
            },
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 10);
        },
      ),
    );
  }

  ///
  /// 유저 초대 다이얼로그
  ///
  void _showInviteDialog(WidgetRef ref, CalendarParticipant user) {
    DialogService.show(
      dialog: AppDialog.doubleBtn(
        title: '유저 초대',
        subTitle: '해당 유저를 초대하시겠습니까?',
        leftBtnContent: '취소',
        rightBtnContent: '초대',
        onRightBtnClicked: () {
          ref.context.pop();
          switch (mode) {
            case SearchMode.create:
              inviteUserForCreate(ref, user);
              break;
            case SearchMode.update:
              inviteUserForUpdate(ref, user);
              break;
            case SearchMode.none:
              break;
          }
        },
        onLeftBtnClicked: () => ref.context.pop(),
      ),
    );
  }
}
