import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

///
/// 일정 메모 뷰
///
class ScheduleMemoView extends HookWidget {
  const ScheduleMemoView({
    super.key,
    required this.memo,
    this.lineColor = AppColors.primary,
    required this.onMemoChanged,
    required this.onExpansionChanged,
  });

  final String memo;
  final Color lineColor;
  final Function(String memo) onMemoChanged;
  final VoidCallback onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 5),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.symmetric(vertical: 10),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.create, color: lineColor, size: 20),
            const SizedBox(width: 15),
            AppText(
              text: '메모',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: lineColor,
            ),
            const SizedBox(width: 30),
            Expanded(
              child: AppText(
                text: memo,
                textAlign: TextAlign.end,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                textColor: lineColor,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        trailing: const SizedBox.shrink(),
        showTrailingIcon: false,
        onExpansionChanged: (isExpanded) {
          if (isExpanded) {
            focusNode.requestFocus();
            onExpansionChanged();
          } else {
            focusNode.unfocus();
          }
        },
        children: [_buildMemoTextField(focusNode)],
      ),
    );
  }

  ///
  /// 메모 입력 텍스트 필드
  ///
  Widget _buildMemoTextField(FocusNode focusNode) {
    return AppTextField(
      focusNode: focusNode,
      initialValue: memo,
      placeholderText: '메모 입력',
      maxLines: 5,
      focusedBorderColor: lineColor,
      cursorColor: lineColor,
      onTextChanged: onMemoChanged,
    );
  }
}
