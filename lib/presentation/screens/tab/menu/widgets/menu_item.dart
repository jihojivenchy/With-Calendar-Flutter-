import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/menu/menu_item.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({super.key, required this.menu, required this.onTapped});

  final Menu menu;
  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BounceTapper(
        highlightColor: Colors.transparent,
        onTap: onTapped,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(menu.icon, color: const Color(0xFF1A1A1A), size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: AppText(
                  text: menu.title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  textColor: const Color(0xFF1A1A1A),
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
}
