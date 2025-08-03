import 'dart:math';

class RandomGenerator {
  static const String _characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  static final Random _random = Random();

  /// 유저 고유 코드를 생성합니다 (기본 5자리)
  static String generateUserCode({int length = 5}) {
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _characters.codeUnitAt(_random.nextInt(_characters.length)),
      ),
    );
  }
}