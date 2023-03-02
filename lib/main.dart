import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/behaviours/pointerScrollBehaviour.dart';
import 'package:flutter_karteikarten_app/routes.dart';

void main() {
  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Karteikarten App',
      // Light theme settings
      theme: ThemeData(
        // Set theme as light-theme
        brightness: Brightness.light,
        // Material Design 3 verwenden
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        // Use Material Design 3 typography settings
        typography: Typography.material2021(),
        cardTheme: const CardTheme(
          margin: EdgeInsets.zero,
        )
      ),
      // Dark-Theme settings
      darkTheme: ThemeData(
        // Set theme as dark-theme
        brightness: Brightness.dark,
        // Material Design 3 verwenden
        useMaterial3: true,
        colorSchemeSeed: const Color(0xff6750a4),
        // Use Material Design 3 typography settings
        typography: Typography.material2021(),
        cardTheme: const CardTheme(
          margin: EdgeInsets.zero,
        ),
      ),
      // Pick light or dark theme based on device's settings
      themeMode: ThemeMode.system,
      // Hide "debug" banner
      debugShowCheckedModeBanner: false,
      // Allow scrolling via mouse-dragging on devices with cursors
      scrollBehavior: PointerScrollBehaviour(),

      routerConfig: Routes.router,
      // routes: Routes.list(),
      // initialRoute: Routes.routeHome,
    );
  }
}
