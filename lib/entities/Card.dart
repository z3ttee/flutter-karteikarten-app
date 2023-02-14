import 'package:uuid/uuid.dart';

class Card{

  String question = "";
  String answer = "";
  bool lastCorrect = false;
  String id = "";

  Card(this.question , this.answer){
    const uuid = Uuid();
    id = uuid.v4();
  }

   Card.fromJson(Map<String,dynamic> json):
         id = json['id'],
         answer = json['answer'],
         question = json['question'],
         lastCorrect = json['lastCorrect'];

  Map<String,dynamic> toJson()=>{
    'id': id,
    'question': question,
    'answer' : answer,
    'lastCorrect' : lastCorrect
  };
}

