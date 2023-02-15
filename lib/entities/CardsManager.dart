import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';

class CardsManager{

  late StorageManager _storageManager;
  CardsManager(){
    _storageManager = StorageManager();
  }

  Future<List<Card>> getAllCards(String moduleId) async {
    Map<String,Module>? currentData = await _storageManager.readAll();

    Map<String, Card> cards = currentData[moduleId]!.cards;
    List<Card> result = [];
    cards.forEach((key, value) {
      result.add(value);
    });
    return result;
  }

  Future<List<Card>> getWrongCards(String moduleId) async {
    Map<String,Module>? currentData = await _storageManager.readAll();

    Map<String, Card> cards = currentData[moduleId]!.cards;
    List<Card> result = [];
    cards.forEach((key, value) {
      if(!value.lastCorrect) {
        result.add(value);
      }
    });
    return result;
  }

  Future<List<Card>> getCorrectCards(String moduleId) async {
    Map<String,Module>? currentData = await _storageManager.readAll();

    Map<String, Card> cards = currentData[moduleId]!.cards;
    List<Card> result = [];
    cards.forEach((key, value) {
      if(value.lastCorrect) {
        result.add(value);
      }
    });
    return result;
  }
}