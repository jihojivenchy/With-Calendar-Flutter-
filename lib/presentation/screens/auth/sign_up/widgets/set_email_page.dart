import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class SetEmailPage extends StatefulWidget {
  const SetEmailPage({
    super.key,
    required this.focusNode,
    required this.emailController,
    required this.onSubmitted,
  });

  final FocusNode focusNode;
  final TextEditingController emailController;
  final Function(String) onSubmitted;

  @override
  State<SetEmailPage> createState() => _SetEmailPageState();
}

class _SetEmailPageState extends State<SetEmailPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const AppText(text: '이메일', fontSize: 18),
            const SizedBox(height: 8),
            AppTextField(
              focusNode: widget.focusNode,
              controller: widget.emailController,
              placeholderText: '이메일을 입력하세요',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) {
                if (email == null || email.isEmpty) {
                  return '이메일을 입력해주세요.';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(email)) {
                  return '유효한 이메일 형식이 아닙니다.';
                }
                return null;
              },
              onSubmitted: (email) => widget.onSubmitted(email),
            ),
          ],
        ),
      ),
    );
  }
}
