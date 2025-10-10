import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/notification/notification_service.dart';
import 'package:with_calendar/domain/entities/menu/menu_item.dart';

/// 메뉴 화면의 상태
abstract class MenuScreenState {
  /// 메뉴 리스트
  static final menuListProvider = StateProvider.autoDispose<List<Menu>>((ref) {
    return Menu.signInStatusList;
  });

  /// 알림 토글 상태
  static final notificationEnabledProvider =
      StateProvider<bool>((ref) {
    return false;
  });
}
