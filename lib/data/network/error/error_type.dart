
///
/// 파이어베이스 인증 에러 타입
///
class FirebaseAuthErrorType implements Exception {
  final String message;

  FirebaseAuthErrorType(this.message);

  @override
  String toString() {
    return message;
  }
}
