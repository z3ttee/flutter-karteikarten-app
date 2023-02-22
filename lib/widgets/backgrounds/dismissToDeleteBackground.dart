import 'package:flutter/material.dart';
import '../../constants.dart';

class DismissToDeleteBackground extends StatelessWidget {
  const DismissToDeleteBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 0,
          bottom: 0,
          right: 0
      ),
      child: Container(
        padding: const EdgeInsets.only(
            top: 0,
            bottom: 0,
            right: Constants.sectionMarginX
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(Constants.cardBorderRadius/2),
              bottomRight: Radius.circular(Constants.cardBorderRadius/2)),
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
