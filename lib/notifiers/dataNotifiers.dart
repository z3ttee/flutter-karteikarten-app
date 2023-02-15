
class Notifier {

  static final Map<String, Function> _notifiers = {};

  static set(String name, Function notifier) {
    _notifiers[name] = notifier;
  }

  static unset(String name) {
    _notifiers.remove(name);
  }

  static notify(String name) {
    Function? notifier = _notifiers[name];
    notifier?.call();
  }

}