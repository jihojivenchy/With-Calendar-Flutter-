import 'package:flutter/material.dart';

class Memo {
  final String id;
  final String content;
  final String createdAt; // yyyy년 MM월 dd일 HH시 mm분
  final bool isPinned;
  final Color pinColor;

  const Memo({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.isPinned,
    required this.pinColor,
  });

  static Memo fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id'],
      content: json['content'],
      createdAt: json['createdAt'],
      isPinned: json['isPinned'],
      pinColor: Color(json['pinColor'] as int),
    );
  }

  Memo copyWith({String? content, bool? isPinned, Color? pinColor}) {
    return Memo(
      id: id,
      content: content ?? this.content,
      createdAt: createdAt,
      isPinned: isPinned ?? this.isPinned,
      pinColor: pinColor ?? this.pinColor,
    );
  }

  static Memo initialState = Memo(
    id: '',
    content: '',
    createdAt: '',
    isPinned: false,
    pinColor: const Color(0xFF409060),
  );
}
