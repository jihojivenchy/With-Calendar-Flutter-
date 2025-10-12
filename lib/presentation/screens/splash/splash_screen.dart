import 'package:flutter/material.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/utils/constants/image_paths.dart';
import 'package:with_calendar/utils/extensions/image_extension.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (_authService.isSignIn()) {
        const TabRoute().go(context);
      } else {
        const SignInRoute().go(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.whiteAndBlack,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Image.asset(
            ImagePaths.logo,
            width: 300.cacheSize(context).toDouble(),
            height: 300.cacheSize(context).toDouble(),
            cacheWidth: 300.cacheSize(context),
            cacheHeight: 300.cacheSize(context),
          ),
        ),
      ),
    );
  }
}
