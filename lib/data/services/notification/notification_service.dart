import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:with_calendar/domain/entities/notification/schedule_notification.dart';
import 'package:with_calendar/domain/entities/schedule/request/schedule_request.dart';
import 'package:with_calendar/domain/entities/schedule/request/schedule_type.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

abstract class AndroidChannelConstants {
  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDesc = '일정 알림 채널';
}

/// 알림 권한 상태
enum NotificationPermissionStatus {
  granted,
  provisional,
  denied,
  restricted,
  notDetermined,
  unknown,
}

/// 알림 서비스
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// 플러그인 인스턴스
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  ///
  /// 알림 서비스 초기화
  ///
  /// 안드로이드와 iOS 각각의 초기화 로직을 실행한다.
  /// 1. 플랫폼별 알림 설정 구성
  /// 2. 알림 플러그인 초기화
  /// 3. 안드로이드 알림 채널 생성 및 권한 요청
  /// 4. 타임존 설정
  /// 5. iOS 알림 권한 요청
  ///
  Future<void> initialize() async {
    // 안드로이드 알림 초기화 설정
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS 알림 초기화 설정
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // 초기화 시 권한 요청하지 않음 (별도로 처리)
      requestBadgePermission: false, // 초기화 시 배지 권한 요청하지 않음
      requestSoundPermission: false, // 초기화 시 사운드 권한 요청하지 않음
      defaultPresentAlert: true, // 포그라운드 상태에서 알림 표시
      defaultPresentBadge: true, // 포그라운드 상태에서 배지 갱신
      defaultPresentSound: true, // 포그라운드 상태에서 사운드 재생
      defaultPresentBanner: true, // iOS 14+ 배너 표시
      defaultPresentList: true, // iOS 14+ 알림 센터 목록 표시
    );

    // 플랫폼별 설정 통합
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 알림 플러그인 초기화 (알림 클릭 시 콜백 포함)
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 안드로이드 알림 채널 생성 및 권한 요청
    await _ensureAndroidNotificationsPermission();

    // 타임존 설정 (한국 표준시)
    await _ensureLocalTimezone();

    // iOS 알림 권한 요청
    await requestiOSPermissions();
  }

  ///
  /// 안드로이드 알림 채널 생성 및 권한 확인
  ///
  /// Android 13+ 부터 알림 권한을 런타임으로 허용받아야 한다.
  /// 1. 알림 채널을 생성 (Android 8.0+에서 필수)
  /// 2. 알림 권한 요청 (Android 13+에서 필수)
  ///
  Future<void> _ensureAndroidNotificationsPermission() async {
    if (!Platform.isAndroid) return;

    // 안드로이드 플러터 로컬 알림 플러그인 인스턴스 획득
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // 알림 채널 생성 (Android 8.0 Oreo 이상에서 필수)
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        AndroidChannelConstants.channelId,
        AndroidChannelConstants.channelName,
        description: AndroidChannelConstants.channelDesc,
        importance: Importance.high, // 중요도를 높게 설정하여 알림이 표시되도록 함
      ),
    );

    // 알림 권한 요청 (Android 13 Tiramisu 이상에서 필수)
    await androidPlugin?.requestNotificationsPermission();
  }

  ///
  /// iOS 알림 권한 요청
  ///
  /// alert(알림), badge(배지), sound(소리) 권한을 요청한다.
  /// iOS에서는 초기화 시 권한을 요청하지 않고 별도로 요청한다.
  ///
  Future<void> requestiOSPermissions() async {
    if (!Platform.isIOS) return;

    // iOS 플러터 로컬 알림 플러그인 인스턴스 획득
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    // alert, badge, sound 권한 요청
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  ///
  /// 알림을 클릭했을 때 호출되는 콜백
  ///
  /// 현재는 빈 구현이지만, 추후 알림 클릭 시 특정 화면으로 이동하거나
  /// 특정 동작을 수행하도록 확장할 수 있다.
  ///
  void _onNotificationTapped(NotificationResponse response) {}

  ///
  /// 타임존 설정
  ///
  /// 한국 서비스 기준으로 타임존을 'Asia/Seoul'로 설정한다.
  /// 타임존 설정에 실패하면 UTC로 폴백한다.
  /// (추후 필요 시 기기 타임존으로 확장 가능)
  ///
  Future<void> _ensureLocalTimezone() async {
    // 타임존 데이터베이스 초기화
    tz.initializeTimeZones();
    try {
      // 한국 표준시(KST, UTC+9) 설정
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    } catch (_) {
      // 타임존 설정 실패 시 UTC로 폴백
      tz.setLocalLocation(tz.UTC);
    }
  }

  ///
  /// Android SCHEDULE_EXACT_ALARM 권한 확인 및 스케줄링 모드 반환
  ///
  /// Android 12(API 31) 이상에서는 정확한 알람을 예약하려면
  /// SCHEDULE_EXACT_ALARM 권한이 필요하다.
  ///
  /// Returns:
  /// - exactAllowWhileIdle: 정확한 알람 권한이 있을 때 (정확한 시간에 알림 표시)
  /// - inexactAllowWhileIdle: 정확한 알람 권한이 없을 때 (대략적인 시간에 알림 표시)
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

      // 권한이 있으면 정확한 알람 모드, 없으면 부정확한 알람 모드 반환
      return canScheduleExact == true
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (_) {
      // 예외 발생 시 부정확한 알람 모드로 폴백
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  // -----------------------------알림 생성 --------------------------------------

  ///
  /// UUID 문자열을 int 알림 ID로 변환
  ///
  /// 알림 시스템에서는 int 타입의 ID를 사용하므로,
  /// UUID 문자열을 해시코드로 변환하여 int ID를 생성한다.
  /// abs()를 사용하여 양수로 변환한다.
  ///
  int _convertToNotificationID(String scheduleId) {
    return scheduleId.hashCode.abs();
  }

  ///
  /// 알림 생성 및 예약
  ///
  /// `notificationTime`(yyyy-MM-dd HH:mm:ss)이 비어있지 않은 경우에만 예약한다.
  ///
  /// [scheduleID]: 일정 고유 ID (UUID)
  /// [schedule]: 일정 정보를 담은 ScheduleRequest 객체
  ///
  /// 처리 흐름:
  /// 1. 일정 ID를 알림 ID로 변환
  /// 2. 알림 시간이 비어있으면 기존 알림 삭제 후 종료
  /// 3. 과거 시간이면 예약하지 않음
  /// 4. 플랫폼별 알림 설정 구성
  /// 5. 기존 알림 취소 후 새 알림 예약
  ///
  Future<void> create({
    required String scheduleID,
    required ScheduleRequest request,
  }) async {
    // 일정 ID를 알림 ID(int)로 변환
    final notificationID = _convertToNotificationID(scheduleID);

    // 알림 시간이 비어있으면 기존 예약 알림도 제거하고 종료
    if (request.notificationTime.isEmpty) {
      await delete(notificationID);
      return;
    }

    // 알림 시간을 DateTime으로 파싱
    DateTime notificationTime = DateTime.parse(request.notificationTime);

    // 과거 시간에 대한 알림은 예약하지 않음
    if (notificationTime.isBefore(DateTime.now())) return;

    // 타임존 설정에 맞게 알림 시간을 TZDateTime으로 변환
    final tzDate = tz.TZDateTime.from(notificationTime, tz.local);

    // 안드로이드 알림 세부 정보 구성
    final androidDetails = AndroidNotificationDetails(
      AndroidChannelConstants.channelId,
      AndroidChannelConstants.channelName,
      channelDescription: AndroidChannelConstants.channelDesc,
      importance: Importance.high, // 높은 중요도 (헤드업 알림 표시)
      priority: Priority.high, // 높은 우선순위
      ticker: '일정 알림', // 상태바에 표시될 텍스트
    );

    // iOS 알림 세부 정보 구성
    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true, // 알림 표시
      presentBadge: true, // 배지 표시
      presentSound: true, // 사운드 재생
    );

    // 플랫폼별 알림 세부 정보 통합
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      // 기존 알림이 있다면 먼저 취소 (중복 방지)
      await _plugin.cancel(notificationID);

      // 안드로이드 알림 스케줄링 모드 확인 (정확한 알람 vs 부정확한 알람)
      final androidScheduleMode = await _canScheduleExactAlarms();

      // 새 알림 예약
      await _plugin.zonedSchedule(
        notificationID,
        request.title,
        _createNotificationBody(request),
        tzDate,
        notificationDetails,
        androidScheduleMode: androidScheduleMode,
        payload: jsonEncode({
          'scheduleID': scheduleID,
          'scheduledDate': request.startDate.toStringFormat(
            'yyyy-MM-dd HH:mm:ss',
          ),
          'notificationTime': request.notificationTime,
        }),
      );
    } catch (e) {
      log('알림 생성 실패: ${e.toString()}');
      SnackBarService.showSnackBar('알림을 예약하는 중 오류가 발생했습니다.');
      return;
    }
  }

  ///
  /// 알림 본문(body) 생성
  ///
  /// 일정 타입(하루종일/시간 일정)에 따라 적절한 알림 본문을 생성한다.
  ///
  /// [schedule]: 일정 정보
  ///
  /// Returns: 알림에 표시될 본문 텍스트
  ///
  String _createNotificationBody(ScheduleRequest request) {
    final DateTime startDate = request.startDate;
    final DateTime endDate = request.endDate;
    final notificationDate = DateTime.parse(request.notificationTime);

    // 일정 타입에 따라 다른 형식의 본문 생성
    switch (request.type) {
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
          isLongSchedule: request.isLongSchedule,
        );
    }
  }

  ///
  /// 하루종일 일정용 알림 본문 생성
  ///
  /// 형식: "yyyy년 MM월 dd일 (요일) 일정, X일/시간/분 전 알림입니다."
  ///
  /// [startDate]: 일정 시작 날짜
  /// [endDate]: 일정 종료 날짜
  /// [countdownText]: 카운트다운 텍스트 (예: "1일 전 알림입니다.")
  ///
  String _buildAllDayBody({
    required DateTime startDate,
    required DateTime endDate,
    required String? countdownText,
  }) {
    final String baseText = '${startDate.toKoreanSimpleDateFormat()} 일정';
    if (countdownText == null) return baseText;
    return '$baseText, $countdownText';
  }

  ///
  /// 시간 일정용 알림 본문 생성
  ///
  /// - 장기 일정: "yyyy년 MM월 dd일 (요일) 일정, X일/시간/분 전 알림입니다."
  /// - 단기 일정: "오전/오후 HH:mm ~ 오전/오후 HH:mm 일정, X일/시간/분 전 알림입니다."
  ///
  /// [startDate]: 일정 시작 시간
  /// [endDate]: 일정 종료 시간
  /// [countdownText]: 카운트다운 텍스트
  /// [isLongSchedule]: 장기 일정 여부
  ///
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
      // 단기 일정일 경우 => '오전/오후 HH:mm ~ 오전/오후 HH:mm 일정'
      baseText =
          '${startDate.toKoreanMeridiemTime()} ~ ${endDate.toKoreanMeridiemTime()} 일정';
    }

    if (countdownText == null) return baseText;
    return '$baseText, $countdownText';
  }

  ///
  /// 알림이 시작 시간보다 얼마나 이전인지 한국어로 포맷
  ///
  /// 알림 시간과 일정 시작 시간의 차이를 계산하여
  /// "X일/시간/분 전 알림입니다." 형식의 텍스트를 생성한다.
  ///
  /// [startDate]: 일정 시작 시간
  /// [notificationDate]: 알림 시간
  ///
  /// Returns: 카운트다운 텍스트 (알림 시간이 시작 시간 이후이면 null)
  ///
  String? _formatCountdownText({
    required DateTime startDate,
    required DateTime notificationDate,
  }) {
    // 알림 시간이 시작 시간 이후이거나 같으면 카운트다운 표시 안 함
    if (!startDate.isAfter(notificationDate)) {
      return null;
    }

    final Duration diff = startDate.difference(notificationDate);

    // 1일 이상 차이나면 일 단위로 표시
    if (diff.inDays >= 1) {
      return '${diff.inDays}일 전 알림입니다.';
    }

    // 1시간 이상 차이나면 시간 단위로 표시
    if (diff.inHours >= 1) {
      return '${diff.inHours}시간 전 알림입니다.';
    }

    // 1분 이상 차이나면 분 단위로 표시
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}분 전 알림입니다.';
    }

    // 1분 미만이면 '곧 시작됩니다.' 표시
    return '곧 시작됩니다.';
  }

  // -----------------------------알림 조회 --------------------------------------

  ///
  /// 예약된 알림 목록 조회
  ///
  /// 시스템에 예약된 모든 알림을 조회하여 ScheduledNotification 리스트로 반환한다.
  /// 파싱에 실패한 알림은 제외하고 반환한다.
  ///
  /// Returns: 예약된 알림 목록
  ///
  Future<List<ScheduledNotification>> fetchNotificationList() async {
    // 시스템에서 예약된 알림 목록 조회
    final pendingList = await _plugin.pendingNotificationRequests();

    // 각 알림을 ScheduledNotification으로 변환
    final List<ScheduledNotification?> resultList = pendingList.map((request) {
      ScheduleNotificationPayload payload;

      try {
        // 알림 페이로드를 JSON에서 객체로 파싱
        payload = ScheduleNotificationPayload.fromJson(
          jsonDecode(request.payload!),
        );

        return ScheduledNotification(
          id: request.id,
          title: request.title ?? '',
          body: request.body ?? '',
          payload: payload,
        );
      } catch (e) {
        log('알림 파싱 실패: $e');
        return null; // 파싱 실패 시 null 반환
      }
    }).toList();

    // null을 제외하고 유효한 알림만 반환
    return resultList.whereType<ScheduledNotification>().toList();
  }

  // -----------------------------알림 삭제 --------------------------------------

  ///
  /// 예약된 알림 삭제
  ///
  /// 특정 알림 ID에 해당하는 예약된 알림을 취소한다.
  ///
  /// [notificationID]: 삭제할 알림의 고유 ID
  ///
  Future<void> delete(int notificationID) async {
    await _plugin.cancel(notificationID);
  }

  // -----------------------------알림 권한 관련 -----------------------------------

  ///
  /// 알림 권한 상태 조회
  ///
  Future<bool> fetchPermissionStatus() async {
    // 안드로이드 권한 확인
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // 알림 권한 활성화 여부 확인
      final notificationsEnabled =
          await androidPlugin?.areNotificationsEnabled() ?? true;

      return notificationsEnabled;
    }

    // iOS 권한 확인
    if (Platform.isIOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      // iOS에서 권한을 다시 요청하여 현재 상태를 확인
      final NotificationsEnabledOptions? options = await iosPlugin
          ?.checkPermissions();

      final notificationsEnabled = options?.isEnabled ?? false;
      return notificationsEnabled;
    }

    return false;
  }

  ///
  /// 시스템 알림 설정 화면으로 이동
  ///
  Future<void> openSystemNotificationSettings() async {
    await AppSettings.openAppSettings();
  }
}
