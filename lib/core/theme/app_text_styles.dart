import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import 'app_tokens.dart';

class AppTextStyles {
  AppTextStyles.of(this.context);
  final BuildContext context;
  TextStyle _style(TextStyle base) => base.apply(
    fontSizeFactor: context.r.scale,
    color: Theme.of(context).colorScheme.onSurface,
  );
  TextStyle get displayXL => _style(AppTokens.displayXL);
  TextStyle get display => _style(AppTokens.display);
  TextStyle get headline => _style(AppTokens.headline);
  TextStyle get question => _style(AppTokens.question);
  TextStyle get title => _style(AppTokens.title);
  TextStyle get button => _style(AppTokens.button);
  TextStyle get body => _style(AppTokens.body);
  TextStyle get monoLabel => _style(AppTokens.monoLabel);
  TextStyle get monoData => _style(AppTokens.monoData);
  TextStyle get code => _style(AppTokens.code);
}
