import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 각 데이터 파일 경로
enum HiveBoxPath {
  currentCalendar(key: "CURRENT_CALENDAR"); // 현재 선택된 캘린더 데이터

  final String key;
  const HiveBoxPath({required this.key});
}

///
/// Hive 서비스
/// Box는 하나의 key-value 쌍을 저장하는 공간입니다.
///
class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();
  static HiveService get instance => _instance;

  ///
  /// 로컬 디비 초기화
  /// 모든 디비 박스를 열어줍니다.
  /// 박스 열기 작업은 디스크에 저장된 데이터를 read/write 할 수 있도록 메모리로 로드합니다.
  ///
  Future<void> init() async {
    await Future.wait(
      List.generate(
        HiveBoxPath.values.length,
        (index) => Hive.openBox(HiveBoxPath.values[index].key),
      ),
    );
  }

  ///
  /// 데이터 조회
  ///
  /// [path] 조회할 파일 데이터 경로
  /// [key] 조회할 데이터의 키 (없을 경우 path의 key를 사용)
  /// [defaultValue] 키에 해당하는 값이 없을 경우 반환할 기본값
  ///
  /// Returns:
  ///   키에 해당하는 값 또는 defaultValue
  ///
  T? get<T>(HiveBoxPath path, {String? key, T? defaultValue}) {
    final box = Hive.box(path.key);
    final result = box.get(key ?? path.key, defaultValue: defaultValue);
    log('로컬 DB에서 데이터 조회 - 키: ${key ?? path.key}, 값: $result');
    return result;
  }

  ///
  /// 데이터 리스트 조회
  ///
  /// Returns:
  ///   키에 해당하는 값 리스트
  ///
  List<dynamic>? getList(HiveBoxPath path) {
    final box = Hive.box(path.key);
    final result = box.values.toList();
    log('로컬 DB에서 리스트 조회 - 키: ${path.key}, 값: $result');
    return result;
  }

  ///
  /// 특정 파일 데이터 실시간 구독
  ///
  /// Returns: 특정 파일 데이터 == box
  ///
  ValueListenable<Box> getListenable(HiveBoxPath path) {
    final box = Hive.box(path.key);
    return box.listenable();
  }

  ///
  /// 데이터 저장
  ///
  /// [path] 저장할 데이터의 파일 경로
  /// [key] 저장할 데이터의 키 (없을 경우 path의 key를 사용)
  /// [value] 저장할 데이터 값
  ///
  Future<void> create(
    HiveBoxPath path, {
    String? key,
    required dynamic value,
  }) async {
    final box = Hive.box(path.key);
    await box.put(key ?? path.key, value);
    log('로컬 DB에 데이터 저장 - 키: ${(key ?? path.key)}, 값: $value');
  }

  ///
  /// 데이터 삭제
  ///
  /// [path] 삭제할 데이터의 파일 경로
  /// [key] 삭제할 데이터의 키 (없을 경우 path의 key를 사용)
  ///
  Future<void> delete(HiveBoxPath path, {String? key}) async {
    final box = Hive.box(path.key);
    await box.delete(key ?? path.key);
    log('로컬 DB에서 데이터 삭제 - 키: ${key ?? path.key}');
  }

  ///
  /// 모든 데이터 삭제
  ///
  Future<void> clearAll() async {
    await Future.wait(
      List.generate(
        HiveBoxPath.values.length,
        (index) => Hive.box(HiveBoxPath.values[index].key).clear(),
      ),
    );
    log('로컬 DB의 모든 데이터 삭제');
  }
}
