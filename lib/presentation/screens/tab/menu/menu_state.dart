

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/menu/menu_item.dart';
import 'package:with_calendar/presentation/common/type/screen_state.dart';

/// 메뉴 화면의 상태
abstract class MenuState {
  /// 메뉴 리스트
  static final menuListProvider = StateProvider.autoDispose<List<Menu>>((
    ref,
  ) {
    return Menu.signInStatusList;
  });
}
