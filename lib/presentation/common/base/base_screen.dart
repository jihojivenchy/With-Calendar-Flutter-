import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/router/router.dart';

/// 앱 화면의 기본 템플릿 클래스
abstract class BaseScreen extends HookConsumerWidget {
  const BaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 페이지의 초기화 및 해제를 처리
    useEffect(() {
      onInit(ref);
      return () => onDispose(ref);
    }, []);

    /// 앱의 라이플 사이클 변화를 처리
    useOnAppLifecycleStateChange((previousState, state) {
      switch (state) {
        case AppLifecycleState.resumed:
          onResumed(ref);
          break;
        case AppLifecycleState.paused:
          onPaused(ref);
          break;
        case AppLifecycleState.inactive:
          onInactive(ref);
          break;
        case AppLifecycleState.detached:
          onDetached(ref);
          break;
        case AppLifecycleState.hidden:
          break;
      }
    });

   
    ///
    /// Swipe Back 제스처 이벤트를 관리
    /// [preventSwipeBack]의 속성 값은 통해
    /// 플랫폼별 Swipe Back 제스쳐 작동 여부를 설정할 수 있음.
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onWillPop(ref);
      },
      child: Scaffold(
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: buildAppBar(context, ref),
        body: wrapWithSafeArea
            ? SafeArea(
                top: setTopSafeArea,
                bottom: setBottomSafeArea,
                child: buildBody(context, ref),
              )
            : buildBody(context, ref),
        backgroundColor: backgroundColor(context),
        bottomNavigationBar: buildBottomNavigationBar(context, ref),
        floatingActionButtonLocation: floatingActionButtonLocation,
        floatingActionButton: buildFloatingButton(ref),
      ),
    );
  }

  /// 앱 바 구성
  @protected
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) => null;

  /// 화면 본문 구성
  @protected
  Widget buildBody(BuildContext context, WidgetRef ref) =>
      const SizedBox.shrink();

  /// 하단 네비게이션 바 구성
  @protected
  Widget? buildBottomNavigationBar(BuildContext context, WidgetRef ref) => null;

  /// 플로팅 버튼 구성
  @protected
  Widget? buildFloatingButton(WidgetRef ref) => null;

  /// 키보드가 화면 하단에 올라왔을 때 페이지의 크기를 조정하는 여부를 설정
  @protected
  bool get resizeToAvoidBottomInset => true;

  /// 플로팅 액션 버튼의 위치를 설정
  @protected
  FloatingActionButtonLocation? get floatingActionButtonLocation => null;

  /// Scaffold의 확장 여부를 설정
  @protected
  bool get extendBody => false;

  /// 앱 바 아래의 콘텐츠가 앱 바 뒤로 표시되는지 여부를 설정
  @protected
  bool get extendBodyBehindAppBar => false;

  /// Swipe Back 제스처 동작을 막는지 여부를 설정
  @protected
  bool get canPop => true;

  /// 화면의 배경색을 설정
  @protected
  Color? backgroundColor(BuildContext context) {
    return context.backgroundColor;
  }

  /// SafeArea로 감싸는 여부를 설정
  @protected
  bool get wrapWithSafeArea => true;

  /// 뷰의 아래에 SafeArea를 적용할지 여부를 설정
  @protected
  bool get setBottomSafeArea => true;

  /// 뷰의 위에 SafeArea를 적용할지 여부를 설정
  @protected
  bool get setTopSafeArea => true;

  /// 앱이 활성화된 상태로 돌아올 때 호출
  @protected
  void onResumed(WidgetRef ref) {}

  /// 앱이 일시 정지될 때 호출
  @protected
  void onPaused(WidgetRef ref) {}

  /// 앱이 비활성 상태로 전환될 때 호출
  @protected
  void onInactive(WidgetRef ref) {}

  /// 앱이 분리되었을 때 호출
  @protected
  void onDetached(WidgetRef ref) {}

  /// 페이지 초기화 시 호출
  @protected
  void onInit(WidgetRef ref) {}

  /// 페이지 해제 시 호출
  @protected
  void onDispose(WidgetRef ref) {}

  /// will pop시
  @protected
  void onWillPop(WidgetRef ref) {}
}
