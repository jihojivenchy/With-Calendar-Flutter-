import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/side_menu/widgets/calendar_item.dart';

class ShareCalendarItem extends StatefulWidget {
  const ShareCalendarItem({
    super.key,
    required this.information,
    required this.isSelected,
    required this.onTapped,
    required this.onUpdateTapped,
    required this.onDeleteTapped,
  });

  final CalendarInformation information;
  final bool isSelected;
  final VoidCallback onTapped;
  final Function(CalendarInformation calendar) onUpdateTapped;
  final Function(CalendarInformation calendar) onDeleteTapped;

  @override
  State<ShareCalendarItem> createState() => _ShareCalendarItemState();
}

class _ShareCalendarItemState extends State<ShareCalendarItem> {
  /// edit 메뉴 표시
  OverlayEntry? _entry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () {
          if (_entry == null) {
            _show();
          } else {
            _hide();
          }
        },
        child: CalendarItem(
          information: widget.information,
          isSelected: widget.isSelected,
          onTapped: widget.onTapped,
        ),
      ),
    );
  }

  /// 드롭다운 메뉴 렌더링
  Widget buildOverlay() {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: context.surface3,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              label: '수정',
              icon: Icons.edit_outlined,
              iconColor: AppColors.primary,
              onTapped: () {
                _hide();
                widget.onUpdateTapped(widget.information);
              },
            ),
            Divider(height: 1, thickness: 0.2, color: AppColors.gray200),
            _buildActionButton(
              label: '삭제',
              icon: Icons.delete_outline,
              iconColor: const Color(0xFFE4604F),
              onTapped: () {
                _hide();
                widget.onDeleteTapped(widget.information);
              },
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 액션 버튼
  ///
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTapped,
  }) {
    return InkWell(
      onTap: onTapped,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                text: label,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// edit 메뉴 표시
  void _show() {
    // 헌재 화면에서 Overlay 위젯 가져오기
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (context) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerMove: (details) {
          // 최소 움직임 임계값
          if (_entry != null && details.delta.dy.abs() > 4) {
            _hide();
          }
        },
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hide,
              child: const SizedBox.expand(),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(110, 50),
              child: buildOverlay(),
            ),
          ],
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
}
