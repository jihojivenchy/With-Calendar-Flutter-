import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';

class CalendarAnimationBuilder extends HookWidget {
  const CalendarAnimationBuilder({
    super.key,
    required this.screenMode,
    required this.child,
    this.customHeight,
  });

  final CalendarScreenMode screenMode;
  final Widget child;
  final double? customHeight;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    final curvedAnimation = useMemoized(
      () => CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ),
      [controller],
    );

    final fullHeight = AppSize.calendarHeight;
    final halfHeight = fullHeight / 2;

    final height = useState<double>(
      screenMode == CalendarScreenMode.full ? fullHeight : halfHeight,
    );
    final dragStartY = useRef<double?>(null);
    final dragStartHeight = useRef<double>(height.value);
    final activeAnimation = useRef<Animation<double>?>(null);

    useEffect(() {
      final initialHeight =
          screenMode == CalendarScreenMode.full ? fullHeight : halfHeight;
      height.value = initialHeight;
      dragStartHeight.value = initialHeight;
      return null;
    }, [screenMode, fullHeight, halfHeight]);

    useEffect(() {
      void listener() {
        final animation = activeAnimation.value;
        if (animation != null) {
          height.value = animation.value;
        }
      }

      curvedAnimation.addListener(listener);
      return () {
        curvedAnimation.removeListener(listener);
      };
    }, [curvedAnimation]);

    void stopActiveAnimation() {
      controller.stop();
      activeAnimation.value = null;
    }

    void animateTo(double target) {
      activeAnimation.value = Tween<double>(
        begin: height.value,
        end: target,
      ).animate(curvedAnimation);
      controller.reset();
      controller.forward().whenCompleteOrCancel(() {
        activeAnimation.value = null;
        height.value = target;
        dragStartHeight.value = target;
      });
    }

    void settle({double velocityY = 0}) {
      if (dragStartY.value == null) {
        return;
      }

      dragStartY.value = null;

      const velocityThreshold = 400.0;
      final midpoint = (halfHeight + fullHeight) / 2;
      final currentHeight = height.value;

      double targetHeight;
      if (velocityY.abs() > velocityThreshold) {
        targetHeight = velocityY > 0 ? fullHeight : halfHeight;
      } else {
        targetHeight = currentHeight >= midpoint ? fullHeight : halfHeight;
      }

      if ((currentHeight - targetHeight).abs() < 0.5) {
        stopActiveAnimation();
        height.value = targetHeight;
        dragStartHeight.value = targetHeight;
        return;
      }

      animateTo(targetHeight);
    }

    if (customHeight != null) {
      return SizedBox(height: customHeight, child: child);
    }

    return GestureDetector(
      onPanStart: (details) {
        dragStartY.value = details.globalPosition.dy;
        dragStartHeight.value = height.value;
        stopActiveAnimation();
      },
      onPanUpdate: (details) {
        final startY = dragStartY.value;
        if (startY == null) {
          return;
        }

        final deltaY = details.globalPosition.dy - startY;
        final proposedHeight = dragStartHeight.value + deltaY;
        height.value =
            proposedHeight.clamp(halfHeight, fullHeight) as double;
      },
      onPanEnd: (details) {
        settle(velocityY: details.velocity.pixelsPerSecond.dy);
      },
      onPanCancel: () => settle(),
      child: SizedBox(
        height: height.value,
        child: child,
      ),
    );
  }
}
