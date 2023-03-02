import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/widgets/icons/cardSentiment.dart';
import 'package:go_router/go_router.dart';

class IndexCardItemCard extends StatelessWidget {

  /// Module data to display in the card
  final IndexCard indexCard;

  final bool answerRevealed;

  /// Callback function to handle clicks on the card
  final ValueSetter<IndexCard>? onPressed;

  /// Callback function to show an edit button and handle the button press
  final ValueSetter<IndexCard>? onEditPressed;

  final ValueSetter<IndexCard>? onDeletePressed;

  const IndexCardItemCard({
    super.key,
    required this.indexCard,
    required this.answerRevealed,
    this.onPressed,
    this.onEditPressed,
    this.onDeletePressed,
  });

  _openMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.sectionMarginX, vertical: Constants.sectionMarginX),
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Bearbeiten"),
                  subtitle: const Text("Frage oder Beschreibung einer Karte bearbeiten"),
                  onTap: () {
                    ctx.pop();
                    onEditPressed?.call(indexCard);
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24))
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Löschen"),
                  subtitle: const Text("Eine Karte löschen"),
                  onTap: () {
                    ctx.pop();
                    onDeletePressed?.call(indexCard);
                  },
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.listGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IndexCardSentiment(card: indexCard),
          const SizedBox(width: Constants.sectionMarginX,),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Question
                  Text(
                    indexCard.question,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  /// Answer
                  _renderAnswer(indexCard.answer, answerRevealed, context),
                ],
              )
          ),
          const SizedBox(width: Constants.listGap,),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Chip(
                label: Text(indexCard.cardWeight.name),
                labelStyle: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(width: Constants.listGap,),
          Column(
            children: [
              IconButton(
                  onPressed: () => _openMoreMenu(context),
                  icon: const Icon(Icons.more_vert)
              ),
            ],
          )
        ],
      ),
    );
  }

  _renderAnswer(String description, bool revealed, BuildContext context) {
    if(revealed) {
      return Text(
        description,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: Constants.cardAnswerBlur, sigmaY: Constants.cardAnswerBlur),
      child: Text(
        description,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );

    return SizedBox(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Text(description),
      )
    );
  }
}
