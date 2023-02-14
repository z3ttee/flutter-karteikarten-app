
import 'package:flutter/cupertino.dart';
import 'package:flutter_karteikarten_app/screens/moduleInfoScreen.dart';
import 'package:flutter_karteikarten_app/screens/moduleListScreen.dart';

class Routes {
  static const String routeHome = "/";
  static const String routeModuleInfo = "/module";

  static Map<String, Widget Function(BuildContext)> list() {
    return {
      Routes.routeHome: (context) => const ModuleListScreen(),
      Routes.routeModuleInfo: (context) => const ModuleInfoScreen()
    };
  }
}