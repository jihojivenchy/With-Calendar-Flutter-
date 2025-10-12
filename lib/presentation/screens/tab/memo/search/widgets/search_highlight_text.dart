import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

///
/// 검색어 하이라이트 텍스트
///
class SearchHighlightText extends StatelessWidget {
  final String text;
  final String highlightText;
  final Color highlightColor;

  const SearchHighlightText({
    super.key,
    required this.text,
    required this.highlightText,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    // 검색어가 없거나 키워드에 포함되지 않는 경우 기본 텍스트를 반환합니다.
    if (highlightText.isEmpty || !text.contains(highlightText)) {
      return AppText(
        text: text,
        fontSize: 16,
        textColor: AppColors.gray800,
        fontWeight: FontWeight.w600,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // 검색어 주변 컨텍스트 추출
    final extractedText = _extractContextAroundKeyword(text, highlightText);

    final spans = <TextSpan>[];
    int startIndex = 0;
    int indexOfMatch;

    // 검색어와 일치하는 부분을 찾아 스타일을 적용
    while ((indexOfMatch = extractedText.indexOf(highlightText, startIndex)) !=
        -1) {
      // 일치하지 않는 부분을 추가
      if (indexOfMatch > startIndex) {
        spans.add(
          TextSpan(
            text: extractedText.substring(startIndex, indexOfMatch),
            style: TextStyle(
              color: context.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      // 일치하는 부분을 강조
      spans.add(
        TextSpan(
          text: highlightText,
          style: TextStyle(
            color: highlightColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

      startIndex = indexOfMatch + highlightText.length;
    }

    // 나머지 텍스트를 추가
    if (startIndex < extractedText.length) {
      spans.add(
        TextSpan(
          text: extractedText.substring(startIndex),
          style: TextStyle(
            color: context.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  ///
  /// 검색어 주변 컨텍스트 추출
  ///
  /// 검색어가 포함된 라인을 찾아 반환하거나,
  /// 라인이 너무 길면 검색어 주변 일정 길이만 추출
  ///
  String _extractContextAroundKeyword(String text, String keyword) {
    const int maxContextLength = 20; // 최대 표시 길이
    const int contextPadding = 10; // 검색어 앞뒤로 보여줄 글자 수

    // 한 줄로 정규화 처리
    final normalizedText = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 검색어 위치 찾기
    final lowerText = normalizedText.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();
    final keywordIndex = lowerText.indexOf(lowerKeyword);

    // 검색어를 못 찾은 경우
    if (keywordIndex == -1) {
      return normalizedText.length > maxContextLength
          ? '${normalizedText.substring(0, maxContextLength)}...'
          : normalizedText;
    }

    // 전체 텍스트가 짧으면 그대로 반환
    if (normalizedText.length <= maxContextLength) {
      return normalizedText;
    }

    // 검색어 주변 컨텍스트 추출
    final startIndex = (keywordIndex - contextPadding).clamp(
      0,
      normalizedText.length,
    );
    final endIndex = (keywordIndex + keyword.length + contextPadding).clamp(
      0,
      normalizedText.length,
    );

    final prefix = startIndex > 0 ? '...' : '';
    final suffix = endIndex < normalizedText.length ? '...' : '';

    return '$prefix${normalizedText.substring(startIndex, endIndex)}$suffix';
  }
}
