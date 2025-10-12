import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/menu/menu_item.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.menu,
    required this.onTapped,
    this.notificationEnabled = false,
    this.onNotificationChanged,
  });

  final Menu menu;
  final VoidCallback onTapped;
  final bool notificationEnabled;
  final ValueChanged<bool>? onNotificationChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.textColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: menu.type == MenuType.notification
          ? _buildSetNotificationView(menu)
          : BounceTapper(
              highlightColor: Colors.transparent,
              onTap: onTapped,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Icon(menu.icon, size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppText(
                        text: menu.title,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: const Color(0xFF9E9E9E),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  ///
  /// 알림 설정의 경우
  ///
  Widget _buildSetNotificationView(Menu menu) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(menu.icon, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: AppText(
              text: menu.title,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          CupertinoSwitch(
            value: notificationEnabled,
            onChanged: onNotificationChanged,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.gray200,
            inactiveThumbColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}
