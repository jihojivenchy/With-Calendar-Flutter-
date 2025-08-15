
import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF409060)
          ),
          const SizedBox(height: 16),
          AppText(
            text: title,
            textAlign: TextAlign.center,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            textColor: const Color(0xFF898989),
          ),
        ],
      ),
    );
  }
}