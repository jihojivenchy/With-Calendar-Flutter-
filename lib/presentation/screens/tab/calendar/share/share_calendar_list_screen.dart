import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/view/empty_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/error_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/share_calendar_list_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/share_calendar_list_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/widgets/calendar_item.dart';

class ShareCalendarListScreen extends BaseScreen with ShareCalendarListEvent {
  ShareCalendarListScreen({super.key});

  ///
  /// Init
  ///
  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCurrentCalendar(ref);
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
    return DefaultAppBar(
      title: '달력 목록',
      backgroundColor: Color(0xFFF2F2F7),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, size: 26),
          onPressed: () {
            CreateShareCalendarRoute().push(context);
          },
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
    return FocusDetector(
      onFocusGained: () {
        fetchCalendarList(ref);
      },
      child: _buildCalendarList(ref),
    );
  }

  ///
  /// 캘린더 리스트
  ///
  Widget _buildCalendarList(WidgetRef ref) {
    // 캘린더 리스트
    final calendarListState = ref.watch(
      ShareCalendarListState.calendarListProvider,
    );

    // 현재 선택된 캘린더 ID
    final String currentCalendarID = ref.watch(
      ShareCalendarListState.currentCalendarIDProvider,
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
      child: calendarListState.onState(
        fetched: (calendarList) {
          // 개인 캘린더 리스트
          final privateList = calendarList
              .where((element) => element.type == CalendarType.private)
              .toList();

          // 공유 캘린더 리스트
          final sharedList = calendarList
              .where((element) => element.type == CalendarType.shared)
              .toList();

          return CustomScrollView(
            slivers: [
              _buildSectionTitle('개인 달력'),
              _buildPrivateCalendarList(ref, privateList, currentCalendarID),
              SliverToBoxAdapter(child: const SizedBox(height: 20)),
              _buildSectionTitle('공유 달력'),
              _buildSharedCalendarList(ref, sharedList, currentCalendarID),
            ],
          );
        },
        failed: (error) {
          return const ErrorView(title: '캘린더 목록 조회 중 오류가 발생했습니다.');
        },
        loading: () {
          return const LoadingView(title: '캘린더 목록을 불러오는 중입니다.');
        },
      ),
    );
  }

  ///
  /// 섹션 타이틀
  ///
  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: AppText(
          text: title,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          textColor: AppColors.color727577,
        ),
      ),
    );
  }

  ///
  /// 개인 캘린더 리스트
  ///
  Widget _buildPrivateCalendarList(
    WidgetRef ref,
    List<CalendarInformation> calendarList,
    String currentCalendarID,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: calendarList.length,
        itemBuilder: (context, index) {
          final calendar = calendarList[index];

          return CalendarItem(
            information: calendar,
            isSelected: calendar.id == currentCalendarID,
            onTapped: () async {
              HapticFeedback.selectionClick();
              updateSelectedCalendar(ref, calendar: calendar);
            },
          );
        },
      ),
    );
  }

  ///
  /// 공유 캘린더 리스트
  ///
  Widget _buildSharedCalendarList(
    WidgetRef ref,
    List<CalendarInformation> calendarList,
    String currentCalendarID,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: calendarList.length,
        itemBuilder: (context, index) {
          final calendar = calendarList[index];

          return CalendarItem(
            information: calendar,
            isSelected: calendar.id == currentCalendarID,
            onTapped: () async {
              HapticFeedback.selectionClick();
              updateSelectedCalendar(ref, calendar: calendar);
            },
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
      ),
    );
  }
}
