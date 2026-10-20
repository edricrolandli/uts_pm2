import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_tokens.dart';
import '../common/mono_label.dart';

class NimInputField extends StatelessWidget {
  const NimInputField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onSubmitted,
  });
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback? onSubmitted;
  static String? validate(String? value) {
    final nim = value ?? '';
    if (nim.isNotEmpty && !RegExp(r'^\d+$').hasMatch(nim)) {
      return AppStrings.nimDigits;
    }
    if (nim.length != 9) return AppStrings.nimLength;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final g = AppGeometry.of(context);
    final colors = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: g.radiusMd,
      borderSide: BorderSide(color: color, width: width),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MonoLabel(AppStrings.nimLabel),
        SizedBox(height: context.r.sm),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          enabled: enabled,
          validator: validate,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: TextInputAction.go,
          onFieldSubmitted: (_) => onSubmitted?.call(),
          style: AppTextStyles.of(context).body,
          cursorColor: colors.onSurface,
          decoration: InputDecoration(
            hintText: AppStrings.nimHint,
            hintStyle: AppTextStyles.of(context).body
                .copyWith(color: colors.onSurfaceVariant),
            filled: true,
            fillColor: colors.surface,
            contentPadding: EdgeInsets.all(context.r.md),
            constraints: BoxConstraints(minHeight: g.touch),
            border: border(colors.outline, g.strokeThin),
            enabledBorder: border(colors.outline, g.strokeThin),
            disabledBorder: border(colors.outlineVariant, g.strokeThin),
            focusedBorder: border(colors.primary, g.strokeThick),
            errorBorder: border(colors.error, g.strokeThick),
            focusedErrorBorder: border(colors.error, g.strokeThick),
            errorStyle: AppTextStyles.of(context).body
                .copyWith(color: colors.onErrorContainer),
          ),
        ),
      ],
    );
  }
}
