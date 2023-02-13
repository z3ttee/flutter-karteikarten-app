import 'dart:convert';

import 'package:uuid/uuid.dart';

class Card{

  String question = "";
  String answer = "";
  bool lastCorrect = false;
  String id = "";

  //Card([this.question = "", this.answer = ""]);
  Card(this.question , this.answer){
    var uuid = Uuid();
    id = uuid.v1();
  }

  toJson(){
    return jsonEncode( {
      "id": id,
      "question": question,
      "answer": answer,
      "lastCorrect" : lastCorrect
    });
  }
}


