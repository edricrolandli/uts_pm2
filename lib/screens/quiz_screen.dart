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
import '../widgets/common/bottom_action_bar.dart';
import '../widgets/common/confirm_dialog.dart';
import '../widgets/quiz/segmented_progress.dart';
import '../widgets/quiz/question_card.dart';
import '../widgets/quiz/option_tile.dart';
import '../widgets/quiz/explanation_panel.dart';
import '../widgets/quiz/timer_chip.dart';
import 'pending_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  final _compactScroll = ScrollController();
  final _questionScroll = ScrollController();
  final _answerScroll = ScrollController();
  bool _busy = false;
  bool _allowExit = false;
  bool _exitDialogOpen = false;
  bool _navigating = false;
  int? _visibleIndex;
  late final QuizProvider _quiz;

  @override
  void initState() {
    super.initState();
    _quiz = context.read<QuizProvider>();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _quiz.resumeTimer();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_exitDialogOpen) {
      _quiz.resumeTimer();
    } else {
      _quiz.pauseTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _quiz.pauseTimer();
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
    if (_busy || !quiz.isCurrentResolved) return;
    setState(() => _busy = true);
    try {
      if (quiz.isLastQuestion) {
        await quiz.finish();
      } else {
        await quiz.next();
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
    _quiz.pauseTimer();
    final confirmed = await ConfirmDialog.ask(
      context,
      title: AppStrings.exitTitle,
      message: AppStrings.exitMessage,
      cancelLabel: AppStrings.stay,
      confirmLabel: AppStrings.exit,
    );
    _exitDialogOpen = false;
    if (!mounted) return;
    if (_quiz.status == QuizStatus.finished) {
      _openResult();
      return;
    }
    if (!confirmed) {
      _quiz.resumeTimer();
      return;
    }
    // Setiap jawaban/next sudah disimpan provider. Izinkan pop satu kali
    // setelah dialog disetujui; keluar tidak memanggil discard().
    setState(() => _allowExit = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop();
  }

  void _openResult() {
    if (!mounted || _navigating || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    _navigating = true;
    Navigator.of(context).pushReplacementNamed(AppRoutes.result);
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final session = quiz.session;
    if (quiz.status == QuizStatus.finished && !_navigating) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openResult());
    }
    if (_visibleIndex != quiz.currentIndex) {
      _visibleIndex = quiz.currentIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final controller in [
          _compactScroll,
          _questionScroll,
          _answerScroll,
        ]) {
          if (controller.hasClients) controller.jumpTo(0);
        }
      });
    }
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
    final action = BottomActionBar(
      primary: KeyButton(
        label: quiz.timerFailed
            ? AppStrings.retrySave
            : !quiz.isCurrentResolved
            ? AppStrings.submitAnswer
            : quiz.isLastQuestion
            ? AppStrings.finish
            : AppStrings.next,
        icon: AssetPaths.arrow,
        onPressed: _busy
            ? null
            : quiz.timerFailed
            ? quiz.retryTimeout
            : quiz.isCurrentResolved
            ? _advance
            : quiz.pendingAnswer == null
            ? null
            : () => _select(quiz.pendingAnswer!),
      ),
    );
    final header = Column(
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
            if (!r.isCompact) ...[
              Expanded(child: SegmentedProgress(session: session)),
              SizedBox(width: r.md),
            ],
            SizedBox(width: r.sm),
            TimerChip(
              seconds: quiz.remainingSeconds,
              answered: quiz.isCurrentResolved,
              expired: session.expired[session.currentIndex],
            ),
          ],
        ),
        if (r.isCompact) ...[
          SizedBox(height: r.sm),
          SegmentedProgress(session: session),
        ],
      ],
    );
    final question = QuestionCard(
      question: item.question,
      index: session.currentIndex,
    );
    final options = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < item.displayedOptions.length; i++) ...[
          OptionTile(
            key: ValueKey((item.question.id, i)),
            index: i,
            text: item.displayedOptions[i],
            state: !quiz.isCurrentResolved
                ? (quiz.pendingAnswer == i
                      ? OptionState.selected
                      : OptionState.idle)
                : i == answer
                ? i == item.displayedCorrectIndex
                      ? OptionState.correct
                      : OptionState.wrong
                : i == item.displayedCorrectIndex
                ? OptionState.revealed
                : OptionState.locked,
            onPressed:
                quiz.isCurrentResolved || _busy || quiz.remainingSeconds == 0
                ? null
                : () => quiz.chooseAnswer(i),
          ),
          SizedBox(height: r.sm),
        ],
        ExplanationPanel(
          key: ValueKey(item.question.id),
          explanation: item.question.explanation,
          answered: quiz.isCurrentResolved,
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
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.all(r.md), child: header),
                  Expanded(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
