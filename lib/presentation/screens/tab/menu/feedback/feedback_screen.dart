import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/menu/feedback/feedback_screen_event.dart';

class FeedbackScreen extends BaseScreen with FeedbackEvent {
  FeedbackScreen({super.key});

  ///
  /// 앱바
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(
      title: '피드백',
      backgroundColor: context.backgroundColor,
    );
  }

  ///
  /// 본문
  ///
  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildContentTextField(ref, textController),
          _buildCompletionButton(ref, textController),
          _buildCustomerCenterButton(ref),
        ],
      ),
    );
  }

  ///
  /// 피드백 내용 텍스트 필드
  ///
  Widget _buildContentTextField(
    WidgetRef ref,
    TextEditingController textController,
  ) {
    return AppTextField(
      controller: textController,
      placeholderText: '내용을 입력하세요',
      keyboardType: TextInputType.multiline,
      maxLines: 8,
      backgroundColor: ref.context.surface,
      borderColor: Colors.transparent,
    );
  }

  ///
  /// 피드백 완료 버튼
  ///
  Widget _buildCompletionButton(
    WidgetRef ref,
    TextEditingController textController,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: AppButton(
        text: '완료',
        onTapped: () {
          if (textController.text.trim().isEmpty) {
            SnackBarService.showSnackBar('내용을 입력해주세요');
            return;
          }

          create(ref, textController.text);
          textController.clear();
        },
      ),
    );
  }

  ///
  /// 고객 센터 이동 버튼
  ///
  Widget _buildCustomerCenterButton(WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(ref.context).unfocus();
        goToCustomerCenter(ref);
      },
      child: Padding(
        padding: EdgeInsets.only(top: 30),
        child: AppText(
          text: '고객 센터로 문의하기',
          textColor: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          textDecoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
