import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';

class CardsManager {
  late StorageManager _storageManager;

  CardsManager() {
    _storageManager = StorageManager();
  }

  ///recive all saved Cards
  Future<List<IndexCard>> getAllCards(String? moduleId) async {
    if (moduleId == null) return [];
    //init sharedpreferences
    Map<String, Module>? currentData = await _storageManager.readAll();

    Map<String, IndexCard> cards = currentData[moduleId]!.cards;
    List<IndexCard> result = [];
    cards.forEach((key, value) {
      result.add(value);
    });
    return result;
  }

  ///retrieve all wrong answered Cards
  Future<List<IndexCard>> getWrongCards(String? moduleId) async {
    if (moduleId == null) return [];
    Map<String, Module>? currentData = await _storageManager.readAll();

    Map<String, IndexCard> cards = currentData[moduleId]!.cards;
    List<IndexCard> result = [];
    cards.forEach((key, value) {
      if (!value.lastCorrect) {
        result.add(value);
      }
    });
    return result;
  }

  ///retrieve all correct answered Cards
  Future<List<IndexCard>> getCorrectCards(String? moduleId) async {
    if (moduleId == null) return [];
    Map<String, Module>? currentData = await _storageManager.readAll();

    Map<String, IndexCard> cards = currentData[moduleId]!.cards;
    List<IndexCard> result = [];
    cards.forEach((key, value) {
      if (value.lastCorrect) {
        result.add(value);
      }
    });
    return result;
  }
}
