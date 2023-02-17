import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/CardsManager.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/constants.dart';

class Iteration {

  List<IndexCard> _iterationCards = [];
  final Module _module;

  final CardsManager _cardsManager = CardsManager();
  final StorageManager _storageManager = StorageManager();
  bool _init = false;
  CardFilter _filter = CardFilter.filterAll;

  Iteration(this._module, CardFilter filter) {
    _filter = filter;
  }

  _initIteration() async {
    if (_filter == CardFilter.filterAll) {
      _iterationCards = await _cardsManager.getAllCards(_module.id);
    } else if (_filter == CardFilter.filterCorrect) {
      _iterationCards = await _cardsManager.getWrongCards(_module.id);
    } else if (_filter == CardFilter.filterWrong) {
      _iterationCards = await _cardsManager.getCorrectCards(_module.id);
    }
    _iterationCards.shuffle();
  }

  Future<IndexCard?> getNext() async {
    if (!_init) {
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
