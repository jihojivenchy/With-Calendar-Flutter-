import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

class CalendarActionDialog extends Dialog {
  const CalendarActionDialog({
    super.key,
    required this.onEditTapped,
    required this.onDeleteTapped,
  });

  final VoidCallback onEditTapped;
  final VoidCallback onDeleteTapped;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: 50,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionTile(
              label: '수정',
              icon: Icons.edit_outlined,
              iconColor: AppColors.primary,
              onTap: onEditTapped,
            ),
            Divider(height: 1, thickness: 0.2, color: AppColors.gray200),
            _buildActionTile(
              label: '삭제',
              icon: Icons.delete_outline,
              iconColor: const Color(0xFFE4604F),
              onTap: onDeleteTapped,
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 액션 타일
  ///
  Widget _buildActionTile({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
}
