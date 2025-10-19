import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.surface3,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: AppColors.gray400, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: profile.name,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  AppText(
                    text: '회원 코드: ${profile.code}',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.gray400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
