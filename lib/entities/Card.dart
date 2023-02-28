import 'package:flutter_karteikarten_app/constants.dart';
import 'package:uuid/uuid.dart';

class IndexCard {
  String question = "";
  String answer = "";
  bool lastCorrect = false;
  String id = "";
  CardAnswer cardAnswer = CardAnswer.never;
  CardWeight cardWeight = CardWeight.simple;
  String? color;

  IndexCard(this.question, this.answer) {
    const uuid = Uuid();
    id = uuid.v4();
  }

 // implement toJson method for storage handling
  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'lastCorrect': lastCorrect,
        'cardWeight': cardWeight.value,
        'cardAnswer': cardAnswer.value,
        'color': color
      };
}
