extension ValidationExtension on String {
  ///
  /// 기본적인 이메일 형식 패턴을 사용하여 유효성을 검사합니다.
  ///
  bool get isValidEmail {
    if (isEmpty) return false;

    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  ///
  /// 이메일 유효성 검사를 수행하고 에러 메시지를 반환합니다.
  ///
  String? validateEmail() {
    if (isEmpty) {
      return '이메일을 입력해주세요.';
    }

    if (!isValidEmail) {
      return '유효한 이메일 형식이 아닙니다.';
    }

    return null;
  }

  ///
  /// 비밀번호의 유효성을 검사합니다. 6자 이상인지 확인합니다.
  ///
  bool get isValidPassword {
    return isNotEmpty && length >= 6;
  }

  ///
  /// 비밀번호 유효성 검사를 수행하고 에러 메시지를 반환합니다.
  ///
  String? validatePassword() {
    if (isEmpty) {
      return '비밀번호를 입력해주세요';
    }

    if (length < 6) {
      return '비밀번호는 6자 이상이어야 합니다';
    }

    return null;
  }

  ///
  /// 비밀번호 확인 유효성 검사를 수행하고 에러 메시지를 반환합니다.
  /// [originalPassword] - 원본 비밀번호와 비교
  ///
  String? validatePasswordConfirm(String originalPassword) {
    if (isEmpty) {
      return '비밀번호를 입력해주세요';
    }

    if (length < 6) {
      return '비밀번호는 6자 이상이어야 합니다';
    }

    if (this != originalPassword) {
      return '비밀번호가 일치하지 않습니다';
    }

    return null;
  }
}
