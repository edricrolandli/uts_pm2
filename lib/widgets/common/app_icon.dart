import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_tokens.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(this.asset, {super.key, this.color});
  final String asset;
  final Color? color;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    width: AppGeometry.of(context).icon,
    height: AppGeometry.of(context).icon,
    excludeFromSemantics: true,
    colorFilter: ColorFilter.mode(
      color ?? Theme.of(context).colorScheme.onSurface,
      BlendMode.srcIn,
    ),
  );
}

class AssetPaletteMapper extends ColorMapper {
  const AssetPaletteMapper(this.palette);
  final AppPalette palette;
  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == AppTokens.light.ink) return palette.ink;
    if (color == AppTokens.light.surface) return palette.surface;
    if (color == AppTokens.light.amber) return palette.amber;
    return color;
  }
}
