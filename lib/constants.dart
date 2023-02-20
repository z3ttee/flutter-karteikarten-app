
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
  never(-1),
  wrong(0),
  neutral(1),
  correct(2);

  final int value;
  const CardAnswer(this.value);
}

enum CardWeight{
  normal(1),
  medium(2),
  hard(3);

  final int value;
  const CardWeight(this.value);
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