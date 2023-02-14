import 'dart:convert';

import 'package:uuid/uuid.dart';

class Card{

  String question = "";
  String answer = "";
  bool lastCorrect = false ;
  String id = "";

  //Card([this.question = "", this.answer = ""]);
  Card(this.question , this.answer){
    const uuid = Uuid();
    id = uuid.v1();
  }

   Card.fromJson(Map<String,dynamic> json):
         id = json['id'],
         answer = json['answer'],
         question = json['question'],
         lastCorrect = json['lastCorrect'];

       /*
    Card card = Card( json['question'], json['answer']);
    card.id = json['id'];
    card.lastCorrect = json['lastCorrect'];
    return card;
  */

  Map<String,dynamic> toJson()=>{
    'id': id,
    'question': question,
    'answer' : answer,
    'lastCorrect' : lastCorrect
  };
}

