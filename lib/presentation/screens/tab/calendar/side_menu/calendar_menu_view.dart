import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/view/error_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/side_menu/widgets/calendar_action_dialog.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/side_menu/widgets/calendar_item.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/side_menu/calendar_menu_view_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/side_menu/calendar_menu_view_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/side_menu/widgets/create_calendar_button.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/side_menu/widgets/profile_header.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/side_menu/widgets/share_calendar_item.dart';

///
/// 사이드 메뉴 표시
///
Future<void> showCalendarMenu({required BuildContext context}) async {
  // 전체 화면을 덮는 다이얼로그 표시
  final result = await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false, // 배경 터치로 닫기 비활성화 (애니메이션으로만 닫기)
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, __) {
      return CalendarMenuView();
    },
  );

  return result;
}

class CalendarMenuView extends ConsumerStatefulWidget {
  const CalendarMenuView({super.key});

  @override
  ConsumerState<CalendarMenuView> createState() => _CalendarMenuViewState();
}

class _CalendarMenuViewState extends ConsumerState<CalendarMenuView>
    with SingleTickerProviderStateMixin, CalendarMenuEvent {
  // 애니메이션 컨트롤러 - 애니메이션의 시작/정지/역재생을 담당
  late final AnimationController _animationController;
  // 슬라이드 애니메이션 - 오른쪽에서 왼쪽으로 슬라이드하는 효과
  late final Animation<Offset> _slideAnimation;
  // 배경 어둡게 처리하는 애니메이션 (스크림 효과)
  late final Animation<double> _scrimOpacityAnimation;

  // 메뉴가 열려있는지 상태를 추적
  bool _isOpen = false;

  ///
  /// 초기화
  ///
  @override
  void initState() {
    super.initState();
    // 컨트롤러 구성
    _configureController();

    // 메뉴 열기
    _open();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProfile(ref);
      fetchCurrentCalendar(ref);
      fetchCalendarList(ref);
    });
  }

  ///
  /// Dispose
  ///
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  ///
  /// 컨트롤러 구성
  ///
  void _configureController() {
    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
    );

    // 부드러운 애니메이션을 위한 곡선 설정
    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // 슬라이드 애니메이션 설정
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // 화면 오른쪽 밖에서 시작
      end: Offset.zero, // 화면 중앙으로 이동
    ).animate(curvedAnimation);

    // 배경 어둡게 처리하는 애니메이션
    _scrimOpacityAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(curvedAnimation);
  }

  /// 메뉴 열기 - 슬라이드 애니메이션 시작
  Future<void> _open() async {
    // 이미 열려있으면 무시
    if (_isOpen) return;

    // 애니메이션 시작
    _isOpen = true;
    await _animationController.forward();
  }

  /// 메뉴 닫기 - 슬라이드 애니메이션 역재생
  Future<void> _close() async {
    // 이미 닫혀있으면 무시
    if (!_isOpen) return;

    // 애니메이션 역재생
    await _animationController.reverse();
    _isOpen = false;

    // 메뉴 닫기
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _close();
      },
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) {
            // 애니메이션이 시작되었는지 확인 (터치 가능 여부 결정)
            final isInteractable = _animationController.value > 0.0;

            return Stack(
              children: [
                // 배경 오버레이
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !(isInteractable), // 시작 전에는 터치 무시
                    child: GestureDetector(
                      onTap: () async {
                        await _close();
                      },
                      child: Container(
                        color: Colors.black.withValues(
                          alpha: _scrimOpacityAnimation.value,
                        ),
                      ),
                    ),
                  ),
                ),
                // 사이드 메뉴
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    heightFactor: 1,
                    child: SlideTransition(
                      position: _slideAnimation, // 슬라이드 애니메이션 적용
                      child: Scaffold(
                        backgroundColor: context.backgroundColor,
                        appBar: _buildAppBar(),
                        body: _buildCalendarList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  ///
  /// 앱 바
  ///
  PreferredSizeWidget _buildAppBar() {
    return DefaultAppBar(
      title: '',
      backgroundColor: context.backgroundColor,
      onBackPressed: () {
        _close();
      },
    );
  }

  ///
  /// 캘린더 리스트
  ///
  Widget _buildCalendarList() {
    return CustomScrollView(
      slivers: [
        _buildProfileHeader(),
        _buildSectionTitle('개인 달력'),
        _buildPrivateCalendarList(),
        SliverToBoxAdapter(child: const SizedBox(height: 20)),
        _buildSectionTitle('공유 달력'),
        _buildSharedCalendarList(),
        CreateCalendarButton(
          onTapped: () {
            HapticFeedback.selectionClick();
            CreateShareCalendarRoute().push(context);
          },
        ),
      ],
    );
  }

  ///
  /// 프로필 헤더
  ///
  Widget _buildProfileHeader() {
    final Profile profile = ref.watch(CalendarMenuState.profileProvider);

    return ProfileHeader(profile: profile);
  }

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
  Widget _buildPrivateCalendarList() {
    final privateList = ref.watch(CalendarMenuState.privateListProvider);
    final currentCalendarID = ref.watch(
      CalendarMenuState.currentCalendarIDProvider,
    );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: privateList.length,
        itemBuilder: (context, index) {
          final calendar = privateList[index];

          return CalendarItem(
            information: calendar,
            isSelected: calendar.id == currentCalendarID,
            onTapped: () {
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
  Widget _buildSharedCalendarList() {
    final sharedList = ref.watch(CalendarMenuState.sharedListProvider);
    final currentCalendarID = ref.watch(
      CalendarMenuState.currentCalendarIDProvider,
    );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: sharedList.length,
        itemBuilder: (context, index) {
          final calendar = sharedList[index];

          return ShareCalendarItem(
            information: calendar,
            isSelected: calendar.id == currentCalendarID,
            onTapped: () {
              HapticFeedback.selectionClick();
              updateSelectedCalendar(ref, calendar: calendar);
            },
            onUpdateTapped: (calendar) {
              UpdateShareCalendarRoute(calendarID: calendar.id).push(context);
            },
            onDeleteTapped: (calendar) {},
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
      ),
    );
  }

  // ------------------------------- Dialog ------------------------------------
  ///
  /// 달력 액션 다이얼로그
  ///
  Future<void> showCalendarActionDialog() async {
    DialogService.show(
      dialog: CalendarActionDialog(
        onEditTapped: () {
          context.pop();
        },
        onDeleteTapped: () {
          context.pop();
        },
      ),
    );
  }
}
