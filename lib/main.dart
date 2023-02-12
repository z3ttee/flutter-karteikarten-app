import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_karteikarten_app/behaviours/pointerScrollBehaviour.dart';
import 'package:flutter_karteikarten_app/views/moduleList.dart';

void main() {
  // Add google fonts licence to the app
  LicenseRegistry.addLicense(() async* {
    final licenseRobotoFlex = await rootBundle.loadString('google_fonts/ROBOTO_FLEX_OFL.txt');
    final licenseRobotoSerif = await rootBundle.loadString('google_fonts/ROBOTO_SERIF_OFL.txt');

    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseRobotoFlex);
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseRobotoSerif);
  });

  // Disable fetching of google fonts at runtime (only
  // bundled fonts are used)
  // GoogleFonts.config.allowRuntimeFetching = false;

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
      theme: ThemeData(
        // Material Design 3 verwenden
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        // Use Material Design 3 typography settings
        typography: Typography.material2021(),
      ),
      // Allow scrolling via mouse-dragging on devices with cursors
      scrollBehavior: PointerScrollBehaviour(),
      home: const MyHomePage(title: 'Modulübersicht'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Karteikarten", style: TextStyle(),),
      ),
      body: const ModuleListView(),
    );
  }
}
