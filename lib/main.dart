import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/behaviours/pointerScrollBehaviour.dart';
import 'package:flutter_karteikarten_app/screens/moduleListScreen.dart';

void main() {
  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      ),
      // Dark-Theme settings
      darkTheme: ThemeData(
        // Set theme as dark-theme
        brightness: Brightness.dark,
        // Material Design 3 verwenden
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
        // Use Material Design 3 typography settings
        typography: Typography.material2021(),
      ),
      // Pick light or dark theme based on device's settings
      themeMode: ThemeMode.system,
      // Hide "debug" banner
      debugShowCheckedModeBanner: false,
      // Allow scrolling via mouse-dragging on devices with cursors
      scrollBehavior: PointerScrollBehaviour(),
      routes: {
        '/': (context) => const ModuleListScreen(),
      },
    );
  }
}
