import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/utils/constants/image_paths.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double fontSize;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool isShowBackButton;
  final bool isDivider;
  final Color backgroundColor;
  final double height;

  const DefaultAppBar({
    super.key,
    required this.title,
    this.fontSize = 16,
    this.actions,
    this.onBackPressed,
    this.isShowBackButton = true,
    this.isDivider = false,
    this.backgroundColor = Colors.white,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      toolbarHeight: height,
      surfaceTintColor: backgroundColor,
      backgroundColor: backgroundColor,
      titleSpacing: -10,
      title: AppText(text: title, fontSize: fontSize),
      leading: isShowBackButton
          ? IconButton(
              icon: Image.asset(ImagePaths.arrowLeft, width: 20, height: 20),
              iconSize: 20,
              onPressed: onBackPressed ?? () => context.pop(),
            )
          : const SizedBox(width: 10),
      leadingWidth: isShowBackButton ? null : 30,
      actions: actions,
      bottom: isDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: const Color(0xFFD2D5D7), height: 1.0),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
