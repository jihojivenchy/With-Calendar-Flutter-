import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/common/type/screen_state.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/component/view/error_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/screens/tab/menu/update_profile.dart/update_profile_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/menu/update_profile.dart/update_profile_screen_state.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class UpdateProfileScreen extends BaseScreen with UpdateProfileScreenEvent {
  UpdateProfileScreen({super.key});

  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 프로필 조회
      fetchProfile(ref);
    });
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildScreen(ref),
    );
  }

  ///
  /// 배경색
  ///
  @override
  Color? get backgroundColor => const Color(0xFFF2F2F7);

  ///
  /// 앱 바 구성
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(
      title: '프로필 수정',
      backgroundColor: const Color(0xFFF2F2F7),
      actions: [
        // 회원 탈퇴
        GestureDetector(
          onTap: () {},
          child: const AppText(
            text: '탈퇴',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            textColor: Color(0xFFF00000),
            textDecoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  ///
  /// 화면 상태에 따른 처리
  ///
  Widget _buildScreen(WidgetRef ref) {
    final screenState = ref.watch(UpdateProfileScreenState.screenStateProvider);

    return switch (screenState) {
      ScreenState.loading => const LoadingView(title: '프로필 정보를 불러오는 중입니다.'),
      ScreenState.empty => const SizedBox.shrink(),
      ScreenState.success => _buildContentView(ref),
      ScreenState.error => ErrorView(
        title: '조회 중 오류가 발생했습니다.',
        onRetryBtnTapped: () {
          // 프로필 다시 조회
          fetchProfile(ref);
        },
      ),
    };
  }

  ///
  /// 컨텐츠 뷰
  ///
  Widget _buildContentView(WidgetRef ref) {
    final profile = ref.watch(UpdateProfileScreenState.profileProvider);
    log('profile 데이터 갱신 완료: ${profile?.name}');

    if (profile == null) {
      return ErrorView(
        title: '조회 중 오류가 발생했습니다.',
        onRetryBtnTapped: () {
          // 프로필 조회
          fetchProfile(ref);
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 프로필 정보 입력 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 이메일
                  _buildReadOnlyField(title: '이메일', value: profile.email),
                  const SizedBox(height: 24),
    
                  // 이름
                  AppText(
                    text: '이름',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    textColor: Colors.black,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    initialValue: profile.name,
                    placeholderText: '이름을 입력하세요',
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    borderRadius: 16,
                    borderColor: Colors.transparent,
                    backgroundColor: Colors.white,
                    onTextChanged: (name) => updateName(ref, name),
                  ),
                  const SizedBox(height: 24),
    
                  // 유저 코드
                  _buildUserCodeField(ref, profile.code),
                  const SizedBox(height: 24),
    
                  // 생성 날짜
                  _buildReadOnlyField(
                    title: '생성 날짜',
                    value: profile.createdAt.toAnotherDateFormat(),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
    
          // 수정 완료 버튼
          _buildUpdateButton(),
        ],
      ),
    );
  }

  ///
  /// 읽기 전용 필드
  ///
  Widget _buildReadOnlyField({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          textColor: Colors.black,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: AppText(
            text: value,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            textColor: AppColors.color727577,
          ),
        ),
      ],
    );
  }

  /// 코드/변경 버튼
  Widget _buildUserCodeField(WidgetRef ref, String userCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: '코드',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          textColor: Colors.black,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // 코드 표시
              Expanded(
                child: AppText(
                  text: userCode,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  textColor: const Color(0xFF000000),
                ),
              ),
              const SizedBox(width: 12),
              // 변경 버튼
              GestureDetector(
                onTap: () => updateUserCode(ref),
                child: AppText(
                  text: '변경',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 수정 완료 버튼
  Widget _buildUpdateButton() {
    return Consumer(
      builder: (context, ref, child) {
        // 유저 이름 유효성 검사
        final isValidate = ref.watch(
          UpdateProfileScreenState.profileValidationProvider,
        );

        return Padding(
          padding: EdgeInsets.only(bottom: AppSize.responsiveBottomInset),
          child: AppButton(
            text: '완료',
            isEnabled: isValidate,
            onTapped: () => updateProfile(ref),
          ),
        );
      },
    );
  }
}
