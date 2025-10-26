import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/data/services/calendar/calendar_range_service.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/splash/splash_screen_event.dart';
import 'package:with_calendar/utils/constants/image_paths.dart';
import 'package:with_calendar/utils/extensions/image_extension.dart';

class SplashScreen extends BaseScreen with SplashScreenEvent {
  SplashScreen({super.key});

  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);
    Future.delayed(const Duration(seconds: 2), () {
      checkLoginStatus(ref);
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(
      title: '',
      isShowBackButton: false,
      backgroundColor: context.whiteAndBlack,
    );
  }

  @override
  bool get extendBodyBehindAppBar => true;

  @override
  bool get wrapWithSafeArea => false;

  @override
  Color? backgroundColor(BuildContext context) {
    return context.whiteAndBlack;
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Image.asset(
          ImagePaths.logo,
          width: 300.cacheSize(context).toDouble(),
          cacheWidth: 500.cacheSize(context),
        ),
      ),
    );
  }
}
