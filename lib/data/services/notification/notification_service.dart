import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:with_calendar/domain/entities/notification/schedule_notification.dart';
import 'package:with_calendar/domain/entities/schedule/create_schedule_request.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

abstract class AndroidChannelConstants {
  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDesc = '일정 알림 채널';
}

/// 알림 서비스
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// 플러그인 인스턴스
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// 안드로이드와 iOS 각각의 초기화 로직을 실행
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS 알림 초기화 설정
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true, // 포그라운드 상태에서 알림 표시
      defaultPresentBadge: true, // 포그라운드 상태에서 배지 갱신
      defaultPresentSound: true, // 포그라운드 상태에서 사운드
      defaultPresentBanner: true, // iOS 14+ 배너 표시
      defaultPresentList: true, // iOS 14+  알림 센터 목록 표시
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 초기화 (알림 클릭 시 콜백 등)
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 안드로이드 알림 채널 생성 및 권한 요청
    await _ensureAndroidNotificationsPermission();

    // 타임존 설정
    await _ensureLocalTimezone();

    // iOS 알림 권한 요청
    await requestiOSPermissions();
  }

  /// 안드로이드 알림 권한 확인
  /// Android 13+ 부터 알림 권한을 런타임으로 허용받아야 함
  Future<void> _ensureAndroidNotificationsPermission() async {
    if (!Platform.isAndroid) return;
    // 안드로이드 플러터 로컬 알림 플러그인
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // 알림 채널 생성
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        AndroidChannelConstants.channelId,
        AndroidChannelConstants.channelName,
        description: AndroidChannelConstants.channelDesc,
        importance: Importance.high,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();
  }

  /// 알림 권한을 요청하고 허용 여부를 반환
  Future<void> requestiOSPermissions() async {
    if (!Platform.isIOS) return;

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// 알림을 클릭했을 때
  void _onNotificationTapped(NotificationResponse response) {}

  ///
  /// 타임존 설정
  ///
  Future<void> _ensureLocalTimezone() async {
    // 한국 서비스 기준으로 타임존을 고정 (추후 필요 시 기기 타임존으로 확장 가능)
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  ///
  /// Android SCHEDULE_EXACT_ALARM 권한 확인 및 스케줄링 모드 반환
  ///
  Future<AndroidScheduleMode> _canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;

    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // Android 12+ 정확한 알람 권한 체크
      final bool? canScheduleExact = await androidPlugin
          ?.canScheduleExactNotifications();
      return canScheduleExact == true
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (_) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  // -----------------------------알림 생성 --------------------------------------
  ///
  /// UUID 문자열을 int 알림 ID로 변환
  ///
  int _convertToNotificationID(String scheduleId) {
    return scheduleId.hashCode.abs();
  }

  ///
  /// 알림 생성
  /// `notificationTime`(yyyy-MM-dd HH:mm:ss)이 비어있지 않은 경우에만 예약한다.
  ///
  Future<bool> create(String scheduleID, CreateScheduleRequest schedule) async {
    // 알림 시간이 비어있으면 예약하지 않음
    if (schedule.notificationTime.isEmpty) return false;

    // 알림 시간을 DateTime으로 변환
    DateTime scheduledDate = DateTime.parse(schedule.notificationTime);

    // 과거 시간에 대한 알림은 예약하지 않음
    if (scheduledDate.isBefore(DateTime.now())) return false;

    // 타임존 설정에 맞게 알림 시간 설정
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // 안드로이드 알림 세부 정보
    final androidDetails = AndroidNotificationDetails(
      AndroidChannelConstants.channelId,
      AndroidChannelConstants.channelName,
      channelDescription: AndroidChannelConstants.channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ticker: '일정 알림',
    );

    // iOS 알림 세부 정보
    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 알림 아이디 생성
    final notificationID = _convertToNotificationID(scheduleID);

    try {
      // 기존 알림이 있다면 먼저 취소
      await _plugin.cancel(notificationID);

      // 안드로이드 알림 스케줄링 모드 확인
      final androidScheduleMode = await _canScheduleExactAlarms();

      // 새 알림 예약
      await _plugin.zonedSchedule(
        notificationID,
        schedule.title,
        _createNotificationBody(schedule),
        tzDate,
        notificationDetails,
        androidScheduleMode: androidScheduleMode,
        payload: jsonEncode({
          'scheduleId': scheduleID,
          'notificationTime': schedule.notificationTime,
        }),
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  ///
  /// 알림 body 생성
  ///
  String _createNotificationBody(CreateScheduleRequest schedule) {
    final DateTime startDate = schedule.startDate;
    final DateTime endDate = schedule.endDate;
    final notificationDate = DateTime.parse(schedule.notificationTime);

    switch (schedule.type) {
      case ScheduleType.allDay:
        return _buildAllDayBody(
          startDate: startDate,
          endDate: endDate,
          countdownText: _formatCountdownText(
            startDate: startDate,
            notificationDate: notificationDate,
          ),
        );
      case ScheduleType.time:
        return _buildTimeBody(
          startDate: startDate,
          endDate: endDate,
          countdownText: _formatCountdownText(
            startDate: startDate,
            notificationDate: notificationDate,
          ),
          isLongSchedule: schedule.isLongSchedule,
        );
    }
  }

  /// 하루종일 일정용 알림 바디 생성
  String _buildAllDayBody({
    required DateTime startDate,
    required DateTime endDate,
    required String? countdownText,
  }) {
    final String baseText = '${startDate.toKoreanSimpleDateFormat()} 일정';
    if (countdownText == null) return baseText;
    return '$baseText, $countdownText';
  }

  /// 시간 일정용 알림 바디 생성
  String _buildTimeBody({
    required DateTime startDate,
    required DateTime endDate,
    required String? countdownText,
    required bool isLongSchedule,
  }) {
    String baseText = '';

    // 장기 일정일 경우 => 'yyyy년 MM월 dd일 (요일) 일정'
    if (isLongSchedule) {
      baseText = '${startDate.toKoreanSimpleDateFormat()} 일정';
    } else {
      baseText =
          '${startDate.toKoreanMeridiemTime()} ~ ${endDate.toKoreanMeridiemTime()} 일정';
    }

    if (countdownText == null) return baseText;
    return '$baseText, $countdownText';
  }

  /// 알림이 시작 시간보다 얼마나 이전인지 한국어로 포맷
  String? _formatCountdownText({
    required DateTime startDate,
    required DateTime notificationDate,
  }) {
    if (!startDate.isAfter(notificationDate)) {
      return null;
    }

    final Duration diff = startDate.difference(notificationDate);

    if (diff.inDays >= 1) {
      return '${diff.inDays}일 전 알림입니다.';
    }

    if (diff.inHours >= 1) {
      return '${diff.inHours}시간 전 알림입니다.';
    }

    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}분 전 알림입니다.';
    }

    return '곧 시작됩니다.';
  }

  // -----------------------------알림 조회 --------------------------------------

  ///
  /// 알림 목록 조회
  ///
  Future<List<ScheduledNotification>> fetchNotificationList() async {
    // 알림 목록 조회
    final pendingList = await _plugin.pendingNotificationRequests();

    final List<ScheduledNotification> result = pendingList.map((request) {
      DateTime scheduledDate = DateTime.now();
      String scheduleID = '';

      try {
        final dynamic decoded = jsonDecode(request.payload!);
        if (decoded is Map<String, dynamic>) {
          scheduleID = decoded['scheduleId'] as String;
          final String? notificationTime =
              decoded['notificationTime'] as String?;
          if (notificationTime != null) {
            scheduledDate =
                DateTime.tryParse(notificationTime) ?? DateTime.now();
          }
        }
      } catch (e) {
        log('알림 파싱 실패: $e');
      }

      return ScheduledNotification(
        id: request.id,
        title: request.title ?? '',
        body: request.body ?? '',
        scheduledDate: scheduledDate,
        scheduleID: scheduleID,
      );
    }).toList();

    return result;
  }
}
