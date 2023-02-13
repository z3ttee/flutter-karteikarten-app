
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/widgets/dotDivider.dart';

class ModuleItemCard extends StatelessWidget {

  /// Name of the module
  final String name;
  /// Description of the module
  final String? description;
  /// Amount of created cards inside the module
  final int cardsCount;
  /// Amount of incorrect answers during last iteration
  final int incorrectAnswers;
  /// Amount of iterations. During an iteration the user goes through all cards and
  /// tries answer them correctly
  final int iterations;

  final bool filled;

  const ModuleItemCard({
    super.key,
    required this.name,
    this.description,
    this.cardsCount = 0,
    this.incorrectAnswers = 0,
    this.iterations = 0,
    this.filled = false
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        // Only show a border, if card type is not "filled"
        side: BorderSide(
          width: filled ? 0 : 1,
          color: filled ? Colors.transparent : Theme.of(context).colorScheme.outline
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12))
      ),

      color: filled ? Theme.of(context).colorScheme.surfaceVariant : Theme.of(context).colorScheme.surface,
      shadowColor: Theme.of(context).colorScheme.shadow,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(
                  fontWeight: FontWeight.w400,
                  letterSpacing: Theme.of(context).textTheme.labelLarge?.letterSpacing,
                  color: Theme.of(context).colorScheme.onSurfaceVariant
                )),)
              ],
            ),
            // Render module description, if there is a description
            description != null ? Padding(padding: const EdgeInsets.only(top: 2, bottom: 16), child: Text(description!, textAlign: TextAlign.left, style: Theme.of(context).textTheme.bodyMedium?.merge(TextStyle(
                fontWeight: FontWeight.w400,
                letterSpacing: Theme.of(context).textTheme.labelLarge?.letterSpacing,
                color: Theme.of(context).colorScheme.onSurfaceVariant
            )),),) : Container(),
            // Render bottom row of card containing stats and actions
            Row(
              children: [
                // Chip for displaying stats
                Chip(
                  label: Row(
                    children: [
                      Text("$cardsCount Karte${(cardsCount != 1 ? 'n' : '')}"),
                      const DotDivider(),
                      Text("${((incorrectAnswers) / (cardsCount == 0 ? 1 : cardsCount)).round()} %")
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
                        Padding(padding: const EdgeInsets.only(left: 4), child: IconButton(
                          icon: const Icon(Icons.alarm),
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                            disabledBackgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.12),
                            hoverColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.08),
                            focusColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
                            highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
                          ),
                        ),),
                        Padding(padding: const EdgeInsets.only(left: 4), child: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
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
    );
  }

}