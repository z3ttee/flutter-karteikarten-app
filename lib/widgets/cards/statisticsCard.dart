import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/widgets/cards/FilledCard.dart';

class StatCard extends StatelessWidget {
  final double? width;
  final String title;
  final String? value;
  final String? unit;

  final Widget? customChild;
  final double? elevation;
  final Color? backgroundColor;

  final bool disablePaddingX;

  const StatCard({
    super.key,
    required this.title,
    this.width = 128,
    this.value,
    this.unit,
    this.customChild,
    this.elevation, this.backgroundColor,
    this.disablePaddingX = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: FilledCard(
        borderRadius: 4,
        elevation: elevation ?? 0,
        color: backgroundColor,
        disablePaddingX: disablePaddingX,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Constants.listGap),
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                style: Theme.of(context).textTheme.labelMedium?.merge(TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5)),
              ),
            ),
            customChild ?? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                value == null ? Container() : Text(
                  value!,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                unit == null
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(top: 12, left: 4),
                        child: Text(
                          unit!,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              letterSpacing: 1.5),
                        ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
