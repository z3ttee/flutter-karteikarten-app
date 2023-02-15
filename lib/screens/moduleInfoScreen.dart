
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/routes.dart';
import 'package:flutter_karteikarten_app/sections/moduleStatistics/moduleStatisticsSection.dart';
import 'package:flutter_karteikarten_app/utils/snackbars.dart';
import 'package:flutter_karteikarten_app/widgets/cards/errorCard.dart';
import 'package:go_router/go_router.dart';
import '../entities/Module.dart';

class ModuleInfoArguments {
  final Module module;

  ModuleInfoArguments(this.module);
}

class ModuleInfoScreen extends StatefulWidget {
  final GoRouterState activatedRoute;

  const ModuleInfoScreen({
    super.key,
    required this.activatedRoute
  });

  @override
  State<StatefulWidget> createState() {
    return _ModuleInfoScreenState();
  }

}

class _ModuleInfoScreenState extends State<ModuleInfoScreen> {
  late Future<Module?> _module;
  List<String> _filters = [];

  _openModuleEditor() {

  }

  _addFilter(String name) {
    List<String> filtersCopy = _filters;
    filtersCopy.add(name);

    setState(() {
      _filters = filtersCopy;
    });
  }

  _removeFilter(String name) {
    List<String> filtersCopy = _filters;
    filtersCopy.remove(name);

    setState(() {
      _filters = filtersCopy;
    });
  }
  
  _toggleFilter(bool selected, String name) {
    if(selected) {
      _addFilter(name);
    } else {
      _removeFilter(name);
    }
  }

  _navigateHome() {
    if(context.canPop()) {
      // If the context can pop this page,
      // then do this to navigate back to previous page
      context.pop();
    } else {
      // Use goNamed() to not add this info route to the
      // routing history.
      context.goNamed(Routes.routeHome);
    }
  }

  Future<Module?> _fetchModule(String? moduleId) {
    StorageManager manager = StorageManager();

    if (kDebugMode) print("[ModuleInfoScreen] Loading module info page for moduleId '$moduleId'");
    if(moduleId == null) return Future(() => null);
    return manager.readOneModule(moduleId).then((value) {
      if (kDebugMode) print("[ModuleInfoScreen] Loaded module with id '$moduleId': \"${value?.name}\"");
      return value;
    }).onError((error, stackTrace) {
      if (kDebugMode) print("[ModuleInfoScreen] Failed loading module with id '$moduleId'");
      Snackbars.message("Ein unerwarteter Fehler ist aufgetreten.", context);
      return null;
    });
  }

  @override
  void initState() {
    super.initState();

    var moduleId = widget.activatedRoute.params["moduleId"];
    _module = _fetchModule(moduleId);

    _filters.add(Constants.filterAllName);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder<Module?>(
        future: _module,
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(),);
          }

          return snapshot.data == null ? _renderErrorScreen() : _renderInfoScreen(snapshot.data!);
        }
      ),
    );
  }

  Widget _renderInfoScreen(Module module) {
    return Scaffold(
      appBar: AppBar(
        title: Text(module.name),
        centerTitle: true,
        leading: BackButton(
          onPressed: () => _navigateHome(),
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Constants.sectionMarginY),
              child: ModuleStatisticsSection(module: module,),
            ),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: Constants.sectionMarginX+4,),
                  FilterChip(
                    label: const Text(Constants.filterAllName),
                    selected: _filters.contains(Constants.filterAllName),
                    onSelected: (selected) => _toggleFilter(selected, Constants.filterAllName)
                  ),
                  const SizedBox(width: Constants.listGap,),
                  FilterChip(
                      label: const Text(Constants.filterCorrectName),
                      selected: _filters.contains(Constants.filterCorrectName),
                      onSelected: (selected) => _toggleFilter(selected, Constants.filterCorrectName)
                  ),
                  const SizedBox(width: Constants.listGap,),
                  FilterChip(
                      label: const Text(Constants.filterWrongName),
                      selected: _filters.contains(Constants.filterWrongName),
                      onSelected: (selected) => _toggleFilter(selected, Constants.filterWrongName)
                  ),
                  const SizedBox(width: Constants.sectionMarginX+4,),
                ],
              ),
            ),
          ]
        ),
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
              onPressed: () => _navigateHome(),
              label: const Text("Zurück zur Startseite"),
              icon: const Icon(Icons.arrow_back),
            )
          ],
        ),
      ),
    );
  }

}