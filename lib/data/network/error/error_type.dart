
///
/// 파이어베이스 인증 에러
///
class FirebaseAuthError implements Exception {
  final String message;

  FirebaseAuthError(this.message);

  @override
  String toString() {
    return message;
  }
}


///
/// 파이어스토어 에러
///
class FirestoreError implements Exception {
  final String message;

  FirestoreError(this.message);

  @override
  String toString() {
    return message;
  }
}