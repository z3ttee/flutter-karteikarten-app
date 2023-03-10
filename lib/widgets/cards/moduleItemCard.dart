import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/utils/calc.dart';
import 'package:flutter_karteikarten_app/widgets/cards/FilledCard.dart';
import 'package:flutter_karteikarten_app/widgets/dividers/dotDivider.dart';

class ModuleItemCard extends StatelessWidget {
  final bool filled;

  /// Module data to display in the card
  final Module module;

  /// Callback function to handle clicks on the card
  final ValueSetter<Module>? onPressed;

  /// Callback function to show an edit button and handle the button press
  final ValueSetter<Module>? onEditPressed;

  const ModuleItemCard({
    super.key,
    required this.module,
    this.onPressed,
    this.filled = false,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledCard(
      onTap: () => Future.delayed(const Duration(milliseconds: 50), () => onPressed?.call(module)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  module.name,
                  style: Theme.of(context).textTheme.headlineSmall?.merge(
                      TextStyle(
                          fontWeight: FontWeight.w400,
                          letterSpacing: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.letterSpacing,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                )
              ],
            ),
            // Render module description, if there is a description
            module.description != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 16),
                    child: Text(
                      module.description!,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyMedium?.merge(
                          TextStyle(
                              fontWeight: FontWeight.w400,
                              letterSpacing: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.letterSpacing,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ),
                  )
                : Container(),
            // Render bottom row of card containing stats and actions
            Row(
              children: [
                // Chip for displaying stats
                Chip(
                  label: Row(
                    children: [
                      Text("${module.cards.length} Karte${(module.cards.length != 1 ? 'n' : '')}"),
                      const DotDivider(),
                      Text("${Calc.calcModuleProgress(module)} %"),
                    ],
                  ),
                  side: const BorderSide(color: Colors.transparent),
                  labelStyle: Theme.of(context).textTheme.labelMedium?.merge(
                      TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withAlpha(130),
                          fontWeight: FontWeight.w600)),
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
                      /*Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: IconButton(
                          icon: const Icon(Icons.alarm),
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            disabledBackgroundColor: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.12),
                            hoverColor: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.08),
                            focusColor: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.12),
                            highlightColor: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.12),
                          ),
                        ),
                      ),*/
                      // Only show edit button, if there
                      // is an event handler registered to catch the click
                      onEditPressed == null
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => onEditPressed?.call(module),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  disabledBackgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withOpacity(0.12),
                                  hoverColor: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.08),
                                  focusColor: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.12),
                                  highlightColor: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.12),
                                ),
                              ),
                            )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
    );
  }
}
