import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/design_system/component/grid/dynamic_height_grid_view.dart';
import 'package:with_calendar/presentation/design_system/component/skeleton/skeleton_box.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

/// 달력 로딩 시 표시할 스켈레톤 뷰
class CalendarLoadingSkeleton extends StatelessWidget {
  const CalendarLoadingSkeleton({super.key, this.isShowHeader = true});

  final bool isShowHeader;

  @override
  Widget build(BuildContext context) {
    if (isShowHeader) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 16, right: 10),
                child: _buildHeaderSkeleton(),
              ),
              const SizedBox(height: 15),
              Expanded(child: _buildCalendarSkeleton()),
            ],
          ),
        ),
      );
    }

    return _buildCalendarSkeleton();
  }

  ///
  /// 캘린더 스켈레톤
  ///
  Widget _buildCalendarSkeleton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 요일 헤더를 제외한 나머지 영역을 rowCount로 나눈 값이 기본 높이
        final itemMinHeight = (constraints.maxHeight - 35) / 6;

        return Column(
          children: [
            SizedBox(height: 35, child: _buildWeekSkeleton()),
            const SizedBox(height: 12),
            Expanded(child: _buildDayGridSkeleton(6, itemMinHeight)),
          ],
        );
      },
    );
  }

  ///
  /// 헤더 스켈레톤
  ///
  Widget _buildHeaderSkeleton() {
    return SizedBox(
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SkeletonBox(width: 140, height: 18, borderRadius: 6),
                SizedBox(height: 4),
                SkeletonBox(width: 90, height: 12, borderRadius: 6),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SkeletonBox(width: 42, height: 14, borderRadius: 7),
              SizedBox(width: 15),
              SkeletonBox(width: 20, height: 20, borderRadius: 4),
              SizedBox(width: 12),
              SkeletonBox(width: 20, height: 20, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }

  ///
  /// 요일 헤더 스켈레톤
  ///
  Widget _buildWeekSkeleton() {
    return Row(
      children: List.generate(7, (index) {
        return Expanded(
          child: Center(
            child: const SkeletonBox(width: 20, height: 10, borderRadius: 4),
          ),
        );
      }),
    );
  }

  ///
  /// 날짜 그리드 스켈레톤
  ///
  Widget _buildDayGridSkeleton(int rowCount, double itemMinHeight) {
    return DynamicHeightGridView(
      itemCount: 7 * rowCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      builder: (context, index) {
        return _buildDayCellSkeleton(index, itemMinHeight);
      },
      crossAxisCount: 7,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
    );
  }

  ///
  /// 날짜 셀 스켈레톤
  ///
  Widget _buildDayCellSkeleton(int index, double itemMinHeight) {
    final bool showDots = index % 3 != 0;
    final int dotCount = (index % 4) + 1;

    return SizedBox(
      height: itemMinHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          const SkeletonBox(width: 20, height: 10, borderRadius: 6),
          if (showDots) ...[
            const SizedBox(height: 8),
            _buildScheduleDotsRow(dotCount),
          ],
        ],
      ),
    );
  }

  ///
  /// 일정 점 표시
  ///
  Widget _buildScheduleDotsRow(int count) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          const SkeletonBox(width: 4, height: 4, borderRadius: 2),
      ],
    );
  }
}
