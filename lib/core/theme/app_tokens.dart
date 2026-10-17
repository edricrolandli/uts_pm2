import 'package:flutter/material.dart';

import '../responsive/responsive.dart';

class AppPalette {
  const AppPalette({
    required this.paper,
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.line,
    required this.outlineStrong,
    required this.amber,
    required this.amberContainer,
    required this.onAmberContainer,
    required this.keyEdge,
    required this.blueprint,
    required this.blueprintContainer,
    required this.correct,
    required this.correctContainer,
    required this.onCorrectContainer,
    required this.wrong,
    required this.wrongContainer,
    required this.onWrongContainer,
    required this.codeBg,
    required this.codeText,
  });
  final Color paper;
  final Color surface;
  final Color ink;
  final Color inkMuted;
  final Color line;
  final Color outlineStrong;
  final Color amber;
  final Color amberContainer;
  final Color onAmberContainer;
  final Color keyEdge;
  final Color blueprint;
  final Color blueprintContainer;
  final Color correct;
  final Color correctContainer;
  final Color onCorrectContainer;
  final Color wrong;
  final Color wrongContainer;
  final Color onWrongContainer;
  final Color codeBg;
  final Color codeText;
  AppPalette lerp(AppPalette other, double t) => AppPalette(
    paper: Color.lerp(paper, other.paper, t)!,
    surface: Color.lerp(surface, other.surface, t)!,
    ink: Color.lerp(ink, other.ink, t)!,
    inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
    line: Color.lerp(line, other.line, t)!,
    outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
    amber: Color.lerp(amber, other.amber, t)!,
    amberContainer: Color.lerp(amberContainer, other.amberContainer, t)!,
    onAmberContainer: Color.lerp(onAmberContainer, other.onAmberContainer, t)!,
    keyEdge: Color.lerp(keyEdge, other.keyEdge, t)!,
    blueprint: Color.lerp(blueprint, other.blueprint, t)!,
    blueprintContainer: Color.lerp(
      blueprintContainer,
      other.blueprintContainer,
      t,
    )!,
    correct: Color.lerp(correct, other.correct, t)!,
    correctContainer: Color.lerp(correctContainer, other.correctContainer, t)!,
    onCorrectContainer: Color.lerp(
      onCorrectContainer,
      other.onCorrectContainer,
      t,
    )!,
    wrong: Color.lerp(wrong, other.wrong, t)!,
    wrongContainer: Color.lerp(wrongContainer, other.wrongContainer, t)!,
    onWrongContainer: Color.lerp(onWrongContainer, other.onWrongContainer, t)!,
    codeBg: Color.lerp(codeBg, other.codeBg, t)!,
    codeText: Color.lerp(codeText, other.codeText, t)!,
  );
}

abstract final class AppTokens {
  static const light = AppPalette(
    paper: Color(0xFFF5F0E6),
    surface: Color(0xFFFFFCF5),
    ink: Color(0xFF1D1B16),
    inkMuted: Color(0xFF5C574B),
    line: Color(0xFFD8D0BD),
    outlineStrong: Color(0xFF1D1B16),
    amber: Color(0xFFF4B400),
    amberContainer: Color(0xFFFFE8A6),
    onAmberContainer: Color(0xFF3A2A00),
    keyEdge: Color(0xFF1D1B16),
    blueprint: Color(0xFF2F5D8A),
    blueprintContainer: Color(0xFFD6E4F3),
    correct: Color(0xFF1F8A55),
    correctContainer: Color(0xFFCFEFDB),
    onCorrectContainer: Color(0xFF0E4A2B),
    wrong: Color(0xFFC93A2E),
    wrongContainer: Color(0xFFF9D6D1),
    onWrongContainer: Color(0xFF651912),
    codeBg: Color(0xFF1D1B16),
    codeText: Color(0xFFF5F0E6),
  );
  static const dark = AppPalette(
    paper: Color(0xFF16140F),
    surface: Color(0xFF211F19),
    ink: Color(0xFFF3EEE2),
    inkMuted: Color(0xFFB3AC9C),
    line: Color(0xFF3A362C),
    outlineStrong: Color(0xFF8A8472),
    amber: Color(0xFFFFC21F),
    amberContainer: Color(0xFF4A3A05),
    onAmberContainer: Color(0xFFFFE8A6),
    keyEdge: Color(0xFF7A5A00),
    blueprint: Color(0xFF8DB8E3),
    blueprintContainer: Color(0xFF1F3A57),
    correct: Color(0xFF5FD08F),
    correctContainer: Color(0xFF17402B),
    onCorrectContainer: Color(0xFFCFEFDB),
    wrong: Color(0xFFFF8A7D),
    wrongContainer: Color(0xFF4A1D18),
    onWrongContainer: Color(0xFFF9D6D1),
    codeBg: Color(0xFF0F0E0B),
    codeText: Color(0xFFF3EEE2),
  );
  static const transparent = Color(0x00000000);
  static const textScaleMax = 1.3;
  static const pressedScale = .98;
  static const curveStandard = Curves.easeOutCubic;
  static const curveExpressive = Curves.easeOutBack;
  static const durShort = Duration(milliseconds: 120);
  static const durMedium = Duration(milliseconds: 240);
  static const durLong = Duration(milliseconds: 420);
  static const durShake = Duration(milliseconds: 360);
  static const shakeCycles = 3;
  static const shakeRadians = 6.283185307179586;
  static const noMotion = Duration.zero;
  static const zero = 0.0;
  static const fullRadius = BorderRadius.all(Radius.circular(999));
  static const nunito = 'Nunito';
  static const mono = 'JetBrainsMono';
  static const displayXL = TextStyle(
    fontFamily: nunito,
    fontWeight: FontWeight.w800,
    fontSize: 72,
    height: .95,
    letterSpacing: -2,
  );
  static const display = TextStyle(
    fontFamily: nunito,
    fontWeight: FontWeight.w800,
    fontSize: 40,
    height: 1.05,
    letterSpacing: -1,
  );
  static const headline = TextStyle(
    fontFamily: nunito,
    fontWeight: FontWeight.w800,
    fontSize: 28,
    height: 1.15,
    letterSpacing: -.5,
  );
  static const question = TextStyle(
    fontFamily: nunito,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 1.3,
  );
  static const title = TextStyle(
    fontFamily: nunito,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.3,
  );
  static const button = TextStyle(
    fontFamily: nunito,
    fontWeight: FontWeight.w800,
    fontSize: 18,
    height: 1.3,
  );
  static const body = TextStyle(
    fontFamily: nunito,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.45,
  );
  static const monoLabel = TextStyle(
    fontFamily: mono,
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 1.2,
    letterSpacing: .8,
  );
  static const monoData = TextStyle(
    fontFamily: mono,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.4,
  );
  static const code = TextStyle(
    fontFamily: mono,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
  );
}

class AppGeometry {
  AppGeometry.of(BuildContext context) : unit = context.r.unit;
  final double unit;
  BorderRadius get radiusSm => BorderRadius.circular(unit);
  BorderRadius get radiusMd => BorderRadius.circular(unit * 2);
  BorderRadius get radiusLg => BorderRadius.circular(unit * 3.5);
  double get strokeThin => unit * .125;
  double get strokeThick => unit * .25;
  double get keyEdge => unit * .5;
  double get touch => (unit * 6).clamp(48, double.infinity);
  double get buttonHeight => unit * 7;
  double get icon => unit * 3;
  double get badge => unit * 5;
  double get logo => unit * 6;
  double get segmentHeight => unit;
  double get shake => unit * .75;
  double get doodleHeight => unit * 25;
}

class AppMotion {
  AppMotion.of(BuildContext context)
    : disabled = MediaQuery.disableAnimationsOf(context);
  final bool disabled;
  Duration get short => disabled ? Duration.zero : AppTokens.durShort;
  Duration get medium => disabled ? Duration.zero : AppTokens.durMedium;
  Duration get long => disabled ? Duration.zero : AppTokens.durLong;
  Duration get shake => disabled ? Duration.zero : AppTokens.durShake;
}
