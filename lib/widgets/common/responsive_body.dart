import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';

class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child, this.bottomBar});
  final Widget child;
  final Widget? bottomBar;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.r.contentMaxWidth),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(context.r.md),
                child: child,
              ),
            ),
            ?bottomBar,
          ],
        ),
      ),
    ),
  );
}
