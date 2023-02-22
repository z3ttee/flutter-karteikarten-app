import 'package:uuid/uuid.dart';

class IndexCard {
  String question = "";
  String answer = "";
  bool lastCorrect = false;
  String id = "";

  IndexCard(this.question, this.answer) {
    const uuid = Uuid();
    id = uuid.v4();
  }

  IndexCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        answer = json['answer'],
        question = json['question'],
        lastCorrect = json['lastCorrect'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'lastCorrect': lastCorrect
      };
}
