import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:with_calendar/data/services/feedback/feedback_service.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';

mixin class FeedbackEvent {
  final FeedbackService _service = FeedbackService();

  ///
  /// 피드백 제출
  ///
  Future<void> create(WidgetRef ref, String content) async {
    try {
      await _service.create(content);

      if (ref.context.mounted) {
        _showDialog(ref, '제출 완료', subTitle: '소중한 의견 감사합니다.');
      }
    } catch (e) {
      log('피드백 제출 실패: ${e.toString()}');
      _showDialog(ref, '피드백 제출에 실패했습니다.');
    }
  }

  ///
  /// 고객 센터 이동
  ///
  Future<void> goToCustomerCenter(WidgetRef ref) async {
    try {
      const urlString = 'https://open.kakao.com/o/sSz7qoRe';
      final Uri uri = Uri.parse(urlString);
      await launchUrl(uri);
    } catch (e) {
      log(e.toString());
      SnackBarService.showSnackBar('고객 센터 이동에 실패했습니다. ${e.toString()}');
    }
  }

  ///
  /// 다이얼로그
  ///
  void _showDialog(WidgetRef ref, String title, {String? subTitle}) {
    DialogService.show(
      dialog: AppDialog.singleBtn(
        title: title,
        subTitle: subTitle,
        btnContent: '확인',
        onBtnClicked: () {
          ref.context.pop();
        },
      ),
    );
  }
}
