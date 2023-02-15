
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/widgets/cards/FilledCard.dart';

class IndexCardItemCard extends StatelessWidget {
  final bool filled;

  /// Module data to display in the card
  final IndexCard indexCard;
  /// Callback function to handle clicks on the card
  final ValueSetter<IndexCard>? onPressed;
  /// Callback function to show an edit button and handle the button press
  final ValueSetter<IndexCard>? onEditPressed;

  const IndexCardItemCard({
    super.key,
    required this.indexCard,
    this.onPressed,
    this.filled = false,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed?.call(indexCard),
      child: FilledCard(
        child: Padding(
          padding: const EdgeInsets.all(Constants.cardInnerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(indexCard.question, style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(
                      fontWeight: FontWeight.w400,
                      letterSpacing: Theme.of(context).textTheme.labelLarge?.letterSpacing,
                      color: Theme.of(context).colorScheme.onSurfaceVariant
                  )),)
                ],
              ),
              // Render module description, if there is a description
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 16),
                child: Text(
                  indexCard.answer,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyMedium?.merge(TextStyle(
                    fontWeight: FontWeight.w400,
                    letterSpacing: Theme.of(context).textTheme.labelLarge?.letterSpacing,
                    color: Theme.of(context).colorScheme.onSurfaceVariant
                  )),
                ),
              ),
              // Render bottom row of card containing stats and actions
              Row(
                children: [
                  // Chip for displaying stats
                  Chip(
                    label: Row(
                      children: [
                        Icon(indexCard.lastCorrect ? Icons.check : Icons.close),
                        const SizedBox(width: Constants.listGap,),
                        Text(indexCard.lastCorrect ? 'Korrekt beantwortet' : 'Falsch beantwortet'),
                      ],
                    ),
                    side: const BorderSide(color: Colors.transparent),
                    labelStyle: Theme.of(context).textTheme.labelMedium?.merge(TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(130),
                        fontWeight: FontWeight.w600
                    )),
                    shadowColor: Theme.of(context).colorScheme.shadow,
                    surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  // Row for actions, takes up all remaining width
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Only show edit button, if there
                        // is an event handler registered to catch the click
                        onEditPressed == null ? Container() : Padding(padding: const EdgeInsets.only(left: 8), child: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => onEditPressed?.call(indexCard),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                            disabledBackgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.12),
                            hoverColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.08),
                            focusColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
                            highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
                          ),
                        ),)
                      ],
                    ),)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}