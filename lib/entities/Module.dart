import 'dart:convert';

import 'Card.dart';
import 'package:uuid/uuid.dart';

class Module{

  String name = "";
  String description = "";
  String id = "";
  Map<String,Card> cards = {};

  void addCard(Card card){
    cards[card.id]= card;
  }

  Map<String,Card> getCards(){
    return cards;
  }


  Module(this.name, this.description){
    var uuid = Uuid();
    id = uuid.v1();

  }

  toJson(){
    return jsonEncode( {
      "name" : name,
      "description" : description,
      "id" : id
    });
  }

}