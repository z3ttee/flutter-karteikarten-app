
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

  static const String notifierModuleList = "ModuleListNotifier";
}

enum CardFilter {
  filterAll("Alle"),
  filterWrong("Falsch"),
  filterCorrect("Korrekt");

  final String value;
  const CardFilter(this.value);
}