import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

/// 캘린더 리스트 드롭다운
class CalendarListDropdown extends StatefulWidget {
  final String currentCalendarID;
  final List<CalendarInformation> calendarList;

  /// 캘린더 리스트 조회 (드롭다운 메뉴 표시 전)
  final Future<void> Function() onWillShow;

  /// 캘린더 선택
  final Function(CalendarInformation calendar) onCalendarTapped;

  const CalendarListDropdown({
    super.key,
    required this.currentCalendarID,
    required this.calendarList,
    required this.onWillShow,
    required this.onCalendarTapped,
  });

  @override
  State<CalendarListDropdown> createState() => _CalendarListDropdownState();
}

class _CalendarListDropdownState extends State<CalendarListDropdown> {
  OverlayEntry? _entry;
  final LayerLink _layerLink = LayerLink();

  /// 드롭다운 메뉴 표시
  void _show() {
    // 헌재 화면에서 Overlay 위젯 가져오기
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _hide();
        },
        child: Align(
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(-120, 40),
            child: buildOverlay(),
          ),
        ),
      ),
    );

    overlay.insert(_entry!);
  }

  /// 드롭다운 메뉴 숨김
  void _hide() {
    if (_entry != null && _entry!.mounted) {
      _entry!.remove();
    }
    _entry = null;
  }

  /// 드롭다운 메뉴 렌더링
  Widget buildOverlay() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(107, 107, 107, 0.25),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.calendarList.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 0.5,
              color: Color(0xFFD2D5D7),
            ),
            itemBuilder: (context, index) {
              final calendar = widget.calendarList[index];
              final isSelected = calendar.id == widget.currentCalendarID;

              return InkWell(
                onTap: () {
                  widget.onCalendarTapped(calendar);
                  _hide();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 15,
                  ),
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: calendar.name,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          textColor: isSelected
                              ? AppColors.primary
                              : AppColors.color727577,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedOpacity(
                        opacity: isSelected ? 1 : 0,
                        duration: const Duration(milliseconds: 120),
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          if (_entry == null) {
            HapticFeedback.lightImpact();
            // 캘린더 리스트 조회 후 드롭다운 메뉴 표시
            await widget.onWillShow();
            _show();
          } else {
            _hide();
          }
        },
        child: const SizedBox(
          width: 30,
          height: 40,
          child: Center(
            child: Icon(Icons.swap_horiz, color: Color(0xFF000000), size: 20),
          ),
        ),
      ),
    );
  }
}
