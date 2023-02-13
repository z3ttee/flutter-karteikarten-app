
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget>? actions;

  const ErrorCard({
    super.key,
    required this.title,
    required this.message,
    this.actions
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Show a title
                    Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(
                      fontWeight: FontWeight.w400,
                      letterSpacing: Theme.of(context).textTheme.labelLarge?.letterSpacing,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),),
                    // Add spacing between title and message
                    const SizedBox(height: 16,),
                    // Show a message to the error with a line height of 1.5 dp
                    Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(
                        height: 1.5
                    )),),
                  ],
                ),
              ),
            ),
            // Actions section outside the card
            Padding(
              padding: EdgeInsets.all((actions?.length ?? 0) > 0 ? 8 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...?actions
                ],
              ),
            )
          ],
        ),
      )
    );
  }

}