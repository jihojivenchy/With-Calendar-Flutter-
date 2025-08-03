import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_up_information.dart';
import 'package:with_calendar/domain/entities/memo/memo_creation.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/color_picker_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/provider/sign_up_view_model.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/widgets/set_email_page.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/widgets/set_name_page.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/widgets/set_password_page.dart';
import 'package:with_calendar/utils/services/snack_bar/snack_bar_service.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _configureControllers();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// 컨트롤러 설정
  void _configureControllers() {
    final viewModel = ref.read(signUpViewModelProvider.notifier);

    // 페이지 이동 시 포커스 이동
    _pageController.addListener(() {
      final pageIndex = _pageController.page?.toInt() ?? 0;
      viewModel.updatePageIndex(pageIndex);

      switch (pageIndex) {
        case 0:
          _nameFocusNode.requestFocus();
          break;
        case 1:
          _emailFocusNode.requestFocus();
          break;
        case 2:
          _passwordFocusNode.requestFocus();
          break;
      }
    });

    _nameController.addListener(() {
      viewModel.updateName(_nameController.text);
    });

    _emailController.addListener(() {
      viewModel.updateEmail(_emailController.text);
    });

    _passwordController.addListener(() {
      viewModel.updatePassword(_passwordController.text);
    });

    _passwordConfirmController.addListener(() {
      viewModel.updatePasswordConfirm(_passwordConfirmController.text);
    });
  }

  void _signUp() async {
    final result = await ref.read(signUpViewModelProvider.notifier).signUp();
    
    if (mounted && result) {
      const TabRoute().go(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(title: '회원가입'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                pageSnapping: false,
                controller: _pageController,
                children: [
                  _buildSetNamePage(),
                  _buildSetEmailPage(),
                  _buildSetPasswordPage(),
                ],
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  ///
  /// 닉네임 및 개인정보처리방침 작성 페이지
  ///
  Widget _buildSetNamePage() {
    return Consumer(
      builder: (context, ref, child) {
        final viewState = ref.watch(signUpViewModelProvider);

        return SetNamePage(
          focusNode: _nameFocusNode,
          nameController: _nameController,
          onSubmitted: (value) {
            FocusScope.of(context).unfocus();
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          isPrivacyPolicyAgreed: viewState.isPrivacyPolicyAgreed,
          onPrivacyPolicyAgreed: (value) {
            // 개인정보처리방침 동의 업데이트
            ref
                .read(signUpViewModelProvider.notifier)
                .updatePrivacyPolicyAgreed(value);
          },
          onPrivacyArrowButtonTapped: () {
            // 개인정보처리방침 링크 이동
            ref.read(signUpViewModelProvider.notifier).goToPrivacyPolicyLink();
          },
        );
      },
    );
  }

  ///
  /// 이메일 작성 페이지
  ///
  Widget _buildSetEmailPage() {
    return Consumer(
      builder: (context, ref, child) {
        final viewState = ref.watch(signUpViewModelProvider);

        return SetEmailPage(
          focusNode: _emailFocusNode,
          emailController: _emailController,
          onSubmitted: (email) {
            _emailFocusNode.unfocus();

            if (!viewState.isEmailValid) {
              SnackBarService.showSnackBar('이메일 형식이 올바르지 않습니다.');
              return;
            }

            // 다음 페이지 이동
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      },
    );
  }

  ///
  /// 이메일 작성 페이지
  ///
  Widget _buildSetPasswordPage() {
    return Consumer(
      builder: (context, ref, child) {
        final viewState = ref.watch(signUpViewModelProvider);

        return SetPasswordPage(
          focusNode: _passwordFocusNode,
          passwordController: _passwordController,
          passwordConfirmController: _passwordConfirmController,
          isPasswordVisible: viewState.isPasswordVisible,
          isPasswordConfirmVisible: viewState.isPasswordConfirmVisible,
          onPasswordVisible: (value) {
            // 비밀번호 보여주기 토글
            ref
                .read(signUpViewModelProvider.notifier)
                .togglePasswordVisibility();
          },
          onPasswordConfirmVisible: (value) {
            // 비밀번호 확인 보여주기 토글
            ref
                .read(signUpViewModelProvider.notifier)
                .togglePasswordConfirmVisibility();
          },
        );
      },
    );
  }

  ///
  /// 하단 버튼
  ///
  Widget _buildBottomButton() {
    return Consumer(
      builder: (context, ref, child) {
        final viewState = ref.watch(signUpViewModelProvider);

        // 첫 페이지 유효성 검사 (이름 + 개인정보처리방침 동의)
        final isFirstPageValid =
            viewState.name.isNotEmpty && viewState.isPrivacyPolicyAgreed;

        // 두 번째 페이지 유효성 검사 (이메일)
        final isSecondPageValid = viewState.isEmailValid;

        // 세 번째 페이지 유효성 검사 (비밀번호)
        final isThirdPageValid = viewState.isPasswordValid;

        return Padding(
          padding: const EdgeInsets.only(
            top: 30,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          child: switch (viewState.pageIndex) {
            0 => _buildFirstPageButton(isEnabled: isFirstPageValid),
            1 => _buildSecondPageButton(isEnabled: isSecondPageValid),
            2 => _buildThirdPageButton(isEnabled: isThirdPageValid),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }

  ///
  /// 첫 페이지 버튼 (이름 + 개인정보처리방침 동의)
  ///
  Widget _buildFirstPageButton({required bool isEnabled}) {
    return AppButton(
      text: '다음',
      isEnabled: isEnabled,
      onTapped: () {
        FocusScope.of(context).unfocus();

        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  ///
  /// 두 번째 페이지 버튼 (이메일)
  ///
  Widget _buildSecondPageButton({required bool isEnabled}) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: '이전',
            backgroundColor: const Color(0xfff5f5f5),
            textColor: const Color(0xff111111),
            onTapped: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            text: '다음',
            isEnabled: isEnabled,
            onTapped: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
      ],
    );
  }

  ///
  /// 세 번째 페이지 버튼 (비밀번호)
  ///
  Widget _buildThirdPageButton({required bool isEnabled}) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: '이전',
            backgroundColor: const Color(0xfff5f5f5),
            textColor: const Color(0xff111111),
            onTapped: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            text: '회원가입',
            isEnabled: isEnabled,
            onTapped: _signUp,
          ),
        ),
      ],
    );
  }


}
