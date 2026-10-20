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
import '../widgets/common/bottom_action_bar.dart';
import '../widgets/common/theme_toggle_button.dart';
import '../core/routes/app_routes.dart';
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
  bool _busy = false;
  Future<void> _start() async {
    if (_busy) return;
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
      if (mounted) Navigator.of(context).pushNamed(AppRoutes.identity);
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
    Widget artwork(double height) => SvgPicture.asset(
      AssetPaths.doodle,
      height: height,
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
      ],
    );
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
    );
    final branding = Row(
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
    );
    final start = BottomActionBar(
      primary: KeyButton(
        label: AppStrings.start,
        icon: AssetPaths.arrow,
        onPressed: _busy ? null : _start,
      ),
    );
    if (!r.isCompact || r.isShort) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.homeSideMargin + r.md,
                  vertical: r.sm,
                ),
                child: branding,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: r.homeSideMargin + r.md,
                          right: r.md,
                          top: r.sm,
                          bottom: r.md,
                        ),
                        child: intro,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) =>
                                  SingleChildScrollView(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: r.md,
                                              right: r.homeSideMargin + r.md,
                                              top: r.sm,
                                            ),
                                            child: form,
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: artwork(
                                              r.homeArtworkHeight(
                                                constraints.maxHeight,
                                                saved != null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: r.homeSideMargin),
                            child: start,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(r.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          branding,
                          SizedBox(height: r.xl),
                          intro,
                          SizedBox(height: r.lg),
                          form,
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: artwork(g.doodleHeight),
                    ),
                  ],
                ),
              ),
            ),
            start,
          ],
        ),
      ),
    );
  }
}
