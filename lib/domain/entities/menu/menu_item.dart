import 'package:flutter/material.dart';

enum MenuType {
  profile,
  displayMode,
  notification,
  notificationList,
  feedback,
  privacyPolicy,
  signIn,
  signOut,
}

class Menu {
  final MenuType type;
  final String title;
  final IconData icon;

  const Menu({required this.type, required this.title, required this.icon});

  ///
  /// 로그인 상태일 때 메뉴 리스트
  ///
  static List<Menu> signInStatusList = [
    const Menu(
      type: MenuType.profile,
      title: '프로필 설정',
      icon: Icons.person_outline,
    ),
    const Menu(
      type: MenuType.displayMode,
      title: '화면 모드',
      icon: Icons.display_settings_outlined,
    ),
    const Menu(
      type: MenuType.notification,
      title: '알림 설정',
      icon: Icons.notifications_outlined,
    ),
    const Menu(
      type: MenuType.notificationList,
      title: '알림 리스트',
      icon: Icons.list_alt_outlined,
    ),
    const Menu(
      type: MenuType.feedback,
      title: '피드백',
      icon: Icons.feedback_outlined,
    ),
    const Menu(
      type: MenuType.privacyPolicy,
      title: '개인정보처리방침',
      icon: Icons.privacy_tip_outlined,
    ),
    const Menu(
      type: MenuType.signOut,
      title: '로그아웃',
      icon: Icons.logout_outlined,
    ),
  ];

  ///
  /// 로그아웃 상태일 때 메뉴 리스트
  ///
  static List<Menu> signOutStatusList = [
    const Menu(
      type: MenuType.displayMode,
      title: '화면 모드',
      icon: Icons.display_settings_outlined,
    ),  
    const Menu(
      type: MenuType.notification,
      title: '알림 설정',
      icon: Icons.notifications_outlined,
    ),
    const Menu(
      type: MenuType.notificationList,
      title: '알림 리스트',
      icon: Icons.list_alt_outlined,
    ),
    const Menu(
      type: MenuType.feedback,
      title: '피드백',
      icon: Icons.feedback_outlined,
    ),
    const Menu(
      type: MenuType.privacyPolicy,
      title: '개인정보처리방침',
      icon: Icons.privacy_tip_outlined,
    ),
    const Menu(
      type: MenuType.signIn,
      title: '로그인',
      icon: Icons.login_outlined,
    ),
  ];
}
