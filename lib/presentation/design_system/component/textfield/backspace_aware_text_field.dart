import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

import 'app_textfield.dart';

abstract class BackspaceAwareHelper {
  // 보이지 않는 문자
  static const String _kZeroWidthSpace = '\u200B';

  /// sentinel을 제거한 "실제 텍스트"만 남기는 메서드
  static String sanitizeBackspaceAwareText(String text) =>
      text.replaceAll(_kZeroWidthSpace, '');
}

/// 백스페이스 감지 텍스트필드
/// -------------------------
/// 일부 IME(한글/일본어 등 조합형 입력기 포함) 환경에서는
/// 텍스트가 비어 있을 때 백스페이스를 눌러도 프레임워크에 "삭제" 입력이 오지 않아
/// "마지막 아이템을 지우고 싶다" 같은 제스처를 감지하기 어렵습니다.
/// 이를 해결하기 위해, 입력이 완전히 비어 있을 때만 '보이지 않는 문자(Zero Width Space)'를
/// 텍스트에 잠시 넣어둡니다(센티넬, sentinel).
/// 사용자가 이 sentinel을 지우려고(backspace) 시도하면 "비었는데 또 지웠네!"를 감지하여
/// onBackspaceWhenEmpty 콜백을 호출합니다.
///
/// 단, 이 sentinel은 외부 노출(서버 저장, UI 표시 등) 시 반드시 제거해야 하므로
/// sanitizeBackspaceAwareText 로 감싸서 실제 값을 사용하도록 합니다.
///
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
  // 입력 변화마다 호출되는 포맷터.
  late final TextInputFormatter _formatter;

  // 컨트롤러 값을 정규화하는 중인지 플래그(무한 루프 방지).
  bool _isNormalizing = false;

  @override
  void initState() {
    super.initState();

    // 포맷터에서 old/new 값을 비교하며 백스페이스 시도를 감지.
    _formatter = TextInputFormatter.withFunction(_handleFormatUpdate);

    // 컨트롤러 값이 외부에서 바뀌어도(프로그램적으로 set) 항상 sentinel 규칙을 맞추기 위해 리스너 등록.
    widget.controller.addListener(_normalizeControllerValue);

    // 첫 프레임 이후 현재 값도 규칙에 맞춰 정규화(초기 상태에서 공백이면 sentinel 주입 등).
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _normalizeControllerValue(),
    );
  }

  @override
  void didUpdateWidget(covariant BackspaceAwareTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 부모가 controller 인스턴스를 교체했을 때 리스너를 옮겨줌(메모리 누수/중복 방지).
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_normalizeControllerValue);
      widget.controller.addListener(_normalizeControllerValue);

      // 새 컨트롤러 값도 규칙에 맞추어 정규화.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _normalizeControllerValue(),
      );
    }
  }

  @override
  void dispose() {
    // 리스너 제거
    widget.controller.removeListener(_normalizeControllerValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      placeholderText: '할 일을 입력해주세요',
      cursorColor: context.textColor,
      backgroundColor: Colors.transparent,
      borderColor: Colors.transparent,
      focusedBorderColor: Colors.transparent,
      textInputAction: TextInputAction.next,
      onSubmitted: (value) => widget.onSubmitted?.call(
        BackspaceAwareHelper.sanitizeBackspaceAwareText(value),
      ),
      inputFormatters: [_formatter],
    );
  }

  /// 포맷터 콜백: 사용자의 입력 전/후(old/new)를 비교해
  /// "비어있는데도 삭제를 시도"했는지 감지하고, 값은 항상 정규화해서 반환합니다.
  TextEditingValue _handleFormatUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // sentinel 제거한 "실제 텍스트"로 변환
    final String oldPlain = BackspaceAwareHelper.sanitizeBackspaceAwareText(
      oldValue.text,
    );
    final String newPlain = BackspaceAwareHelper.sanitizeBackspaceAwareText(
      newValue.text,
    );

    // selection 이동이 뒤로 갔는지(좌측으로 이동 = 백스페이스와 유사한 동작) 체크
    final bool selectionMovedBack =
        newValue.selection.baseOffset < oldValue.selection.baseOffset ||
        newValue.selection.extentOffset < oldValue.selection.extentOffset;

    // 조건: (1) 이전/이후 모두 실제 텍스트는 비어 있음
    //      (2) 텍스트 길이가 줄었거나(selection이 뒤로 갔거나)
    // 즉, 화면상 비었는데 사용자가 또 지우려고 했다면 백스페이스 시도로 판단.
    final bool attemptedToDeleteSentinel =
        oldPlain.isEmpty &&
        newPlain.isEmpty &&
        (newValue.text.length < oldValue.text.length || selectionMovedBack);

    // 백스페이스 시도 판단
    if (attemptedToDeleteSentinel) {
      // 백스페이스 시도 콜백 호출
      widget.onBackspaceWhenEmpty?.call();

      // 실제 값 변경은 하지 않고, oldValue를 정규화해서 되돌림
      return _normalizeValue(oldValue);
    }

    // 일반 입력 흐름: newValue를 규칙대로 정규화(sentinel 주입/제거, selection/조합영역 보정).
    return _normalizeValue(newValue);
  }

  /// 컨트롤러 값이 외부에서 set 되었을 때도 항상 규칙을 유지하도록 정규화.
  void _normalizeControllerValue() {
    if (_isNormalizing) {
      // 정규화 과정 중 다시 정규화를 부르는 루프 방지.
      return;
    }

    final TextEditingValue currentValue = widget.controller.value;
    final TextEditingValue normalized = _normalizeValue(currentValue);

    // 이미 규칙을 만족하면 아무것도 하지 않음.
    if (normalized == currentValue) return;

    // 정규화 처리
    _isNormalizing = true;
    widget.controller.value = normalized;
    _isNormalizing = false;
  }

  /// 값 정규화
  /// - 입력이 "정말 비어 있고(plainLength == 0) 조합 중이 아닐 때"만 sentinel을 유지/주입
  /// - 그 외엔 sentinel 제거
  /// - selection(커서)와 composing(조합 영역)도 sentinel 유무에 맞춰 정확히 재계산
  TextEditingValue _normalizeValue(TextEditingValue value) {
    // 현재 값이 sentinel로 시작하는지 체크(이전 프레임에서 주입했을 수 있음)
    final bool hadSentinel = value.text.startsWith(
      BackspaceAwareHelper._kZeroWidthSpace,
    );

    // sentinel 제거한 실제 텍스트
    final String plainText = BackspaceAwareHelper.sanitizeBackspaceAwareText(
      value.text,
    );
    final int plainLength = plainText.length;

    // 한글/일본어 등 조합 중인지 여부
    final bool isComposing =
        value.composing.isValid && !value.composing.isCollapsed;

    // 조합 중에는 sentinel이 있으면 조합을 방해할 수 있으므로 제거.
    // 조합이 아니면서 실제 텍스트가 비어 있을 때만 sentinel 유지(또는 주입).
    final bool keepSentinel = !isComposing && plainLength == 0;

    // 최종 텍스트 결정: sentinel을 유지할지, 아니면 실제 텍스트만 둘지
    final String normalizedText = keepSentinel
        ? BackspaceAwareHelper._kZeroWidthSpace
        : plainText;

    // selection과 composing의 인덱스는 텍스트 길이에 의존하므로,
    // sentinel의 유무(길이 +1/ -1)만큼 보정이 필요.
    int normalizeOffset(int offset) {
      if (offset < 0) {
        // -1 같은 값은 의미 그대로 유지(플러터 내부에서 가끔 사용).
        return offset;
      }

      // 이전 값에 sentinel이 있었다면, 기존 오프셋에서 sentinel 1글자를 제거해 plain 기준으로 변환.
      final int sentinelDelta = hadSentinel ? 1 : 0;
      int plainOffset = offset - sentinelDelta;

      // plain 텍스트 범위로 클램핑
      if (plainOffset < 0) {
        plainOffset = 0;
      } else if (plainOffset > plainLength) {
        plainOffset = plainLength;
      }

      // 이번 프레임에 sentinel을 유지한다면 다시 +1 해서 화면 텍스트 기준 오프셋으로 환산.
      return keepSentinel ? plainOffset + 1 : plainOffset;
    }

    // selection(커서/드래그 영역) 보정
    TextSelection normalizeSelection(TextSelection selection) {
      return TextSelection(
        baseOffset: normalizeOffset(selection.baseOffset),
        extentOffset: normalizeOffset(selection.extentOffset),
        affinity: selection.affinity,
        isDirectional: selection.isDirectional,
      );
    }

    // composing(조합 영역) 보정: 유효하지 않거나 접혀 있으면 비움.
    TextRange normalizeComposing(TextRange range) {
      if (!range.isValid || range.isCollapsed) {
        return TextRange.empty;
      }
      final int start = normalizeOffset(range.start);
      final int end = normalizeOffset(range.end);
      return TextRange(start: start, end: end);
    }

    // 최종적으로 보정된 텍스트/selection/조합영역을 합쳐 반환.
    return TextEditingValue(
      text: normalizedText,
      selection: normalizeSelection(value.selection),
      composing: normalizeComposing(value.composing),
    );
  }
}
