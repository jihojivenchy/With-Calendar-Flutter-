import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/data/services/notification/notification_service.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'firebase_options.dart';
import 'package:with_calendar/presentation/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 로컬 디비 초기화
  await initHive();

  // 알림 서비스 초기화
  await NotificationService.instance.initialize();

  // 세로 방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(ProviderScope(child: App()));
}

/// 로컬 디비 초기화
Future<void> initHive() async {
  await Hive.initFlutter();
  await HiveService.instance.init();
}

class App extends ConsumerWidget {
  App({super.key});

  static void _initLoadingIndicator() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = Colors.transparent
      ..boxShadow = []
      ..indicatorColor = AppColors.primary
      ..maskType = EasyLoadingMaskType.black
      ..maskColor = Colors.transparent
      ..textColor = Colors.white
      ..dismissOnTap = false;
  }

  // 라우터 인스턴스
  final _router = appRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _initLoadingIndicator();
    debugInvertOversizedImages = true;
    AppSize.init(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기
      },
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: Colors.transparent,
            selectionColor: AppColors.gray200,
          ),
          fontFamily: 'Pretendard',
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
        builder: (context, child) => EasyLoading.init()(context, child),
      ),
    );
  }
}


// TODO: ---할일  
// 1. FireStore API 모듈 추가
// 2. 