import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/screens/auth/sign_in/find_password/find_pw_screen_event.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/sign_up_screen_event.dart';
import 'package:with_calendar/utils/extensions/validation_extension.dart';

class FindPasswordScreen extends BaseScreen with FindPasswordScreenEvent {
  FindPasswordScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void onDispose(WidgetRef ref) {
    _emailController.dispose();
    super.onDispose(ref);
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  AppText(
                    text: '비밀번호 재설정 이메일을 받을 \n아이디(이메일)를 작성해주세요.',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    textColor: Colors.black,
                  ),
                  const SizedBox(height: 15),
                  AppTextField(
                    controller: _emailController,
                    placeholderText: '이메일 형식',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.send,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) => email?.validateEmail(),
                    onSubmitted: (email) {
                      // 이메일 형식 검사
                      if (!email.isValidEmail) {
                        SnackBarService.showSnackBar('이메일 형식을 확인해주세요.');
                        return;
                      }

                      findPassword(ref, email);
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButton(ref),
        ],
      ),
    );
  }

  /// 앱 바 구성
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(title: '비밀번호 찾기');
  }

  Widget _buildBottomButton(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(
        top: 30,
        bottom: AppSize.responsiveBottomInset,
        left: 16,
        right: 16,
      ),
      child: AppButton(
        text: '이메일 전송',
        isEnabled: true,
        onTapped: () {
          final email = _emailController.text;

          if (!email.isValidEmail) {
            SnackBarService.showSnackBar('이메일 형식을 확인해주세요.');
            return;
          }

          findPassword(ref, email);
        },
      ),
    );
  }
}
