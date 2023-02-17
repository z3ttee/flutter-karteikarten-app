
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/screens/iterationScreen.dart';
import 'package:flutter_karteikarten_app/screens/moduleInfoScreen.dart';
import 'package:flutter_karteikarten_app/screens/moduleListScreen.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static GoRouter router = GoRouter(
    routes: [
      GoRoute(name: RouteName.routeHome.value, path: "/", builder: (context, state) => const ModuleListScreen(), routes: [
        GoRoute(name: RouteName.routeModuleInfo.value, path: "module/:moduleId", builder: (context, state) => ModuleInfoScreen(activatedRoute: state)),
        GoRoute(name: RouteName.routeIteration.value, path: "iteration/:moduleId", builder: (context, state) => IterationScreen(activatedRoute: state))
      ]),
    ]
  );
}