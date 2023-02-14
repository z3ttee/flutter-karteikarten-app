
import 'package:flutter_karteikarten_app/screens/moduleInfoScreen.dart';
import 'package:flutter_karteikarten_app/screens/moduleListScreen.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const String routeHome = "home";
  static const String routeModuleInfo = "moduleInfo";

  static GoRouter router = GoRouter(
    routes: [
      GoRoute(name: routeHome, path: "/", builder: (context, state) => const ModuleListScreen(), routes: [
        GoRoute(name: routeModuleInfo, path: "module/:moduleId", builder: (context, state) => ModuleInfoScreen(activatedRoute: state))
      ]),
    ]
  );
}