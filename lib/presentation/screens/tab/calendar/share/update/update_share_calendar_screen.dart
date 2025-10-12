import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/domain/entities/calendar/share/share_calendar.dart';
import 'package:with_calendar/domain/entities/calendar/share/share_calendar_creation.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/component/view/empty_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/error_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/create/create_share_calendar_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/create/create_share_calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/create/widgets/participant_item.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/search/search_user_screen.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/share_calendar_list_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/share_calendar_list_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/update/update_share_calendar_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/update/update_share_calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/widgets/calendar_item.dart';

class UpdateShareCalendarScreen extends BaseScreen
    with UpdateShareCalendarEvent {
  UpdateShareCalendarScreen({super.key, required this.calendarID});

  final String calendarID;

  ///
  /// Init
  ///
  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchShareCalendar(ref, calendarID);
    });
  }

  ///
  /// 앱 바
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    // 조회 상태
    final calendarState = ref.watch(
      UpdateShareCalendarState.shareCalendarProvider,
    );

    // 조회되지 않았을 경우, 기본 앱바 반환
    if (!calendarState.state.isFetched) {
      return DefaultAppBar(
        title: '달력 수정',
        backgroundColor: context.backgroundColor,
      );
    }

    final isOwner = calendarState.value.isOwner;

    // 조회되었을 경우, 앱바 반환
    return DefaultAppBar(
      title: '달력 수정',
      backgroundColor: context.backgroundColor,
      actions: [
        if (isOwner) ...[
          // 삭제
          IconButton(
            icon: const Icon(
              Icons.delete,
              size: 22,
              color: AppColors.sundayRed,
            ),
            onPressed: () {
              _showDeleteDialog(ref);
            },
          ),
        ] else ...[
          // 나가기
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              size: 22,
              color: AppColors.sundayRed,
            ),
            onPressed: () {
              _showExitDialog(ref);
            },
          ),
        ],

        const SizedBox(width: 16),
      ],
    );
  }

  ///
  /// 본문
  ///
  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    // 조회 상태
    final calendarState = ref.watch(
      UpdateShareCalendarState.shareCalendarProvider,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: calendarState.onState(
        fetched: (calendar) {
          return Column(
            children: [
              // 콘텐츠
              Expanded(child: _buildContentView(ref, calendar: calendar)),
              const SizedBox(height: 20),

              // 수정 버튼
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: AppSize.responsiveBottomInset,
                ),
                child: AppButton(
                  text: '수정하기',
                  onTapped: () {
                    update(ref);
                  },
                ),
              ),
            ],
          );
        },
        failed: (error) {
          return ErrorView(title: '공유 달력 조회 중 오류가 발생했습니다.');
        },
        loading: () {
          return const LoadingView(title: '공유 달력을 불러오는 중입니다.');
        },
      ),
    );
  }

  ///
  /// ContentView
  ///
  Widget _buildContentView(WidgetRef ref, {required ShareCalendar calendar}) {
    return CustomScrollView(
      slivers: [
        /// 달력 제목 설정
        _buildCalendarTitle(ref, calendar.title),

        /// 참여 중인 멤버
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 10),
            child: AppText(
              text: '참여 중인 멤버',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              textColor: AppColors.color727577,
            ),
          ),
        ),
        _buildParticipantList(ref, calendar.participantList),

        /// 초대 버튼
        _buildInviteFooterButton(ref),
      ],
    );
  }

  ///
  /// 달력 제목 설정
  ///
  Widget _buildCalendarTitle(WidgetRef ref, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: '제목',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              textColor: AppColors.color727577,
            ),
            const SizedBox(height: 10),
            AppTextField(
              initialValue: title,
              placeholderText: '제목을 입력하세요.',
              backgroundColor: ref.context.surface,
              onTextChanged: (text) {
                updateTitle(ref, text);
              },
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 참여 중인 멤버
  ///
  Widget _buildParticipantList(
    WidgetRef ref,
    List<CalendarParticipant> participantList,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: participantList.length,
        itemBuilder: (context, index) {
          final participant = participantList[index];
          return ParticipantItem(
            participant: participant,
            onRemoveBtnTapped: () {
              _showRemoveDialog(ref, index);
            },
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 16);
        },
      ),
    );
  }

  ///
  /// 초대 버튼
  ///
  Widget _buildInviteFooterButton(WidgetRef ref) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          SearchUserRoute(mode: SearchMode.update.value).push(ref.context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Row(
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 22,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: AppText(
                  text: '눌러서 초대하기',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------- Dialog ------------------------------------
  ///
  /// 캘린더 삭제 다이얼로그
  ///
  void _showDeleteDialog(WidgetRef ref) {
    DialogService.show(
      dialog: AppDialog.doubleBtn(
        title: '달력 삭제',
        subTitle: '정말 이 달력을 삭제할까요?',
        leftBtnContent: '취소',
        rightBtnContent: '삭제',
        rightBtnColor: const Color(0xFFEF4444),
        onRightBtnClicked: () {
          ref.context.pop();
          delete(ref);
        },
        onLeftBtnClicked: () => ref.context.pop(),
      ),
    );
  }

  ///
  /// 캘린더 나가기 다이얼로그
  ///
  void _showExitDialog(WidgetRef ref) {
    DialogService.show(
      dialog: AppDialog.doubleBtn(
        title: '달력 나가기',
        subTitle: '정말 이 달력을 나가시겠습니까?',
        leftBtnContent: '취소',
        rightBtnContent: '나가기',
        rightBtnColor: const Color(0xFFEF4444),
        onRightBtnClicked: () {
          ref.context.pop();
          exit(ref);
        },
        onLeftBtnClicked: () => ref.context.pop(),
      ),
    );
  }

  ///
  /// 유저 추방 다이얼로그
  ///
  void _showRemoveDialog(WidgetRef ref, int targetIndex) {
    DialogService.show(
      dialog: AppDialog.doubleBtn(
        title: '유저 추방',
        subTitle: '해당 유저를 추방하시겠습니까?',
        leftBtnContent: '취소',
        rightBtnContent: '추방',
        onRightBtnClicked: () {
          ref.context.pop();
          removeUser(ref, targetIndex);
        },
        onLeftBtnClicked: () => ref.context.pop(),
      ),
    );
  }
}
