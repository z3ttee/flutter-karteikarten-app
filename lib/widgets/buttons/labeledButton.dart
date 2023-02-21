
import 'package:flutter/material.dart';

class LabeledButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function() onPressed;

  const LabeledButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
          child: Column(
            children: [
              Icon(icon, size: 24, color: Theme.of(context).colorScheme.secondary,),
              const SizedBox(height: 4,),
              Text(text, style: Theme.of(context).textTheme.labelSmall?.merge(TextStyle(
                color: Theme.of(context).colorScheme.secondary
              )),)
            ],
          ),
        )
    );
  }

}