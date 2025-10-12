import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/utils/extensions/validation_extension.dart';

class SetEmailPage extends StatefulWidget {
  const SetEmailPage({
    super.key,
    required this.focusNode,
    required this.onSubmitted,
    required this.onEmailChanged,
  });

  final FocusNode focusNode;
  final Function(String) onSubmitted;
  final Function(String) onEmailChanged;

  @override
  State<SetEmailPage> createState() => _SetEmailPageState();
}

class _SetEmailPageState extends State<SetEmailPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
              onTextChanged: widget.onEmailChanged,
              placeholderText: '이메일을 입력하세요',
              keyboardType: TextInputType.emailAddress,
              backgroundColor: context.surface,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) => email?.validateEmail(),
              onSubmitted: (email) => widget.onSubmitted(email),
            ),
          ],
        ),
      ),
    );
  }
}
