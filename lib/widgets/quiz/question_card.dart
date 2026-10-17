import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/question.dart';
import '../common/ink_surface.dart';
import '../common/mono_label.dart';
import 'code_block.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question, required this.index});
  final Question question;
  final int index;
  @override
  Widget build(BuildContext context) => InkSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoLabel(AppStrings.questionNumber(index)),
        SizedBox(height: context.r.md),
        Text(question.text, style: AppTextStyles.of(context).question),
        if (question.codeSnippet != null) ...[
          SizedBox(height: context.r.md),
          CodeBlock(question.codeSnippet!),
        ],
      ],
    ),
  );
}
