import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../core/constants/asset_paths.dart';
import '../core/responsive/responsive.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_tokens.dart';
import '../providers/quiz_provider.dart';
import '../widgets/common/app_icon.dart';
import '../widgets/common/mono_label.dart';
import '../widgets/common/key_button.dart';
import '../widgets/common/confirm_dialog.dart';
import '../widgets/quiz/segmented_progress.dart';
import '../widgets/quiz/question_card.dart';
import '../widgets/quiz/option_tile.dart';
import '../widgets/quiz/explanation_panel.dart';
import 'pending_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _compactScroll = ScrollController();
  final _questionScroll = ScrollController();
  final _answerScroll = ScrollController();
  bool _busy = false;
  bool _allowExit = false;
  bool _exitDialogOpen = false;

  @override
  void dispose() {
    _compactScroll.dispose();
    _questionScroll.dispose();
    _answerScroll.dispose();
    super.dispose();
  }

  Future<void> _select(int index) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await context.read<QuizProvider>().selectAnswer(index);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(AppStrings.saveFailed)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _advance() async {
    final quiz = context.read<QuizProvider>();
    if (_busy || !quiz.isCurrentAnswered) return;
    setState(() => _busy = true);
    try {
      if (quiz.isLastQuestion) {
        await quiz.finish();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.result);
        }
      } else {
        await quiz.next();
        if (!mounted) return;
        for (final controller in [
          _compactScroll,
          _questionScroll,
          _answerScroll,
        ]) {
          if (controller.hasClients) controller.jumpTo(0);
        }
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

  Future<void> _requestExit() async {
    if (_busy || _exitDialogOpen || _allowExit) return;
    _exitDialogOpen = true;
    final confirmed = await ConfirmDialog.ask(
      context,
      title: AppStrings.exitTitle,
      message: AppStrings.exitMessage,
      cancelLabel: AppStrings.stay,
      confirmLabel: AppStrings.exit,
    );
    _exitDialogOpen = false;
    if (!mounted || !confirmed) return;
    setState(() => _allowExit = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final session = quiz.session;
    if (session == null) {
      return PendingScreen(
        title: AppStrings.appName,
        message: AppStrings.noSession,
        onReturn: () => Navigator.pop(context),
      );
    }
    final r = context.r;
    final item = session.items[session.currentIndex];
    final answer = session.answers[session.currentIndex];
    final action = SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.all(r.md),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: AppGeometry.of(context).strokeThin,
            ),
          ),
        ),
        child: KeyButton(
          label: quiz.isLastQuestion ? AppStrings.finish : AppStrings.next,
          icon: AssetPaths.arrow,
          onPressed: _busy || answer == null ? null : _advance,
        ),
      ),
    );
    final question = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: AppStrings.exit,
              onPressed: _busy ? null : _requestExit,
              constraints: BoxConstraints(
                minWidth: AppGeometry.of(context).touch,
                minHeight: AppGeometry.of(context).touch,
              ),
              icon: const AppIcon(AssetPaths.close),
            ),
            SizedBox(width: r.sm),
            Expanded(
              child: MonoLabel(
                AppStrings.questionProgress(
                  session.currentIndex,
                  session.items.length,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: r.sm),
        SegmentedProgress(session: session),
        SizedBox(height: r.lg),
        QuestionCard(question: item.question, index: session.currentIndex),
      ],
    );
    final options = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < item.displayedOptions.length; i++) ...[
          OptionTile(
            key: ValueKey((item.question.id, i)),
            index: i,
            text: item.displayedOptions[i],
            state: answer == null
                ? OptionState.idle
                : i == answer
                ? i == item.displayedCorrectIndex
                      ? OptionState.correct
                      : OptionState.wrong
                : i == item.displayedCorrectIndex
                ? OptionState.revealed
                : OptionState.locked,
            onPressed: answer != null || _busy ? null : () => _select(i),
          ),
          SizedBox(height: r.sm),
        ],
        ExplanationPanel(
          key: ValueKey(item.question.id),
          explanation: item.question.explanation,
          answered: answer != null,
          correct: answer == item.displayedCorrectIndex,
        ),
      ],
    );
    return PopScope<void>(
      canPop: _allowExit || quiz.status != QuizStatus.inProgress,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
              child: r.isCompact
                  ? Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _compactScroll,
                            padding: EdgeInsets.all(r.md),
                            child: Column(
                              children: [
                                question,
                                SizedBox(height: r.lg),
                                options,
                              ],
                            ),
                          ),
                        ),
                        action,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _questionScroll,
                            padding: EdgeInsets.all(r.md),
                            child: question,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _answerScroll,
                                  padding: EdgeInsets.all(r.md),
                                  child: options,
                                ),
                              ),
                              action,
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
