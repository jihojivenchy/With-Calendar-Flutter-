/// 문자열 요약
extension StringSummarization on String {
  /// 문자열 요약
  String get summaryTitle {
    if (isEmpty) return '';

    // 다음행이동 문자 -> 공백 처리
    final cleanText = replaceAll('\n', ' ').trim();

    // 1. 먼저 첫 문장 끝을 찾아보기 (10글자 이내)
    final sentenceEndIndex = _firstSentenceEndIndex(cleanText);
    if (sentenceEndIndex != null && sentenceEndIndex <= 10) {
      return cleanText.substring(0, sentenceEndIndex);
    }

    // 2. 문장 끝이 없거나 10글자 초과면, 10글자 이내 공백 찾기
    final spaceIndex = cleanText.indexOf(' ');
    if (spaceIndex != -1 && spaceIndex <= 10) {
      return cleanText.substring(0, spaceIndex);
    }

    // 3. 10글자 이내에 공백이 없으면 10글자까지만
    if (cleanText.length <= 10) {
      return cleanText;
    }

    // 4. 10글자 이상이면서 공백으로 끊어낼 수 없었던 경우 → 10글자 + "..."
    return '${cleanText.substring(0, 10)}...';
  }

  /// 첫 문장의 끝 인덱스(Substring의 end) 반환.
  /// '.', '!', '?', '…', '。', '！', '？' 등을 문장 끝으로 간주.
  int? _firstSentenceEndIndex(String text) {
    final match = RegExp(r'[.!?…]|[。！？]').firstMatch(text);
    return match?.end; // 해당 문자열의 바로 다음 인덱스 반환
  }
}
