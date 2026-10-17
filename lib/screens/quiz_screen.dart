import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../core/constants/asset_paths.dart';
import '../core/responsive/responsive.dart';
import '../core/theme/app_tokens.dart';
import '../providers/quiz_provider.dart';
import '../widgets/common/app_icon.dart';
import '../widgets/common/mono_label.dart';
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
    final question = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: AppStrings.exit,
              onPressed: _busy ? null : () => Navigator.pop(context),
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
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
            child: r.isCompact
                ? SingleChildScrollView(
                    controller: _compactScroll,
                    padding: EdgeInsets.all(r.md),
                    child: Column(
                      children: [
                        question,
                        SizedBox(height: r.lg),
                        options,
                      ],
                    ),
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
                        child: SingleChildScrollView(
                          controller: _answerScroll,
                          padding: EdgeInsets.all(r.md),
                          child: options,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
