import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class AppDialog extends Dialog {
  const AppDialog({
    super.key,
    this.isDoubleButton = false, // 버튼을 분할 형식으로 표시할지 여부
    this.subTitle, // 부제목 텍스트
    this.onLeftBtnClicked, // 왼쪽 버튼 클릭 콜백
    required this.leftBtnText, // 왼쪽 버튼 텍스트
    this.leftBtnColor = AppColors.colorf4f7f9,
    this.rightBtnColor = AppColors.primary,
    required this.rightBtnText, // 오른쪽 버튼 텍스트
    required this.onRightBtnClicked, // 오른쪽 버튼 클릭 콜백
    required this.title, // 제목 텍스트
  });

  /// 단일 버튼 형식의 다이얼로그 생성자
  factory AppDialog.singleBtn({
    required String title,
    required VoidCallback onBtnClicked,
    String? subTitle,
    required String btnContent,
  }) => AppDialog(
    title: title,
    subTitle: subTitle,
    onRightBtnClicked: onBtnClicked,
    leftBtnText: '',
    rightBtnText: btnContent,
  );

  /// 분할 버튼 형식의 다이얼로그 생성자
  factory AppDialog.doubleBtn({
    required String title,
    String? subTitle,
    required String leftBtnContent,
    required String rightBtnContent,
    Color? leftBtnColor,
    Color? rightBtnColor,
    required VoidCallback onRightBtnClicked,
    required VoidCallback onLeftBtnClicked,
  }) => AppDialog(
    isDoubleButton: true,
    title: title,
    subTitle: subTitle,
    onRightBtnClicked: onRightBtnClicked,
    onLeftBtnClicked: onLeftBtnClicked,
    leftBtnText: leftBtnContent,
    rightBtnText: rightBtnContent,
    leftBtnColor: leftBtnColor ?? AppColors.colorf4f7f9,
    rightBtnColor: rightBtnColor ?? AppColors.color7c3aed,
  );

  final bool isDoubleButton;
  final String title;
  final VoidCallback onRightBtnClicked;
  final VoidCallback? onLeftBtnClicked;
  final String rightBtnText;
  final String leftBtnText;
  final String? subTitle;
  final Color leftBtnColor;
  final Color rightBtnColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(163, 163, 179, 0.07),
              blurRadius: 65,
              offset: Offset(0, 5),
            ),
            BoxShadow(
              color: Color.fromRGBO(163, 163, 179, 0.07),
              blurRadius: 20,
              offset: Offset(0, 5.86471),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /// Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AppText(
                text: title,
                textAlign: TextAlign.center,
                fontSize: 20,
              ),
            ),

            /// Sub Title
            if (subTitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AppText(
                  text: subTitle!,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.color727577,
                  textAlign: TextAlign.center,
                ),
              ),

            // Buttons
            const SizedBox(height: 20),
            Row(
              children: [
                if (isDoubleButton) ...[
                  Expanded(
                    child: AppButton(
                      text: leftBtnText,
                      onTapped: onLeftBtnClicked ?? () {},
                      height: 40,
                      backgroundColor: leftBtnColor,
                      textColor: AppColors.color727577,
                      borderRadius: 4,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: AppButton(
                    text: rightBtnText,
                    onTapped: onRightBtnClicked,
                    height: 40,
                    backgroundColor: rightBtnColor,
                    borderRadius: 4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
