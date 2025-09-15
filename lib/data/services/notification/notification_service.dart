import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  NotificationService._internal();

  factory NotificationService() {
    return instance;
  }

  // 플러그인 객체
  FlutterLocalNotificationsPlugin? _localNotificationPlugin;

  ///
  /// 알림 초기화
  ///
  Future init() async {
    // 알림 플러그인 초기화
    _localNotificationPlugin = FlutterLocalNotificationsPlugin();

    // 안드로이드 초기화 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    // iOS(Darwin) 알림 초기화 설정 (모든 권한을 false로 설정하여 나중에 수동으로 요청)
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
          // 포그라운드에서 노티피케이션 표시 설정
          defaultPresentAlert: true, // iOS 10-13용 (알림 표시)
          defaultPresentSound: true, // 소리 재생
          defaultPresentBadge: true, // 배지 표시
          defaultPresentBanner: true, // iOS 14+ 배너 표시
          defaultPresentList: true, // iOS 14+ 노티피케이션 센터 표시
        );

    // 플랫폼별 초기화 설정 통합
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // 알림 플러그인 초기화
    await _localNotificationPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // 안드로이드 알림 채널 생성
    if (Platform.isAndroid) {
      AndroidNotificationChannel androidNotificationChannel =
          const AndroidNotificationChannel(
            'ADHD_CHANNEL_ID', // 채널 ID
            'CHANNEL', // 채널 이름
            importance: Importance.high, // 알림 중요도 설정
          );

      // 안드로이드 알림 채널을 시스템에 등록
      await _localNotificationPlugin
          ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!
          .createNotificationChannel(androidNotificationChannel);

      // 안드로이드 알림 권한 요청
      await _localNotificationPlugin
          ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!
          .requestNotificationsPermission();
    }

    // 알림 초기화 완료
    return Future.value();
  }

  ///
  /// 알림 클릭 시 이벤트 발생
  ///
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload;
    print('알림 클릭 시 이벤트 발생: $payload');
  }

  ///
  /// 알림 권한 요청 메서드
  /// Android 13+ 및 iOS에서 알림 권한을 사용자에게 요청
  ///
  /// Returns:
  /// - true: 권한 허용됨
  /// - false: 권한 거부됨
  ///
  Future<bool?> requestPermission() async {
    if (_localNotificationPlugin == null) {
      return Future.value(false);
    }

    bool? result;
    String platform = '';

    if (Platform.isAndroid) {
      // 안드로이드 알림 권한 요청
      platform = 'android';
      result = await _localNotificationPlugin!
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!
          .requestNotificationsPermission();
    } else if (Platform.isIOS) {
      // iOS 알림 권한 요청
      platform = 'ios';
      result = await _localNotificationPlugin!
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()!
          .requestPermissions(
            alert: true, // 알림 표시 권한
            badge: true, // 배지 권한
            sound: true, // 사운드 권한
          );
    } else {
      // 안드로이드 또는 iOS가 아닌 경우 권한 거부
      return Future.value(false);
    }

    return result;
  }

  ///
  /// Android SCHEDULE_EXACT_ALARM 권한 요청
  ///
  Future<void> requestExactAlarmsPermission() async {
    if (!Platform.isAndroid) return;

    try {
      final androidPlugin = _localNotificationPlugin!
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin!.requestExactAlarmsPermission();
    } catch (e) {
      log('Android SCHEDULE_EXACT_ALARM 권한 요청 실패: $e');
    }
  }

  ///
  /// Android SCHEDULE_EXACT_ALARM 권한 확인 및 스케줄링 모드 반환
  ///
  Future<AndroidScheduleMode> _canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;

    try {
      final androidPlugin = _localNotificationPlugin!
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin == null)
        return AndroidScheduleMode.inexactAllowWhileIdle;

      // Android 12+ 정확한 알람 권한 체크
      final bool? canScheduleExact = await androidPlugin
          .canScheduleExactNotifications();
      return canScheduleExact == true
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (e) {
      print('정확한 알람 권한 체크 실패: $e');
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }
}
