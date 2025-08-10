import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/router/router.dart';

abstract class SnackBarService {
  SnackBarService._();

  static void showSnackBar(String text) {
    ScaffoldMessenger.of(
      rootNavigatorKey.currentContext!,
    ).hideCurrentSnackBar();
    ScaffoldMessenger.of(rootNavigatorKey.currentContext!).clearSnackBars();
    ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        duration: const Duration(milliseconds: 800),
        content: AppText(
          text: text,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          textColor: Colors.white,
        ),
      ),
    );
  }
}
