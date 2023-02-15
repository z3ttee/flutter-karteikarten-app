import 'dart:math';

import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/CardsManager.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';

class Iteration {
  List<Card> iterationCards = [];
   Module module;

  // late Random random;
  final CardsManager _cardsManager = CardsManager();
  final StorageManager _storageManager = StorageManager();
  bool init=false;

  Iteration(this.module);

   _initIteration() async {
    iterationCards = await _cardsManager.getAllCards(module.id);
    iterationCards.shuffle();
  }

  Future<Card?> getNext() async {
    if(!init){
      await _initIteration();
      init = true;
    }
    if (iterationCards.isEmpty) return null;

    Card result = iterationCards.last;
    iterationCards.removeLast();
    return result;
  }

  void setCardState(String cardId, bool correct) {
    module.cards[cardId]!.lastCorrect = correct;
    _storageManager.saveCard(module.id, module.cards[cardId]!);
  }
}
