
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


/// 타임아웃 에러
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}

/// 서버 에러
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// 네트워크 에러
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}
