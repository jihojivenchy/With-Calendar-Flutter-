import 'dart:ui';

import 'package:uuid/uuid.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class MemoCreation {
  final String content;
  final bool isPinned;
  final Color pinColor;

  const MemoCreation({
    required this.content,
    required this.isPinned,
    required this.pinColor,
  });

  MemoCreation copyWith({
    String? title,
    String? content,
    bool? isPinned,
    Color? pinColor,
  }) {
    return MemoCreation(
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      pinColor: pinColor ?? this.pinColor,
    );
  }

  static MemoCreation initialState = MemoCreation(
    content: '',
    isPinned: false,
    pinColor: const Color(0xFF409060),
  );
}