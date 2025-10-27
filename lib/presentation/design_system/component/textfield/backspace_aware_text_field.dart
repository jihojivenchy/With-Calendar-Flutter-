import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

import 'app_textfield.dart';

// IME가 백스페이스 키 이벤트를 전달하지 않는 환경에서도 안정적으로
// 마지막 항목 삭제를 감지하기 위해 텍스트 앞에 숨겨진 문자를 주입한다.
// 해당 문자는 외부 노출 시 제거해야 하므로 아래 함수를 통해 정리한다.
const String _kZeroWidthSpace = '\u200B';

/// 숨겨진 문자(Zero Width Space)를 제거한 실제 입력 값을 반환한다.
String sanitizeBackspaceAwareText(String text) =>
    text.replaceAll(_kZeroWidthSpace, '');

String _plainTextFromValue(TextEditingValue value) =>
    sanitizeBackspaceAwareText(value.text);

/// 백스페이스 시그널을 안전하게 캡처하는 AppTextField 래퍼 위젯.
class BackspaceAwareTextField extends StatefulWidget {
  const BackspaceAwareTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onBackspaceWhenEmpty,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onBackspaceWhenEmpty;

  @override
  State<BackspaceAwareTextField> createState() =>
      _BackspaceAwareTextFieldState();
}

class _BackspaceAwareTextFieldState extends State<BackspaceAwareTextField> {
  late final TextInputFormatter _formatter;
  bool _isNormalizing = false;

  @override
  void initState() {
    super.initState();
    _formatter = TextInputFormatter.withFunction(_handleFormatUpdate);
    widget.controller.addListener(_normalizeControllerValue);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _normalizeControllerValue(),
    );
  }

  @override
  void didUpdateWidget(covariant BackspaceAwareTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_normalizeControllerValue);
      widget.controller.addListener(_normalizeControllerValue);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _normalizeControllerValue(),
      );
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_normalizeControllerValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<TextInputFormatter> formatters = <TextInputFormatter>[
      _formatter,
    ];

    return AppTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      placeholderText: '할 일을 입력해주세요',
      cursorColor: context.textColor,
      backgroundColor: Colors.transparent,
      borderColor: Colors.transparent,
      focusedBorderColor: Colors.transparent,
      textInputAction: TextInputAction.next,
      onSubmitted: (value) =>
          widget.onSubmitted?.call(sanitizeBackspaceAwareText(value)),
      inputFormatters: formatters,
    );
  }

  TextEditingValue _handleFormatUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String oldPlain = _plainTextFromValue(oldValue);
    final String newPlain = _plainTextFromValue(newValue);

    // 기존 텍스트가 비어 있는 상태에서 또다시 백스페이스를 누르면
    // 사용자가 아이템 제거를 원한 것으로 판단하고 콜백을 호출한다.
    final bool selectionMovedBack =
        newValue.selection.baseOffset < oldValue.selection.baseOffset ||
        newValue.selection.extentOffset < oldValue.selection.extentOffset;
    final bool attemptedToDeleteSentinel =
        oldPlain.isEmpty &&
        newPlain.isEmpty &&
        (newValue.text.length < oldValue.text.length || selectionMovedBack);

    if (attemptedToDeleteSentinel) {
      widget.onBackspaceWhenEmpty?.call();
      return _ensureSentinel(oldValue);
    }

    return _ensureSentinel(newValue);
  }

  void _normalizeControllerValue() {
    if (_isNormalizing) {
      return;
    }

    final TextEditingValue currentValue = widget.controller.value;
    final TextEditingValue normalized = _ensureSentinel(currentValue);

    if (normalized == currentValue) {
      return;
    }

    _isNormalizing = true;
    widget.controller.value = normalized;
    _isNormalizing = false;
  }

  TextEditingValue _ensureSentinel(TextEditingValue value) {
    // controller에는 항상 선행 제로 폭 문자를 유지해 백스페이스 시도를 감지한다.
    final String plainText = sanitizeBackspaceAwareText(value.text);
    final String textWithSentinel = '$_kZeroWidthSpace$plainText';
    final bool hadSentinel = value.text.startsWith(_kZeroWidthSpace);
    final int plainLength = plainText.length;

    int normalizeOffset(int offset) {
      if (offset < 0) {
        return offset;
      }

      final int plainOffset = offset - (hadSentinel ? 1 : 0);
      final int clamped = plainOffset < 0
          ? 0
          : (plainOffset > plainLength ? plainLength : plainOffset);
      return clamped + 1;
    }

    TextSelection normalizeSelection(TextSelection selection) {
      return TextSelection(
        baseOffset: normalizeOffset(selection.baseOffset),
        extentOffset: normalizeOffset(selection.extentOffset),
        affinity: selection.affinity,
        isDirectional: selection.isDirectional,
      );
    }

    TextRange normalizeComposing(TextRange range) {
      if (!range.isValid || range.isCollapsed) {
        return TextRange.empty;
      }

      final int start = normalizeOffset(range.start);
      final int end = normalizeOffset(range.end);
      return TextRange(start: start, end: end);
    }

    return TextEditingValue(
      text: textWithSentinel,
      selection: normalizeSelection(value.selection),
      composing: normalizeComposing(value.composing),
    );
  }
}

/// 컨트롤러에 숨겨진 문자가 포함되어 있어도 안전하게 텍스트를 읽는다.
String backspaceAwareControllerText(TextEditingController controller) =>
    sanitizeBackspaceAwareText(controller.text);
