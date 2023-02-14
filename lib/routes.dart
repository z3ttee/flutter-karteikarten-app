
import 'package:flutter/cupertino.dart';
import 'package:flutter_karteikarten_app/screens/moduleInfoScreen.dart';
import 'package:flutter_karteikarten_app/screens/moduleListScreen.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> list() {
    return {
      '/': (context) => const ModuleListScreen(),
      '/module': (context) => const ModuleInfoScreen()
    };
  }
}