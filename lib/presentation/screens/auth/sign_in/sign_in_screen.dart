import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/auth/sign_in/provider/sign_in_view_model.dart';
import 'package:with_calendar/utils/constants/image_paths.dart';
import 'package:with_calendar/utils/services/snack_bar/snack_bar_service.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _configureControllers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 컨트롤러 설정
  void _configureControllers() {
    final viewModel = ref.read(signInViewModelProvider.notifier);

    _emailController.addListener(() {
      viewModel.updateEmail(_emailController.text.trim());
    });

    _passwordController.addListener(() {
      viewModel.updatePassword(_passwordController.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
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
                _buildEmailTextField(),
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
                _buildPasswordTextField(),
                const SizedBox(height: 32),
                _buildSignInButton(),
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
        ),
      ),
    );
  }

  /// 이메일 텍스트 필드
  Widget _buildEmailTextField() {
    return AppTextField(
      controller: _emailController,
      placeholderText: '이메일 형식',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (email) {
        if (email == null || email.isEmpty) {
          return '이메일을 입력해주세요.';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
          return '유효한 이메일 형식이 아닙니다.';
        }
        return null;
      },
    );
  }

  /// 비밀번호 텍스트 필드 빌드
  Widget _buildPasswordTextField() {
    return Consumer(
      builder: (context, ref, child) {
        final viewState = ref.watch(signInViewModelProvider);

        return AppTextField(
          controller: _passwordController,
          placeholderText: '6자 이상',
          obscureText: !viewState.isPasswordVisible,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!viewState.isValid) {
              SnackBarService.showSnackBar('이메일 또는 비밀번호를 확인해주세요.');
            }

            ref.read(signInViewModelProvider.notifier).signIn();
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textAlignVertical: TextAlignVertical.center,
          suffixIcon: GestureDetector(
            onTap: () {
              // 비밀번호 보여주기 토글
              final viewModel = ref.read(signInViewModelProvider.notifier);
              viewModel.togglePasswordVisibility();
            },
            child: Icon(
              viewState.isPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppColors.colora1a4a6,
              size: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호를 입력해주세요';
            }

            if (value.length < 6) {
              return '비밀번호는 6자 이상이어야 합니다';
            }

            return null;
          },
        );
      },
    );
  }

  /// 로그인 버튼
  Widget _buildSignInButton() {
    return Consumer(
      builder: (context, ref, child) {
        final viewState = ref.watch(signInViewModelProvider);

        return AppButton(
          text: '로그인',
          onTapped: () async {
            final isSuccess =
                await ref.read(signInViewModelProvider.notifier).signIn();
            if (isSuccess && context.mounted) {
              const TabRoute().go(context);
            }
          },
          isEnabled: viewState.isValid,
        );
      },
    );
  }
}
