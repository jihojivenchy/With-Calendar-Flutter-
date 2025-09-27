import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

/// 공유달력 사용방법 안내 뷰
class GuideView extends StatelessWidget {
  const GuideView({super.key});

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
              text: '공유달력 이용 방법',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              textColor: AppColors.color727577,
            ),
            const SizedBox(height: 32),
            _buildGuideItem(
              stepNumber: '1',
              content: '회원가입과 동시에 회원코드가 부여됩니다.\n(메뉴 → 프로필 설정에서 확인가능)',
            ),
            const SizedBox(height: 20),

            _buildGuideItem(
              stepNumber: '2',
              content: '검색 바에서 초대하고 싶은 유저의 코드를 입력합니다.',
            ),
            const SizedBox(height: 20),

            _buildGuideItem(
              stepNumber: '3',
              content: '초대 후 뒤로 돌아가서 완료 버튼을 눌러 공유달력을 생성합니다.',
            ),
            const SizedBox(height: 20),

            _buildGuideItem(
              stepNumber: '4',
              content: '달력을 편집하고 싶다면 카테고리 창에서 달력을 꾹 눌러주세요.',
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
