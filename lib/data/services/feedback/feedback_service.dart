import 'package:with_calendar/data/services/firestore/base_firestore_mixin.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class FeedbackService with BaseFirestoreMixin {
  ///
  /// 피드백 생성
  ///
  Future<void> create(String content) async {
    final createdAt = DateTime.now().toStringFormat('yyyy-MM-dd HH:mm:ss');

    await firestore.collection(FirestoreCollection.feedback).add({
      'id': getUserUID,
      'content': content,
      'createdAt': createdAt,
    });
  }
}
