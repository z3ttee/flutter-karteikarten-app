
import 'package:flutter_karteikarten_app/constants.dart';

class Notifier {

  static final Map<String, Function> _notifiers = {};

  static set(NotifierName name, Function notifier) {
    _notifiers[name.value] = notifier;
  }

  static unset(NotifierName name) {
    _notifiers.remove(name.value);
  }

  static notify(NotifierName name) {
    Function? notifier = _notifiers[name.value];
    notifier?.call();
  }

}