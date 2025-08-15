import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.title, this.onRetryBtnTapped});

  final String title;
  final VoidCallback? onRetryBtnTapped;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFF898989),
            ),
            const SizedBox(height: 16),
            AppText(
              text: title,
              textAlign: TextAlign.center,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              textColor: const Color(0xFF898989),
            ),
            if (onRetryBtnTapped != null) ...[
              const SizedBox(height: 24),
              _buildRetryButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onRetryBtnTapped?.call();
      },
      child: Container(
        width: 140,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: AppText(
            text: '다시 시도',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            textColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
