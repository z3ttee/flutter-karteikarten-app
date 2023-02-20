import 'package:flutter_karteikarten_app/constants.dart';
import 'package:uuid/uuid.dart';

class IndexCard {
  String question = "";
  String answer = "";
  bool lastCorrect = false;
  String id = "";
  CardAnswer cardAnswer = CardAnswer.never;
  CardWeight cardWeight = CardWeight.normal;
  String? color;

  IndexCard(this.question, this.answer) {
    const uuid = Uuid();
    id = uuid.v4();
  }

  /*
  IndexCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        answer = json['answer'],
        question = json['question'],
        lastCorrect = json['lastCorrect'],
        cardAnswer = CardAnswer.getById(json['cardAnswer']),
        cardWeight = CardWeight.getById(json['cardWeight']),
        color = json['color']
  ;
*/
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
