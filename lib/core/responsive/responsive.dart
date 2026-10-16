import 'package:flutter/material.dart';

/// Semua ukuran UI dihitung dari ukuran layar di sini,
/// jadi widget tidak perlu angka hardcode.
class Responsive {
  Responsive(this.context);
  final BuildContext context;

  Size get size => MediaQuery.sizeOf(context);

  // Basis desain HP 360dp. Di-clamp supaya tablet/web tidak terlalu raksasa
  // dan HP kecil tidak terlalu mengecil.
  double get scale => (size.shortestSide / 360).clamp(0.9, 1.4);

  // Satuan spasi dasar; semua token spasi kelipatan dari sini.
  double get unit => 8 * scale;

  double get xs => unit * 0.5;
  double get sm => unit;
  double get md => unit * 2;
  double get lg => unit * 3;
  double get xl => unit * 4;

  double font(double base) => base * scale;
  double wp(double f) => size.width * f;
  double hp(double f) => size.height * f;

  bool get isCompact => size.width < 600;
  bool get isMedium => size.width >= 600 && size.width < 1024;
  bool get isExpanded => size.width >= 1024;
  bool get isLandscape =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  double get contentMaxWidth =>
      isCompact ? double.infinity : (isMedium ? 640 : 960);
}

extension ResponsiveX on BuildContext {
  Responsive get r => Responsive(this);
}
