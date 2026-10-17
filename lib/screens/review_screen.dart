import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../core/responsive/responsive.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/quiz_provider.dart';
import '../widgets/common/responsive_body.dart';
import '../widgets/common/key_button.dart';
import '../widgets/result/review_item_card.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<QuizProvider>().session;
    final indices = session == null
        ? <int>[]
        : List.generate(session.items.length, (i) => i);
    Widget item(int index) => ReviewItemCard(
      key: ValueKey(session!.items[index].question.id),
      item: session.items[index],
      index: index,
      answer: session.answers[index],
    );
    return Scaffold(
      body: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.review, style: AppTextStyles.of(context).headline),
            SizedBox(height: context.r.md),
            if (session == null)
              Text(AppStrings.noSession, style: AppTextStyles.of(context).body),
            if (context.r.isCompact)
              for (final index in indices)
                Padding(
                  padding: EdgeInsets.only(bottom: context.r.md),
                  child: item(index),
                )
            else
              for (var i = 0; i < indices.length; i += 2)
                Padding(
                  padding: EdgeInsets.only(bottom: context.r.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: item(indices[i])),
                      SizedBox(width: context.r.md),
                      Expanded(
                        child: i + 1 < indices.length
                            ? item(indices[i + 1])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
            KeyButton(
              label: AppStrings.back,
              secondary: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
