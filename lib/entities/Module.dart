import 'Card.dart';
import 'package:uuid/uuid.dart';

class Module{

  String name = "";
  String? description = "";
  String id = "";
  Map<String,Card> cards = {};
  int correctCards = 0;
  int iterations = 0;

  void addCard(Card card){
    cards[card.id]= card;
  }

  Map<String,Card> getCards(){
    return cards;
  }

  Map<String, dynamic> toJson(){
    Map<String, dynamic> result = {};
    List list = [];
    cards.forEach((key, value) { list.add(value);});
    result.addAll({
      'name' : name,
      'description': description,
      'id' : id,
      'cards' : list
    });
    return result;
  }

   Module.fromJson(Map<String,dynamic> json):
         name = json['name'],
         description= json['description'],
         id = json['id'],
         cards = Card.fromJson(json['cards'])as Map<String,Card>;
      /*
  {
    Module module = Module(json['name'], json['description']);
    module.id = json['id'];
    module.cards = Card.fromJson(json['cards'])as Map<String,Card>;
    return module;
  }
  */



  Module(this.name, this.description){
    var uuid = const Uuid();
    id = uuid.v1();

  }


}