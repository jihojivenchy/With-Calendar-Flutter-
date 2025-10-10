import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

/// 메모 검색 사용방법 안내 뷰
class SearchMemoGuideView extends StatelessWidget {
  const SearchMemoGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            AppText(
              text: '메모 검색 팁',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              textColor: AppColors.color727577,
            ),
            const SizedBox(height: 20),
            _buildGuideItem(stepNumber: '1', content: '2글자 이상의 키워드로 검색하세요.'),
            const SizedBox(height: 20),

            _buildGuideItem(
              stepNumber: '2',
              content: '명사, 동사 등 핵심 단어 위주로 입력하세요.',
            ),
            const SizedBox(height: 20),

            _buildGuideItem(
              stepNumber: '3',
              content: '조사는 생략하고 입력하세요.\n(예: "달력이", "달력은" → "달력"만 입력)',
            ),
            const SizedBox(height: 20),

            _buildGuideItem(
              stepNumber: '4',
              content: '영어와 숫자도 검색 가능합니다.\n(예: "with", "calendar", "123")',
            ),
          ],
        ),
      ),
    );
  }

  /// 안내 아이템 생성
  Widget _buildGuideItem({
    required String stepNumber,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 단계 번호
        AppText(
          text: '$stepNumber.',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          textColor: AppColors.color727577,
        ),
        const SizedBox(width: 12),

        // 안내 텍스트
        Expanded(
          child: AppText(
            text: content,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            textColor: AppColors.color727577,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
