import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../core/routes/app_routes.dart';
import '../core/responsive/responsive.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/quiz_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/common/responsive_body.dart';
import '../widgets/common/bottom_action_bar.dart';
import '../widgets/common/key_button.dart';
import '../widgets/common/mono_label.dart';
import '../widgets/home/name_input_field.dart';
import '../widgets/home/nim_input_field.dart';

class IdentityScreen extends StatefulWidget {
  const IdentityScreen({super.key});
  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: context.read<QuizProvider>().lastName,
  );
  late final _nim = TextEditingController(
    text: context.read<QuizProvider>().lastNim,
  );
  bool _busy = false;
  @override
  void dispose() {
    _name.dispose();
    _nim.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await context.read<QuizProvider>().startNew(_name.text, _nim.text);
      if (!mounted) return;
      context.read<HistoryProvider>().selectNim(_nim.text);
      Navigator.of(context).pushReplacementNamed(AppRoutes.quiz);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(AppStrings.saveFailed)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ResponsiveBody(
      bottomBar: BottomActionBar(
        primary: KeyButton(
          label: AppStrings.start,
          onPressed: _busy ? null : _start,
        ),
        secondary: KeyButton(
          label: AppStrings.back,
          secondary: true,
          onPressed: _busy ? null : () => Navigator.pop(context),
        ),
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MonoLabel(AppStrings.identityEyebrow),
            SizedBox(height: context.r.sm),
            Text(
              AppStrings.identityTitle,
              style: AppTextStyles.of(context).headline,
            ),
            SizedBox(height: context.r.lg),
            NameInputField(controller: _name, enabled: !_busy),
            SizedBox(height: context.r.md),
            NimInputField(
              controller: _nim,
              enabled: !_busy,
              onSubmitted: _start,
            ),
          ],
        ),
      ),
    ),
  );
}
