import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/auth/sign_in/sign_in_event.dart';
import 'package:with_calendar/presentation/screens/auth/sign_in/sign_in_state.dart';
import 'package:with_calendar/utils/constants/image_paths.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/utils/extensions/validation_extension.dart';

class SignInScreen extends BaseScreen with SignInEvent {
  SignInScreen({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const AppText(
              text: 'With Calendar',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              textColor: AppColors.primary,
            ),
            const AppText(
              text: '함께하는 일정 관리',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              textColor: AppColors.color727577,
            ),
            const SizedBox(height: 60),
            const Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: '이메일',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                textColor: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildEmailTextField(ref),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: '비밀번호',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                textColor: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildPasswordTextField(ref),
            const SizedBox(height: 32),
            _buildSignInButton(ref),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText(
                  text: '계정이 없으신가요? ',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.color727577,
                ),
                GestureDetector(
                  onTap: () => SignUpRoute().push(context),
                  child: const AppText(
                    text: '회원가입',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.primary,
                    textDecoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => FindPasswordRoute().push(context),
              child: const AppText(
                text: '비밀번호를 잊으셨나요?',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textColor: AppColors.color727577,
                textDecoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이메일 텍스트 필드
  Widget _buildEmailTextField(WidgetRef ref) {
    return AppTextField(
      placeholderText: '이메일 형식',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (email) => email?.validateEmail(),
      onTextChanged: (email) {
        updateEmail(ref, email);
      },
    );
  }

  /// 비밀번호 텍스트 필드 빌드
  Widget _buildPasswordTextField(WidgetRef ref) {
    final isPasswordVisible = ref.watch(SignInState.isPasswordVisibleProvider);
    final isValid = ref.watch(SignInState.isValidProvider);

    return AppTextField(
      placeholderText: '6자 이상',
      obscureText: !isPasswordVisible,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) {
        if (!isValid) {
          SnackBarService.showSnackBar('이메일 또는 비밀번호를 확인해주세요.');
        }

        // 로그인 요청
        signIn(ref);
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textAlignVertical: TextAlignVertical.center,
      suffixIcon: GestureDetector(
        onTap: () => togglePasswordVisibility(ref),
        child: Icon(
          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: AppColors.colora1a4a6,
          size: 20,
        ),
      ),
      validator: (value) => value?.validatePassword(),
    );
  }

  /// 로그인 버튼
  Widget _buildSignInButton(WidgetRef ref) {
    final isValid = ref.watch(SignInState.isValidProvider);

    return AppButton(
      text: '로그인',
      isEnabled: isValid,
      onTapped: () async {
        signIn(ref);
      },
    );
  }
}
