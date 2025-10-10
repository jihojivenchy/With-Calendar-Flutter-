import 'package:uuid/uuid.dart';
import 'package:with_calendar/data/services/firestore/base_firestore_mixin.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';
import 'package:with_calendar/domain/entities/memo/memo_creation.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class MemoService with BaseFirestoreMixin {
  ///
  /// 메모 조회
  ///
  Stream<List<Memo>> fetchMemoList() {
    return firestore
        .collection(FirestoreCollection.memo)
        .doc(getUserUID)
        .collection(FirestoreCollection.memo)
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Memo.fromJson(doc.data())).toList();
        });
  }

  ///
  /// 메모 생성
  ///
  Future<void> create(MemoCreation memo) async {
    final memoID = Uuid().v4();
    final createdAt = DateTime.now().toStringFormat('yyyy-MM-dd HH:mm:ss');
    final tokens = _extractKeywordList(memo.content);

    await firestore
        .collection(FirestoreCollection.memo)
        .doc(getUserUID)
        .collection(FirestoreCollection.memo)
        .doc(memoID)
        .set({
          'id': memoID,
          'content': memo.content,
          'tokens': tokens,
          'isPinned': memo.isPinned,
          'pinColor': memo.pinColor.toARGB32(), // 32비트 색상 값으로 변환
          'createdAt': createdAt,
        });
  }

  ///
  /// 메모 수정
  ///
  Future<void> updateMemo(Memo memo) async {
    final updatedAt = DateTime.now().toStringFormat('yyyy-MM-dd HH:mm:ss');
    final tokens = _extractKeywordList(memo.content);

    await firestore
        .collection(FirestoreCollection.memo)
        .doc(getUserUID)
        .collection(FirestoreCollection.memo)
        .doc(memo.id)
        .update({
          'content': memo.content,
          'tokens': tokens,
          'isPinned': memo.isPinned,
          'pinColor': memo.pinColor.toARGB32(), // 32비트 색상 값으로 변환
          'createdAt': updatedAt,
        });
  }

  ///
  /// 메모 삭제
  ///
  Future<void> deleteMemo(String memoID) async {
    await firestore
        .collection(FirestoreCollection.memo)
        .doc(getUserUID)
        .collection(FirestoreCollection.memo)
        .doc(memoID)
        .delete();
  }

  ///
  /// 메모 검색
  ///
  Future<List<Memo>> searchMemo(String keyword) async {
    final memoList = await firestore
        .collection(FirestoreCollection.memo)
        .doc(getUserUID)
        .collection(FirestoreCollection.memo)
        .where('tokens', arrayContains: keyword)
        .get();
    return (memoList.docs as List? ?? [])
        .map((doc) => Memo.fromJson(doc.data()))
        .toList();
  }

  ///
  /// 메모 토큰화
  ///
  List<String> _extractKeywordList(String content) {
    // 소문자 변환
    final normalized = content.toLowerCase().trim();
    if (normalized.isEmpty) {
      return const [];
    }

    // 포함시키지 않을 용어
    const stopWords = <String>{
      // 조사
      '은',
      '는',
      '이',
      '가',
      '을',
      '를',
      '의',
      '에',
      '에서',
      '로',
      '으로',
      '와',
      '과',
      '도',
      '만',
      '부터',
      '까지',
      '에게',
      '한테',
      '께',
      '께서',
      '이나',
      '이든',
      '든',
      '이든지',
      '든지',
      '라도',
      '이라도',
      // 대명사
      '나',
      '너',
      '우리',
      '저희',
      '당신',
      '그',
      '저',
      '그것',
      '이것',
      '저것',
      '여기',
      '거기',
      '저기',
      // 접속사/부사
      '그리고',
      '그러나',
      '하지만',
      '그런데',
      '또는',
      '또',
      '및',
      '즉',
      '더욱',
      '매우',
      '아주',
      '좀',
      '조금',
      // 지시어/의존명사
      '것',
      '수',
      '등',
      '때',
      // 영어 불용어
      'a',
      'an',
      'and',
      'are',
      'as',
      'at',
      'be',
      'but',
      'by',
      'for',
      'if',
      'in',
      'into',
      'is',
      'it',
      'no',
      'not',
      'of',
      'on',
      'or',
      'such',
      'that',
      'the',
      'their',
      'then',
      'there',
      'these',
      'they',
      'this',
      'to',
      'was',
      'will',
      'with',
    };

    // 유니코드 문자(한글, 영어 등) + 숫자 추출
    final tokenRegExp = RegExp(r'[\p{L}\p{N}]+', unicode: true);
    final keywordSet = <String>{};

    for (final match in tokenRegExp.allMatches(normalized)) {
      final token = match.group(0);

      // 2글자 미만 제외
      if (token == null || token.length < 2) {
        continue;
      }

      // 불용어 제외
      if (stopWords.contains(token)) {
        continue;
      }

      keywordSet.add(token);
    }

    if (keywordSet.isEmpty) {
      return const [];
    }

    return List<String>.unmodifiable(keywordSet);
  }
}
