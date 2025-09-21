import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
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
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/create/create_share_calendar_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/create/create_share_calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/create/widgets/participant_item.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/share_calendar_list_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/share_calendar_list_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/widgets/calendar_item.dart';

class CreateShareCalendarScreen extends BaseScreen
    with CreateShareCalendarEvent {
  CreateShareCalendarScreen({super.key});

  ///
  /// Init
  ///
  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMyProfile(ref);
    });
  }

  ///
  /// 배경색
  ///
  @override
  Color? get backgroundColor => AppColors.background;

  ///
  /// 앱 바
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return const DefaultAppBar(
      title: '달력 생성',
      backgroundColor: Color(0xFFF2F2F7),
    );
  }

  ///
  /// 본문
  ///
  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    // 참여 중인 멤버 리스트 조회 상태
    final creationState = ref.watch(CreateShareCalendarState.creationProvider);

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
      child: creationState.onState(
        fetched: (creation) {
          return Column(
            children: [
              // 콘텐츠
              Expanded(child: _buildContentView(ref, creation: creation)),
              const SizedBox(height: 20),

              // 생성 버튼
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: AppSize.responsiveBottomInset,
                ),
                child: AppButton(
                  text: '생성하기',
                  onTapped: () {
                    create(ref);
                  },
                ),
              ),
            ],
          );
        },
        failed: (error) {
          return ErrorView(title: '참여 중인 멤버 조회 중 오류가 발생했습니다.');
        },
        loading: () {
          return const LoadingView(title: '참여 중인 멤버를 불러오는 중입니다.');
        },
      ),
    );
  }

  ///
  /// ContentView
  ///
  Widget _buildContentView(
    WidgetRef ref, {
    required ShareCalendarCreation creation,
  }) {
    return CustomScrollView(
      slivers: [
        /// 달력 제목 설정
        _buildCalendarTitle(ref),

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
        _buildParticipantList(ref, creation.participantList),

        /// 초대 버튼
        _buildInviteFooterButton(ref),
      ],
    );
  }

  ///
  /// 달력 제목 설정
  ///
  Widget _buildCalendarTitle(WidgetRef ref) {
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
              placeholderText: '제목을 입력하세요.',
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
          SearchUserRoute().push(ref.context);
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
