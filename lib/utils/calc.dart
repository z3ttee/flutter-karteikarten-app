
import 'package:flutter_karteikarten_app/entities/Module.dart';

class Calc {
  static int calcModuleProgress(Module module) {
    // Calculate how many cards were answered correctly in percent
    var successPercentage = (module.correctCards / (module.cards.isEmpty ? 1 : module.cards.length));
    // Convert to integer values between 0 and 100
    return (successPercentage * 100).round();
  }

}