import 'package:flutter/material.dart';
import '../../constants.dart';

class DismissToDeleteBackground extends StatelessWidget {
  const DismissToDeleteBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: Constants.cardInnerPadding,
          bottom: Constants.cardInnerPadding,
          right: Constants.cardInnerPadding),
      child: Container(
        padding: const EdgeInsets.only(
            top: Constants.cardInnerPadding,
            bottom: Constants.cardInnerPadding,
            right: Constants.cardInnerPadding),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(Constants.cardBorderRadius),
              bottomRight: Radius.circular(Constants.cardBorderRadius)),
          color: Theme.of(context).colorScheme.onError,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [Icon(Icons.delete_forever)],
        ),
      ),
    );
  }
}
