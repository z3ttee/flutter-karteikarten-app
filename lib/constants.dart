
class Constants {
  static const String charDot = "•";
  static const String repoUrl = "https://github.com/z3ttee/flutter-karteikarten-app";
  static const double listGap = 8;
  static const double bottomPaddingFab = 96;

  static const double sectionContentGap = 6;

  static const double cardInnerPadding = 16;
  static const double cardBorderRadius = 10;

  static const double sectionMarginY = 10;
  static const double sectionMarginX = 16;
}

enum CardAnswer{
  never(0),
  wrong(1),
  neutral(2),
  correct(3);

  final int value;
  const CardAnswer(this.value);

  static getById(int id){
    return CardAnswer.values.elementAt(id);
  }
}

enum CardWeight{
  normal(1),
  medium(2),
  hard(3);

  final int value;
  const CardWeight(this.value);

  static getById(int id){
    return CardWeight.values.elementAt(id -1);
  }
}

enum CardFilter {
  filterAll("Alle"),
  filterWrong("Falsch"),
  filterCorrect("Korrekt");

  final String value;
  const CardFilter(this.value);
}

enum RouteName {
  routeHome("home"),
  routeModuleInfo("moduleInfo"),
  routeIteration("iteration");

  final String value;
  const RouteName(this.value);
}

enum NotifierName {
  notifierModuleList("ModuleListNotifier"),
  notifierModuleInfo("ModuleInfoNotifier");

  final String value;
  const NotifierName(this.value);
}