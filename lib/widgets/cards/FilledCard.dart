
import 'package:flutter/material.dart';

import '../../constants.dart';

class FilledCard extends StatelessWidget {

  final double? elevation;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const FilledCard({
    super.key,
    this.elevation,
    this.child, 
    this.padding,
    this.borderRadius
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 0,
      shape: RoundedRectangleBorder(
        // Only show a border, if card type is not "filled"
        side: const BorderSide(
          width: 0,
          color: Colors.transparent
        ),
        borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? Constants.cardBorderRadius))
      ),
      color: Theme.of(context).colorScheme.surfaceVariant,
      shadowColor: Theme.of(context).colorScheme.shadow,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      child: Padding(padding: padding ?? const EdgeInsets.all(Constants.cardInnerPadding), child: child ?? Container()),
    );
  }

}