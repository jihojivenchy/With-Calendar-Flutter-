import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/memo/memo_creation.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/color_picker_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/screens/tab/memo/create/provider/create_memo_view_model.dart';
import 'package:with_calendar/presentation/screens/tab/memo/create/widgets/color_picker_button.dart';

class CreateMemoScreen extends ConsumerStatefulWidget {
  const CreateMemoScreen({super.key});

  @override
  ConsumerState<CreateMemoScreen> createState() => _CreateMemoScreenState();
}

class _CreateMemoScreenState extends ConsumerState<CreateMemoScreen> {
  Future<void> _createMemo() async {
    FocusScope.of(context).unfocus();

    final isSuccess = await ref
        .read(createMemoViewModelProvider.notifier)
        .createMemo();

    if (isSuccess && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: DefaultAppBar(
        title: '메모 작성',
        backgroundColor: const Color(0xFFF2F2F7),
        actions: [_buildColorPickerButton(), const SizedBox(width: 16)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Expanded(
                child: AppTextField(
                  autoFocus: true,
                  placeholderText: '내용을 입력하세요',
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  backgroundColor: Colors.white,
                  borderColor: Colors.transparent,
                  onTextChanged: (content) {
                    ref
                        .read(createMemoViewModelProvider.notifier)
                        .updateContent(content);
                  },
                ),
              ),
              _buildCompletionButton(),
            ],
          ),
        ),
      ),
    );
  }

  ///
  /// 핀 색상 선택 버튼
  ///
  Widget _buildColorPickerButton() {
    return Consumer(
      builder: (context, ref, child) {
        final memo = ref.watch(createMemoViewModelProvider).memo;

        return ColorPickerButton(
          isPinned: memo.isPinned,
          onTapped: () {
            final isPinned = !memo.isPinned;
            ref
                .read(createMemoViewModelProvider.notifier)
                .updatePinState(isPinned: isPinned);

            // 핀 Color Picker 표시
            if (isPinned) {
              _showColorPickerBottomSheet(memo.pinColor);
            }
          },
          pinColor: memo.pinColor,
        );
      },
    );
  }

  ///
  /// 컬러 피커 바텀시트
  ///
  void _showColorPickerBottomSheet(Color pinColor) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ColorPickerBottomSheet(
          selectedColor: pinColor,
          onColorSelected: (color) {
            Navigator.pop(context);
            ref
                .read(createMemoViewModelProvider.notifier)
                .updatePinState(pinColor: color);
          },
        );
      },
    );
  }

  ///
  /// 메모 작성 텍스트 필드
  ///
  Widget _buildCompletionButton() {
    return Consumer(
      builder: (context, ref, child) {
        final isValidate = ref.watch(
          createMemoViewModelProvider.select((state) => state.isValidate),
        );

        return Padding(
          padding: EdgeInsets.only(
            top: 30,
            bottom: AppSize.responsiveBottomInset,
          ),
          child: AppButton(
            isEnabled: isValidate,
            text: '완료',
            onTapped: _createMemo,
          ),
        );
      },
    );
  }
}
