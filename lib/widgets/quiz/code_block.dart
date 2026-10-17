import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/quiz_colors.dart';

class CodeBlock extends StatelessWidget {
  const CodeBlock(this.code, {super.key});
  final String code;
  static final _keywords = RegExp(
    r'\b(SELECT|FROM|WHERE|JOIN|INNER|LEFT|RIGHT|ON|AS|ORDER|BY|GROUP|HAVING|CREATE|TABLE|ALTER|ADD|COLUMN|PRIMARY|KEY|NOT|NULL|INSERT|INTO|VALUES|UPDATE|SET|DELETE|COUNT|AVG|INTEGER|VARCHAR|DECIMAL)\b',
    caseSensitive: false,
  );
  @override
  Widget build(BuildContext context) {
    final qc = context.quizColors;
    final spans = <TextSpan>[];
    var start = 0;
    for (final match in _keywords.allMatches(code)) {
      spans.add(TextSpan(text: code.substring(start, match.start)));
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      );
      start = match.end;
    }
    spans.add(TextSpan(text: code.substring(start)));
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.r.md),
      decoration: BoxDecoration(
        color: qc.codeBg,
        borderRadius: AppGeometry.of(context).radiusMd,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text.rich(
          TextSpan(children: spans),
          style: AppTextStyles.of(context).code.copyWith(color: qc.codeText),
          softWrap: false,
          semanticsLabel: code,
        ),
      ),
    );
  }
}
