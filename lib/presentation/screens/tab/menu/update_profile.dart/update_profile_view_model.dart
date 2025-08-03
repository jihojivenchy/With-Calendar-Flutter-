// import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:with_calendar/data/services/auth/auth_service.dart';
// import 'package:with_calendar/data/services/menu/menu_service.dart';
// import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
// import 'package:with_calendar/domain/entities/profile/profile.dart';
// import 'package:with_calendar/presentation/common/type/screen_state.dart';
// import 'package:with_calendar/presentation/router/router.dart';
// import 'package:with_calendar/utils/services/random/random_generator.dart';
// import 'package:with_calendar/utils/services/snack_bar/snack_bar_service.dart';

// /// 프로필 수정 뷰모델 provider
// final updateProfileViewModelProvider =
//     StateNotifierProvider.autoDispose<
//       UpdateProfileViewModel,
//       UpdateProfileScreenState
//     >((ref) {
//       return UpdateProfileViewModel();
//     });

// /// 프로필 업데이트 화면 상태
// class UpdateProfileScreenState {
//   final ScreenState screenState;
//   final Profile? profile;

//   UpdateProfileScreenState({required this.screenState, required this.profile});

//   UpdateProfileScreenState copyWith({
//     ScreenState? screenState,
//     Profile? profile,
//   }) {
//     return UpdateProfileScreenState(
//       screenState: screenState ?? this.screenState,
//       profile: profile ?? this.profile,
//     );
//   }

//   bool get isValidate => profile?.name != null && profile!.name.isNotEmpty;

//   /// 초기 상태
//   static UpdateProfileScreenState get initialState =>
//       UpdateProfileScreenState(screenState: ScreenState.loading, profile: null);
// }

// /// 프로필 업데이트 뷰모델
// class UpdateProfileViewModel extends StateNotifier<UpdateProfileScreenState> {
//   UpdateProfileViewModel() : super(UpdateProfileScreenState.initialState) {
//     fetchProfile();
//   }

//   /// 메뉴 서비스
//   final MenuService _menuService = MenuService();

//   /// 프로필 조회
//   Future<void> fetchProfile() async {
//     try {
//       final profile = await _menuService.fetchProfile();
//       state = state.copyWith(
//         screenState: ScreenState.success,
//         profile: profile,
//       );
//     } catch (e) {
//       log(e.toString());
//       SnackBarService.showSnackBar('프로필 조회 실패: ${e.toString()}');
//       state = state.copyWith(screenState: ScreenState.error);
//     }
//   }

//   ///
//   /// 유저 고유 코드 변경
//   ///
//   void updateUserCode() {
//     final newCode = RandomGenerator.generateUserCode();
//     state = state.copyWith(profile: state.profile?.copyWith(code: newCode));
//   }

//   ///
//   /// 유저 이름 변경
//   ///
//   void updateName(String name) {
//     state = state.copyWith(profile: state.profile?.copyWith(name: name));
//   }

//   ///
//   /// 프로필 수정
//   ///
//   Future<bool> updateProfile() async {
//     try {
//       await _menuService.updateProfile(state.profile!);
//       SnackBarService.showSnackBar('프로필 수정 완료');
//       return true;
//     } catch (e) {
//       log(e.toString());
//       SnackBarService.showSnackBar('프로필 수정 실패: ${e.toString()}');
//       return false;
//     }
//   }
// }
