import 'Card.dart';
import 'package:uuid/uuid.dart';

class Module{

  String name = "";
  String? description = "";
  String id = "";
  Map<String,IndexCard> cards = {};
  int correctCards = 0;
  int iterations = 0;

  void addCard(IndexCard card){
    cards[card.id]= card;
  }

  Map<String,IndexCard> getCards(){
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
      'iterations': iterations,
      'cards' : list
    });
    return result;
  }

   Module.fromJson(Map<String,dynamic> json):
         name = json['name'],
         description= json['description'],
         id = json['id'],
         iterations= json['iterations'],
         cards = IndexCard.fromJson(json['cards'])as Map<String,IndexCard>;
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