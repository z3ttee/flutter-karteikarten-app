
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/routes.dart';
import 'package:flutter_karteikarten_app/sections/moduleStatistics/moduleStatisticsSection.dart';
import 'package:flutter_karteikarten_app/widgets/cards/errorCard.dart';
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

  _openModuleEditor() {

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var hasValidModule = ModalRoute.of(context)?.settings != null && ModalRoute.of(context)!.settings.arguments != null;

    if(hasValidModule) {
      return _renderInfoScreen();
    } else {
      return _renderErrorScreen();
    }
  }

  Widget _renderInfoScreen() {
    // Get arguments from route
    final args = ModalRoute.of(context)!.settings.arguments as ModuleInfoArguments;
    // Extract module from route args
    Module module = args.module;

    return Scaffold(
      appBar: AppBar(
        title: Text(module.name),
        centerTitle: true,
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _openModuleEditor(),
              icon: const Icon(Icons.edit)
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Constants.sectionMarginY),
            child: ModuleStatisticsSection(module: module,),
          )
        ],
      ),
    );
  }

  Widget _renderErrorScreen() {
    return Scaffold(
      body: Center(
        child: ErrorCard(
          title: "Whoops!",
          message: "Das aufgerufene Modul existiert nicht mehr",
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : Navigator.popAndPushNamed(context, Routes.routeHome),
              label: const Text("Zurück zur Startseite"),
              icon: const Icon(Icons.arrow_back),
            )
          ],
        ),
      ),
    );
  }

}