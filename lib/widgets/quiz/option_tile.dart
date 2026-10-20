import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/quiz_colors.dart';
import '../common/app_icon.dart';

enum OptionState { idle, selected, correct, wrong, revealed, locked }

class OptionTile extends StatefulWidget {
  const OptionTile({
    super.key,
    required this.index,
    required this.text,
    required this.state,
    required this.onPressed,
  });
  final int index;
  final String text;
  final OptionState state;
  final VoidCallback? onPressed;
  @override
  State<OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(vsync: this);
  bool _pressed = false;
  bool _focused = false;
  @override
  void didUpdateWidget(covariant OptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _pressed = false;
      _shake.reset();
      if (widget.state == OptionState.wrong &&
          !AppMotion.of(context).disabled) {
        _shake.duration = AppMotion.of(context).shake;
        _shake.forward(from: 0);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.of(context).disabled) _shake.reset();
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final qc = context.quizColors;
    final g = AppGeometry.of(context);
    final styles = AppTextStyles.of(context);
    final correct = widget.state == OptionState.correct;
    final wrong = widget.state == OptionState.wrong;
    final revealed = widget.state == OptionState.revealed;
    final selected = widget.state == OptionState.selected;
    final answered = widget.state != OptionState.idle && !selected;
    final background = correct
        ? qc.correctContainer
        : wrong
        ? qc.wrongContainer
        : scheme.surface;
    final foreground = correct
        ? qc.onCorrectContainer
        : wrong
        ? qc.onWrongContainer
        : scheme.onSurface;
    final border = correct || revealed
        ? qc.correct
        : wrong
        ? qc.wrong
        : widget.state == OptionState.locked
        ? scheme.outlineVariant
        : scheme.outline;
    final stateLabel = switch (widget.state) {
      OptionState.correct => AppStrings.selectedCorrect,
      OptionState.wrong => AppStrings.selectedWrong,
      OptionState.revealed => AppStrings.answerKey,
      OptionState.locked => AppStrings.locked,
      OptionState.idle => '',
      OptionState.selected => AppStrings.selectedPending,
    };
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      selected: selected || correct || wrong,
      label: AppStrings.optionSemantics(widget.index, widget.text, stateLabel),
      onTap: widget.onPressed,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _shake,
          builder: (context, child) => Transform.translate(
            offset: Offset(
              AppMotion.of(context).disabled
                  ? 0
                  : math.sin(
                          _shake.value *
                              AppTokens.shakeRadians *
                              AppTokens.shakeCycles,
                        ) *
                        g.shake *
                        (1 - _shake.value),
              0,
            ),
            child: child,
          ),
          child: AnimatedScale(
            scale: _pressed ? AppTokens.pressedScale : 1,
            duration: AppMotion.of(context).short,
            child: AnimatedContainer(
              duration: AppMotion.of(context).medium,
              curve: AppTokens.curveStandard,
              constraints: BoxConstraints(minHeight: g.buttonHeight),
              decoration: BoxDecoration(
                color: background,
                borderRadius: g.radiusMd,
                border: Border.all(
                  color: _focused ? scheme.onSurface : border,
                  width: correct || wrong || revealed || selected || _focused
                      ? g.strokeThick
                      : g.strokeThin,
                ),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: widget.onPressed,
                  onHighlightChanged: (pressed) =>
                      setState(() => _pressed = pressed),
                  onFocusChange: (focused) =>
                      setState(() => _focused = focused),
                  borderRadius: g.radiusMd,
                  child: Padding(
                    padding: EdgeInsets.all(context.r.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: AppMotion.of(context).medium,
                          curve: AppTokens.curveStandard,
                          width: g.badge,
                          height: g.badge,
                          decoration: BoxDecoration(
                            color: selected ? scheme.onSurface : null,
                            borderRadius: answered ? g.radiusSm : g.badgeCircle,
                            border: Border.all(
                              color: border,
                              width: g.strokeThin,
                            ),
                          ),
                          child: Center(
                            child: correct || revealed
                                ? AppIcon(AssetPaths.check, color: foreground)
                                : wrong
                                ? AppIcon(AssetPaths.close, color: foreground)
                                : Text(
                                    AppStrings.optionLetters[widget.index],
                                    style: styles.monoLabel.copyWith(
                                      color: selected
                                          ? qc.palette.paper
                                          : foreground,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: context.r.md),
                        Expanded(
                          child: Text(
                            widget.text,
                            style: styles.title.copyWith(color: foreground),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
