
import 'package:flutter/material.dart';
import '../entities/Module.dart';

class ModuleInfoArguments {
  final Module module;

  ModuleInfoArguments(this.module);
}

class ModuleInfoScreen extends StatefulWidget {
  const ModuleInfoScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ModuleInfoScreenState();
  }

}

class _ModuleInfoScreenState extends State<ModuleInfoScreen> {
  late final Module _module;

  @override
  void initState() {
    super.initState();

    // Get arguments from route
    // Extract module from route args
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ModuleInfoArguments;
    Module module = args.module;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

}