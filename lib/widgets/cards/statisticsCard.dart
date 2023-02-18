import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/widgets/cards/FilledCard.dart';

class StatCard extends StatelessWidget {
  final double? width;
  final String title;
  final String value;
  final String? unit;

  const StatCard({
    super.key,
    this.width = 128,
    required this.title,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: FilledCard(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
              style: Theme.of(context).textTheme.labelMedium?.merge(TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
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
