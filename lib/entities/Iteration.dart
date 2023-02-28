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

  ///init function
  _initIteration() async {
    if (_filter == CardFilter.filterAll) {
      _iterationCards = await _cardsManager.getAllCards(module.id);
    } else if (_filter == CardFilter.filterCorrect) {
      _iterationCards = await _cardsManager.getWrongCards(module.id);
    } else if (_filter == CardFilter.filterWrong) {
      _iterationCards = await _cardsManager.getCorrectCards(module.id);
    }
    //shuffle the itteration
    _iterationCards.shuffle();
    //get Card Count
    totalCardCount = _iterationCards.length;
  }

  ///get one Card
  Future<IndexCard?> getNext() async {
    if (!_init) {
      await _initIteration();
      _init = true;
    }
    //null check, return null if the iteration is done
    if (_iterationCards.isEmpty) return null;

    IndexCard result = _iterationCards.last;
    _iterationCards.removeLast();
    _currentCard = result;
    currentCardCount++;
    return result;
  }

  /// set the answer state of the current card
  void setCardState(bool correct) {

    //count the wrong and correct answers
    if (correct) {
      correctAnswers++;
    } else {
      wrongAnswers++;
    }

    //set correct state
    _currentCard.lastCorrect = correct;
    module.cards[_currentCard.id] = _currentCard;
  }

  ///set the Answer state
  void setCardAnswerState(CardAnswer state) {
    _currentCard.cardAnswer = state;
    module.cards[_currentCard.id] = _currentCard;
  }

  ///Complete the iteration
  Future<bool> complete() {
    //increment iteration count
    module.iterations++;
    module.cards[_currentCard.id] = _currentCard;
    //save the iteration in the storage
    return _storageManager.saveModule(module);
  }
}
