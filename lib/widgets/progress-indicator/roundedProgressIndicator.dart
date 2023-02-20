
import 'package:flutter/material.dart';

class RoundedProgressIndicator extends StatelessWidget {
  final double? progress;

  const RoundedProgressIndicator({
    super.key,
    this.progress
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(64)),
      child: progress == null ? LinearProgressIndicator(color: Theme.of(context).colorScheme.secondary, minHeight: 4,) : LinearProgressIndicator(
        value: progress,
        minHeight: 4,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

}