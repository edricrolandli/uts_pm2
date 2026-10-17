import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_tokens.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ExcludeSemantics(
        child: SvgPicture.asset(
          AssetPaths.doodle,
          height: AppGeometry.of(context).doodleHeight * 0.5,
        ),
      ),
      SizedBox(height: context.r.md),
      Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.of(context).body,
      ),
    ],
  );
}
