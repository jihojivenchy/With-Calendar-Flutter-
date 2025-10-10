import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/utils/constants/image_paths.dart';

class AppSearchBar extends HookWidget {
  const AppSearchBar({
    super.key,
    required this.placeholder,
    required this.controller,
    required this.onSearch,
  });

  final String placeholder;
  final TextEditingController controller;
  final Function(String userCode) onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: AppSize.deviceWidth,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Center(
          child: TextField(
            autofocus: true,
            controller: controller,
            style: TextStyle(
              color: AppColors.gray800,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: AppColors.gray800,
            cursorHeight: 20,
            maxLines: 1,
            textAlignVertical: TextAlignVertical.center,
            onSubmitted: (keyword) {
              // 검색어가 비어있으면 return
              if (keyword.isEmpty) {
                SnackBarService.showSnackBar('검색어를 입력해주세요');
                return;
              }

              onSearch(keyword);
            },
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              prefixIcon: IconButton(
                onPressed: () {
                  final keyword = controller.text;
                  if (keyword.isEmpty) {
                    SnackBarService.showSnackBar('검색어를 입력해주세요');
                    return;
                  }
                  onSearch(keyword);
                },
                icon: const Icon(Icons.search, color: Color(0xFF727577)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
