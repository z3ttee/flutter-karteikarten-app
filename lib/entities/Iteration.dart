import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/CardsManager.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/constants.dart';

class Iteration {
  List<IndexCard> _iterationCards = [];
  final Module module;

  final CardsManager _cardsManager = CardsManager();
  final StorageManager _storageManager = StorageManager();
  bool _init = false;
  final CardFilter _filter;
  late IndexCard _currentCard;

  int currentCardCount = 0;
  int totalCardCount = 0;
  int wrongAnswers = 0;
  int correctAnswers = 0;

  Iteration(this.module, this._filter);

  _initIteration() async {
    if (_filter == CardFilter.filterAll) {
      _iterationCards = await _cardsManager.getAllCards(module.id);
    } else if (_filter == CardFilter.filterCorrect) {
      _iterationCards = await _cardsManager.getWrongCards(module.id);
    } else if (_filter == CardFilter.filterWrong) {
      _iterationCards = await _cardsManager.getCorrectCards(module.id);
    }
    _iterationCards.shuffle();
    totalCardCount = _iterationCards.length;
  }

  Future<IndexCard?> getNext() async {
    if (!_init) {
      await _initIteration();
      _init = true;
    }
    if (_iterationCards.isEmpty) return null;

    IndexCard result = _iterationCards.last;
    _iterationCards.removeLast();
    _currentCard = result;
    currentCardCount++;
    return result;
  }

  void setCardState(bool correct) {
    if (correct) {
      correctAnswers++;
    } else {
      wrongAnswers++;
    }
    _currentCard.lastCorrect = correct;
  }

  void setCardAnswerState(CardAnswer state) {
    _currentCard.cardAnswer = state;
  }

  Future<bool> complete() {
    module.iterations++;
    module.cards[_currentCard.id] = _currentCard;
    return _storageManager.saveModule(module);
  }
}
