
import 'package:flutter/material.dart';
import '../../constants.dart';

class FilledCard extends StatelessWidget {

  final double? elevation;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  final Function()? onTap;
  final Color? color;
  final bool disablePaddingX;

  const FilledCard({
    super.key,
    this.elevation,
    this.child, 
    this.padding,
    this.borderRadius,
    this.onTap,
    this.color,
    this.disablePaddingX = false
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
      color: color ?? Theme.of(context).colorScheme.surfaceVariant,
      shadowColor: Theme.of(context).colorScheme.shadow,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? Constants.cardBorderRadius)),
        child: Padding(
            padding: padding ?? (disablePaddingX ? const EdgeInsets.symmetric(vertical: Constants.cardInnerPadding) : const EdgeInsets.all(Constants.cardInnerPadding)),
            child: child ?? Container()
        ),
      )
    );
  }

}