import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../../domain/entities/memo/memo.dart';
import '../../../../design_system/component/app_bar/app_bar.dart';
import '../../../../design_system/component/bottom_sheet/color_picker_bottom_sheet.dart';
import '../../../../design_system/component/text/app_text.dart';
import '../../../../design_system/foundation/app_color.dart';

class UpdateMemoScreen extends StatefulWidget {
  const UpdateMemoScreen({super.key, required this.memo});

  final Memo memo;

  @override
  State<UpdateMemoScreen> createState() => _UpdateMemoScreenState();
}

class _UpdateMemoScreenState extends State<UpdateMemoScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late bool isPinned;
  late Color pinColor;

  bool isTitleEditing = false;
  bool isContentEditing = false;

  final FocusNode titleFocusNode = FocusNode();
  final FocusNode contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    contentController = TextEditingController(text: widget.memo.content);
    isPinned = widget.memo.isPinned;
    pinColor = widget.memo.pinColor;

    // 포커스 리스너 설정
    titleFocusNode.addListener(() {
      if (!titleFocusNode.hasFocus) {
        setState(() {
          isTitleEditing = false;
        });
      }
    });

    contentFocusNode.addListener(() {
      if (!contentFocusNode.hasFocus) {
        setState(() {
          isContentEditing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  void showColorPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ColorPickerBottomSheet(
          selectedColor: pinColor,
          onColorSelected: (Color color) {
            setState(() {
              pinColor = color;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(title: '메모 수정'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 섹션
              _buildTitleSection(),
              const SizedBox(height: 24),

              // 내용 섹션
              _buildContentSection(),
              const SizedBox(height: 24),

              // 핀 설정 섹션
              _buildPinSection(),
              const SizedBox(height: 16),

              // 작성 날짜
              AppText(
                text: '작성일: ${widget.memo.createdAt}',
                fontSize: 12,
                textColor: AppColors.color727577,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(text: '제목', fontSize: 16, fontWeight: FontWeight.w600),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              isTitleEditing = true;
            });
            titleFocusNode.requestFocus();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isTitleEditing ? Colors.white : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isTitleEditing
                    ? AppColors.primary
                    : Colors.grey.shade200,
                width: isTitleEditing ? 2 : 1,
              ),
            ),
            child: isTitleEditing
                ? TextField(
                    controller: titleController,
                    focusNode: titleFocusNode,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '제목을 입력하세요',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : AppText(
                    text: titleController.text.isEmpty
                        ? '제목을 입력하세요'
                        : titleController.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textColor: titleController.text.isEmpty
                        ? Colors.grey
                        : Colors.black,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(text: '내용', fontSize: 16, fontWeight: FontWeight.w600),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              isContentEditing = true;
            });
            contentFocusNode.requestFocus();
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isContentEditing ? Colors.white : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isContentEditing
                    ? AppColors.primary
                    : Colors.grey.shade200,
                width: isContentEditing ? 2 : 1,
              ),
            ),
            child: isContentEditing
                ? TextField(
                    controller: contentController,
                    focusNode: contentFocusNode,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '내용을 입력하세요',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : AppText(
                    text: contentController.text.isEmpty
                        ? '내용을 입력하세요'
                        : contentController.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    textColor: contentController.text.isEmpty
                        ? Colors.grey
                        : Colors.black,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(text: '중요 설정', fontSize: 16, fontWeight: FontWeight.w600),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  isPinned = !isPinned;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isPinned
                      ? pinColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPinned ? pinColor : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: isPinned ? pinColor : Colors.grey.shade600,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                text: isPinned ? '중요한 메모로 설정됨' : '중요한 메모로 설정',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textColor: isPinned ? pinColor : Colors.grey.shade600,
              ),
            ),
            if (isPinned) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: showColorPicker,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: pinColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
