import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class SetNamePage extends StatelessWidget {
  const SetNamePage({
    super.key,
    required this.focusNode,
    required this.onNameChanged,
    required this.isPrivacyPolicyAgreed,
    required this.onPrivacyPolicyAgreed,
    required this.onPrivacyArrowButtonTapped,
  });

  final FocusNode focusNode;
  final Function(String) onNameChanged;
  final bool isPrivacyPolicyAgreed;
  final Function(bool) onPrivacyPolicyAgreed;
  final VoidCallback onPrivacyArrowButtonTapped;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const AppText(text: '닉네임', fontSize: 18),
          const SizedBox(height: 8),
          AppTextField(
            focusNode: focusNode,
            placeholderText: '닉네임을 입력하세요',
            onTextChanged: onNameChanged,
          ),
          const SizedBox(height: 40),
          _buildPrivacyPolicyButton(),
        ],
      ),
    );
  }

  ///
  /// 개인정보처리방침 동의 버튼
  ///
  Widget _buildPrivacyPolicyButton() {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onPrivacyPolicyAgreed(!isPrivacyPolicyAgreed),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPrivacyPolicyAgreed
                          ? AppColors.primary
                          : AppColors.colord2d5d7,
                      width: 1,
                    ),
                    color: isPrivacyPolicyAgreed
                        ? AppColors.primary
                        : Colors.transparent,
                  ),
                  child: isPrivacyPolicyAgreed
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                const AppText(
                  text: '개인정보처리방침 동의',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onPrivacyArrowButtonTapped,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.colora1a4a6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
