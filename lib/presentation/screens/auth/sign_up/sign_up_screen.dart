import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_up_information.dart';
import 'package:with_calendar/domain/entities/memo/memo_creation.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/color_picker_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/sign_up_screen_event.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/sign_up_screen_state.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/widgets/set_email_page.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/widgets/set_name_page.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/widgets/set_password_page.dart';
import 'package:with_calendar/utils/extensions/validation_extension.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';

class SignUpScreen extends BaseScreen with SignUpScreenEvent {
  SignUpScreen({super.key});

  final PageController _pageController = PageController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);

    // 페이지 이동 시 포커스 이동
    _pageController.addListener(() => _moveTextFieldFocus(ref));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void onDispose(WidgetRef ref) {
    _pageController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.onDispose(ref);
  }

  ///
  /// 페이지 이동 시 포커스 이동
  ///
  void _moveTextFieldFocus(WidgetRef ref) {
    final pageIndex = _pageController.page?.toInt() ?? 0;
    updatePageIndex(ref, pageIndex);

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
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            pageSnapping: false,
            controller: _pageController,
            children: [
              _buildSetNamePage(ref),
              _buildSetEmailPage(ref),
              _buildSetPasswordPage(ref),
            ],
          ),
        ),
        _buildBottomButton(ref),
      ],
    );
  }

  /// 앱 바 구성
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(title: '회원가입');
  }

  ///
  /// 닉네임 및 개인정보처리방침 작성 페이지
  ///
  Widget _buildSetNamePage(WidgetRef ref) {
    final isPrivacyPolicyAgreed = ref.watch(
      SignUpScreenState.informationProvider.select(
        (value) => value.isPrivacyPolicyAgreed,
      ),
    );

    print('이름 페이지 재빌드');

    return SetNamePage(
      focusNode: _nameFocusNode,
      onNameChanged: (value) {
        updateName(ref, value);
      },
      isPrivacyPolicyAgreed: isPrivacyPolicyAgreed,
      onPrivacyPolicyAgreed: (value) {
        // 개인정보처리방침 동의 업데이트
        updatePrivacyPolicyAgreed(ref, value);
      },
      onPrivacyArrowButtonTapped: () {
        // 개인정보처리방침 링크 이동
        goToPrivacyPolicyLink();
      },
    );
  }

  ///
  /// 이메일 작성 페이지
  ///
  Widget _buildSetEmailPage(WidgetRef ref) {
    print('이메일 페이지 재빌드');

    return SetEmailPage(
      focusNode: _emailFocusNode,
      onEmailChanged: (value) {
        updateEmail(ref, value);
      },
      onSubmitted: (email) {
        // 이메일 입력 여부 검사
        if (!email.isValidEmail) {
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
  }

  ///
  /// 비밀번호 작성 페이지
  ///
  Widget _buildSetPasswordPage(WidgetRef ref) {
    // 비밀번호
    final password = ref.watch(
      SignUpScreenState.informationProvider.select((value) => value.password),
    );

    // 비밀번호 보여주기 여부
    final isPasswordVisible = ref.watch(
      SignUpScreenState.isPasswordVisibleProvider,
    );

    // 비밀번호 확인 보여주기 여부
    final isPasswordConfirmVisible = ref.watch(
      SignUpScreenState.isPasswordConfirmVisibleProvider,
    );

    print('비밀번호 페이지 재빌드');

    return SetPasswordPage(
      focusNode: _passwordFocusNode,
      password: password,
      onPasswordChanged: (value) {
        updatePassword(ref, value);
      },
      onPasswordConfirmChanged: (value) {
        updatePasswordConfirm(ref, value);
      },
      isPasswordVisible: isPasswordVisible,
      isPasswordConfirmVisible: isPasswordConfirmVisible,
      onPasswordVisible: (value) {
        // 비밀번호 보여주기 토글
        updatePasswordVisibility(ref, value);
      },
      onPasswordConfirmVisible: (value) {
        // 비밀번호 확인 보여주기 토글
        updatePasswordConfirmVisibility(ref, value);
      },
    );
  }

  ///
  /// 하단 버튼
  ///
  Widget _buildBottomButton(WidgetRef ref) {
    // 페이지 인덱스
    final pageIndex = ref.watch(SignUpScreenState.pageIndexProvider);

    // 첫 페이지 유효성 검사 (이름 + 개인정보처리방침 동의)
    final isFirstPageValid = ref.watch(
      SignUpScreenState.isFirstPageValidProvider,
    );

    // 두 번째 페이지 유효성 검사 (이메일)
    final isSecondPageValid = ref.watch(
      SignUpScreenState.isSecondPageValidProvider,
    );

    // 세 번째 페이지 유효성 검사 (비밀번호)
    final isThirdPageValid = ref.watch(
      SignUpScreenState.isThirdPageValidProvider,
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 30,
        bottom: AppSize.responsiveBottomInset,
        left: 16,
        right: 16,
      ),
      child: switch (pageIndex) {
        0 => _buildFirstPageButton(isEnabled: isFirstPageValid),
        1 => _buildSecondPageButton(isEnabled: isSecondPageValid),
        2 => _buildThirdPageButton(ref: ref, isEnabled: isThirdPageValid),
        _ => const SizedBox.shrink(),
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
        // 다음 페이지 이동
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
  Widget _buildThirdPageButton({
    required WidgetRef ref,
    required bool isEnabled,
  }) {
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
            onTapped: () {
              signUp(ref);
            },
          ),
        ),
      ],
    );
  }
}
