
import 'package:flutter/material.dart';

import '../../constants.dart';

class FilledCard extends StatelessWidget {

  final double? elevation;
  final Widget? child;

  const FilledCard({
    super.key,
    this.elevation,
    this.child
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 0,
      shape: const RoundedRectangleBorder(
        // Only show a border, if card type is not "filled"
        side: BorderSide(
          width: 0,
          color: Colors.transparent
        ),
        borderRadius: BorderRadius.all(Radius.circular(Constants.cardBorderRadius))
      ),
      color: Theme.of(context).colorScheme.surfaceVariant,
      shadowColor: Theme.of(context).colorScheme.shadow,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      child: child ?? Container(),
    );
  }

}