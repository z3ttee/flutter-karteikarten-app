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
  final CardFilter _filter;

  int wrongAnswers = 0;
  int correctAnswers = 0;

  Iteration(this._module, this._filter);

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
    if(correct) {
      correctAnswers++;
    } else {
      wrongAnswers++;
    }

    _module.cards[cardId]!.lastCorrect = correct;
    _storageManager.saveCard(_module.id, _module.cards[cardId]!);
  }

  Future<bool> complete() {
    _module.iterations++;
    return _storageManager.saveModule(_module);
  }
}
