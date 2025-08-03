import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.question_mark_outlined,
            size: 64,
            color: Color(0xFF898989),
          ),
          const SizedBox(height: 16),
          AppText(
            text: title,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            textColor: const Color(0xFF898989),
          ),
        ],
      ),
    );
  }
}
