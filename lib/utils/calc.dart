
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';

class Calc {
  static int calcModuleProgress(Module module) {
    // Calculate how many cards were answered correctly in percent
    var successPercentage = (module.correctCards / (module.cards.isEmpty ? 1 : module.cards.length));
    // Convert to integer values between 0 and 100
    return (successPercentage * 100).round();
  }

  static Future<double> calcModuleLearningProgress(Module module) async {
    double totalPoints = 0;
    double reachedPoints = 0;
    var cards = module.cards.values.toList();

    for(var i = 0; i < cards.length; i++) {
      var card = cards.elementAt(i);
      totalPoints += card.cardWeight.value;

      if(card.cardAnswer == CardAnswer.correct) {
        // Add full amount of points if the answer was marked correct
        reachedPoints += card.cardWeight.value;
      } else if(card.cardAnswer == CardAnswer.neutral) {
        // If the answer type is neutral, then only add
        // half the points
        reachedPoints += card.cardWeight.value * 0.5;
      }
    }

    var progress = reachedPoints/totalPoints;
    return progress;
  }

}