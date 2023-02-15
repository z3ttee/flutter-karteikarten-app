import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/CardsManager.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';

class Iteration {
  List<IndexCard> _iterationCards = [];
   Module _module;

  // late Random random;
  final CardsManager _cardsManager = CardsManager();
  final StorageManager _storageManager = StorageManager();
  bool _init=false;

  Iteration(this._module);

   _initIteration() async {
    _iterationCards = await _cardsManager.getAllCards(_module.id);
    _iterationCards.shuffle();
  }

  Future<IndexCard?> getNext() async {
    if(!_init){
      await _initIteration();
      _init = true;
    }
    if (_iterationCards.isEmpty) return null;

    IndexCard result = _iterationCards.last;
    _iterationCards.removeLast();
    return result;
  }

  void setCardState(String cardId, bool correct) {
    _module.cards[cardId]!.lastCorrect = correct;
    _storageManager.saveCard(_module.id, _module.cards[cardId]!);
  }
}
