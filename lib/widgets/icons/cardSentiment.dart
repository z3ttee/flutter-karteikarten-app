import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/entities/Card.dart';

class IndexCardSentiment extends StatelessWidget {
  final IndexCard card;

  const IndexCardSentiment({
    super.key,
    required this.card
  });

  @override
  Widget build(BuildContext context) {
    IconData data;

    if(card.cardAnswer == CardAnswer.correct) {
      data = Icons.sentiment_very_satisfied_outlined;
    } else if(card.cardAnswer == CardAnswer.neutral) {
      data = Icons.sentiment_neutral_outlined;
    } else if(card.cardAnswer == CardAnswer.wrong) {
      data = Icons.sentiment_dissatisfied_outlined;
    } else {
      data = Icons.fiber_new_outlined;
    }

    return Icon(data);
  }

}