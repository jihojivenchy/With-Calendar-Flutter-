import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';

///
/// 캘린더 애니메이션 (드래그로 캘린더 높이 조절)
///
class CalendarAnimationBuilder extends StatefulWidget {
  const CalendarAnimationBuilder({
    super.key,
    required this.screenMode,
    required this.onScreenModeChanged,
    required this.child,
  });

  final CalendarScreenMode screenMode;
  final Function(CalendarScreenMode) onScreenModeChanged;

  final Widget child;

  @override
  State<CalendarAnimationBuilder> createState() =>
      _CalendarAnimationBuilderState();
}

class _CalendarAnimationBuilderState extends State<CalendarAnimationBuilder>
    with SingleTickerProviderStateMixin {
  // 애니메이션 컨트롤러
  late AnimationController _controller;

  // 애니메이션 커브
  late CurvedAnimation _curvedAnimation;

  // 캘린더 높이
  late ValueNotifier<double> _height;

  // 드래그 시작 Y
  double? _dragStartY;

  // 드래그 시작 높이
  late double _dragStartHeight;

  // 활성화된 애니메이션
  Animation<double>? _activeAnimation;

  // 캘린더 최대 및 최소 높이
  double get _fullHeight => AppSize.calendarHeight;
  double get _halfHeight => 360;

  // 초기화
  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // 애니메이션 커브 초기화
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // 드래그로 조절되는 높이 초기화
    _height = ValueNotifier(
      widget.screenMode == CalendarScreenMode.full ? _fullHeight : _halfHeight,
    );

    // 드래그 시작 높이 초기화
    _dragStartHeight = _height.value;

    // 애니메이션 업데이트 리스너 추가
    _curvedAnimation.addListener(_onAnimationUpdate);
  }

  // 캘린더 모드 변경 시 높이 업데이트
  @override
  void didUpdateWidget(CalendarAnimationBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.screenMode != widget.screenMode) {
      _height.value = widget.screenMode == CalendarScreenMode.full
          ? _fullHeight
          : _halfHeight;
      _dragStartHeight = _height.value;
      setState(() {});
    }
  }

  /// 리소스 정리
  @override
  void dispose() {
    _curvedAnimation.removeListener(_onAnimationUpdate);
    _curvedAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 애니메이션 업데이트
  void _onAnimationUpdate() {
    if (_activeAnimation != null) {
      setState(() {
        _height.value = _activeAnimation!.value;
      });
    }
  }

  /// 활성화된 애니메이션 중지
  void _stopActiveAnimation() {
    _controller.stop();
    _activeAnimation = null;
  }

  ///
  /// 드래그 종료 시 최종 높이 결정
  ///
  void _settle({double velocityY = 0}) {
    // 드래그를 시작한 적이 없으면 종료
    if (_dragStartY == null) return;

    // 드래그 상태 초기화
    _dragStartY = null;

    // 중간 지점
    final midpoint = (_halfHeight + _fullHeight) / 2;

    // 최종 높이
    final double targetHeight;

    // 속도가 임계값(400) 보다 클 경우 (빠르게 드래그 했을 경우)
    if (velocityY.abs() > 400.0) {
      // 양수면 위 -> 아래 방향 => full 모드
      // 음수면 아래 -> 위 방향 => half 모드
      targetHeight = velocityY > 0 ? _fullHeight : _halfHeight;
    } else {
      // 중간 지점보다 현재 높이가 크면 full 모드, 작으면 half 모드
      targetHeight = _height.value >= midpoint ? _fullHeight : _halfHeight;
    }

    // 캘린더 모드 변경
    widget.onScreenModeChanged(
      targetHeight == _fullHeight
          ? CalendarScreenMode.full
          : CalendarScreenMode.half,
    );

    // 현재 높이와 목표 높이의 차이가 비슷하면 애니메이션 없이 설정
    if ((_height.value - targetHeight).abs() < 0.5) {
      _stopActiveAnimation();
      setState(() {
        _height.value = targetHeight;
        _dragStartHeight = targetHeight;
      });
      return;
    }

    // 목표 높이로 이동하는 애니메이션
    _animateTo(targetHeight);
  }

  /// 애니메이션 실행
  void _animateTo(double target) {
    _activeAnimation = Tween<double>(
      begin: _height.value,
      end: target,
    ).animate(_curvedAnimation);

    _controller.reset();
    _controller.forward().whenCompleteOrCancel(() {
      _activeAnimation = null;
      setState(() {
        _height.value = target;
        _dragStartHeight = target;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: <Type, GestureRecognizerFactory>{
        // 수직 드래그만 인식하도록
        VerticalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(debugOwner: this),
              (VerticalDragGestureRecognizer instance) {
                instance
                  ..onStart = _handlePanStart
                  ..onUpdate = _handlePanUpdate
                  ..onEnd = _handlePanEnd
                  ..onCancel = _handlePanCancel
                  ..gestureSettings = const DeviceGestureSettings(
                    touchSlop: 8.0,
                  );
              },
            ),
      },
      child: ValueListenableBuilder<double>(
        valueListenable: _height,
        builder: (context, height, child) {
          return SizedBox(height: height, child: child);
        },
        child: widget.child,
      ),
    );
  }

  /// 드래그 시작
  void _handlePanStart(DragStartDetails details) {
    // 드래그를 시작한 Y 좌표 저장
    _dragStartY = details.globalPosition.dy;

    // 드래그 시작 높이 저장
    _dragStartHeight = _height.value;

    // 애니메이션이 진행중이면 중지
    _stopActiveAnimation();
  }

  /// 드래그 중
  void _handlePanUpdate(DragUpdateDetails details) {
    // 드래그를 시작한 Y 좌표가 없으면 중지
    final startY = _dragStartY;
    if (startY == null) return;

    // 현재 손가락 위치 - 드래그 시작 위치 = 움직인 거리
    final deltaY = details.globalPosition.dy - startY;

    // 드래그 시작 높이 + 움직인 거리 = 새로운 높이
    final proposedHeight = _dragStartHeight + deltaY;

    // 새로운 높이를 최소값과 최대값 사이로 제한
    setState(() {
      _height.value = proposedHeight.clamp(_halfHeight, _fullHeight);
    });
  }

  /// 드래그 종료 시, 최종 높이 결정
  void _handlePanEnd(DragEndDetails details) {
    _settle(velocityY: details.velocity.pixelsPerSecond.dy);
  }

  /// 드래그 취소 시, 최종 높이 결정
  void _handlePanCancel() {
    _settle();
  }
}
