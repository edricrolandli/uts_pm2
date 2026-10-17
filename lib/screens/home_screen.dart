import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../core/constants/asset_paths.dart';
import '../core/responsive/responsive.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/quiz_colors.dart';
import '../providers/history_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/common/app_icon.dart';
import '../widgets/common/key_button.dart';
import '../widgets/common/mono_label.dart';
import '../widgets/common/responsive_body.dart';
import '../widgets/common/theme_toggle_button.dart';
import '../widgets/home/name_input_field.dart';
import '../widgets/home/resume_card.dart';
import '../widgets/common/confirm_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenQuiz,
    required this.onOpenHistory,
  });
  final VoidCallback onOpenQuiz;
  final VoidCallback onOpenHistory;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: context.read<QuizProvider>().playerName,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (context.read<QuizProvider>().hasSavedSession) {
        final confirmed = await ConfirmDialog.ask(
          context,
          title: AppStrings.newTitle,
          message: AppStrings.newMessage,
          cancelLabel: AppStrings.cancel,
          confirmLabel: AppStrings.startNew,
        );
        if (!mounted || !confirmed) return;
      }
      await context.read<QuizProvider>().startNew(_name.text.trim());
      if (mounted) widget.onOpenQuiz();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(AppStrings.saveFailed)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resumeOrDiscard({bool discard = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final quiz = context.read<QuizProvider>();
      if (discard) {
        final confirmed = await ConfirmDialog.ask(
          context,
          title: AppStrings.discardTitle,
          message: AppStrings.discardMessage,
          cancelLabel: AppStrings.cancel,
          confirmLabel: AppStrings.discard,
        );
        if (!mounted || !confirmed) return;
        await quiz.discard();
      } else {
        await quiz.resume();
        if (mounted && quiz.session != null) widget.onOpenQuiz();
      }
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
  Widget build(BuildContext context) {
    final r = context.r;
    final g = AppGeometry.of(context);
    final styles = AppTextStyles.of(context);
    final palette = context.quizColors.palette;
    final saved = context.watch<QuizProvider>().savedSession;
    final artwork = SvgPicture.asset(
      AssetPaths.doodle,
      height: g.doodleHeight,
      fit: BoxFit.contain,
      alignment: Alignment.centerRight,
      excludeFromSemantics: true,
      colorMapper: AssetPaletteMapper(palette),
    );
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MonoLabel(AppStrings.homeEyebrow),
        SizedBox(height: r.md),
        Text(AppStrings.homeHeadline, style: styles.display),
        if (!r.isCompact) ...[SizedBox(height: r.xl), artwork],
      ],
    );
    final form = Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NameInputField(
            controller: _name,
            enabled: !_busy,
            onSubmitted: _start,
          ),
          SizedBox(height: r.md),
          KeyButton(
            label: AppStrings.start,
            icon: AssetPaths.arrow,
            onPressed: _busy ? null : _start,
          ),
          SizedBox(height: r.lg),
          if (saved != null) ...[
            ResumeCard(
              session: saved,
              onResume: _busy ? null : () => _resumeOrDiscard(),
              onDiscard: _busy ? null : () => _resumeOrDiscard(discard: true),
            ),
            SizedBox(height: r.lg),
          ],
          TextButton(
            onPressed: _busy ? null : widget.onOpenHistory,
            style: TextButton.styleFrom(
              foregroundColor: palette.ink,
              minimumSize: Size(0, g.touch),
              padding: EdgeInsets.zero,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.historyCount(
                      context.watch<HistoryProvider>().records.length,
                    ),
                    style: styles.body,
                  ),
                ),
                const AppIcon(AssetPaths.arrow),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      body: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  AssetPaths.logo,
                  width: g.logo,
                  height: g.logo,
                  excludeFromSemantics: true,
                  colorMapper: AssetPaletteMapper(palette),
                ),
                SizedBox(width: r.sm),
                Expanded(child: Text(AppStrings.appName, style: styles.title)),
                const ThemeToggleButton(),
              ],
            ),
            SizedBox(height: r.xl),
            if (r.isCompact) ...[
              intro,
              SizedBox(height: r.xl),
              form,
              SizedBox(height: r.lg),
              artwork,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: intro),
                  SizedBox(width: r.xl),
                  Expanded(child: form),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
