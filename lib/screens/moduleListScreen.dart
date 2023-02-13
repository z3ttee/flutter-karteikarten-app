
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/dialogs/moduleEditorDialog.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/widgets/dotDivider.dart';
import 'package:flutter_karteikarten_app/widgets/errorCard.dart';
import 'package:flutter_karteikarten_app/widgets/moduleItemCard.dart';
import '../entities/Module.dart';

class ModuleListScreen extends StatefulWidget {
  const ModuleListScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ModuleListState();
  }

}

class _ModuleListState extends State<ModuleListScreen> {

  // Create variable of type Future to not re-fetch all modules
  // when UI is rerendered
  late Future<List<Module>> _modules;

  Future<Map<String, Module>> _fetchModules() {
    StorageManager test = StorageManager();
    return test.getDummyModules(0);
  }

  Future<List<Module>> _fetchModulesAsList() {
    print("[ModuleList] Fetching modules...");
    return Future.delayed(const Duration(milliseconds: 300), () async {
      return _fetchModules().then((value) {
        // Create list from map values
        return value.values.toList();
      }).catchError((error) {
        // Return empty list
        return List<Module>.empty();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Set initial state of the widget
    // In this case, start fetching modules
    _reloadModules();
  }

  _openModuleEditor(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (context) {
          return const ModuleEditorDialog();
        }
    );
  }

  _reloadModules() {
    setState(() {
      _modules = _fetchModulesAsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => _openModuleEditor(context),
          child: const Icon(Icons.add)
      ),
      body: FutureBuilder(
          future: _modules,
          builder: (context, snapshot) {
            // Check if future is still fetching modules
            if (snapshot.connectionState != ConnectionState.done) {
              // If not done yet, show progress bar (circular) to
              // indicate loading
              return const Center(child: CircularProgressIndicator());
            }

            // Check if future produced an error
            if(snapshot.hasError) {
              // If true, show an error card
              return ErrorCard(title: "Whoops!", message: "Ein unerwarteter Fehler ist aufgetreten.", actions: [
                renderRetryAction()
              ],);
            }

            // Show a scroll view with the listed items
            // if snapshot has data
            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar.medium(
                  title: const Text("Modulübersicht"),
                  actions: <Widget>[
                    IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline))
                  ],
                ),
                // Render list if list is not empty. Otherwise render placeholder
                ((snapshot.data?.length ?? 0) > 0) ? _renderList(snapshot) : _renderPlaceholder(context),
              ],
            );
          }
      ),
    );
  }

  /// Function to render the list of modules
  Widget _renderList(AsyncSnapshot snapshot) {
    return SliverList(delegate: SliverChildBuilderDelegate((context, index) {
      if (snapshot.data == null) return _renderPlaceholder(context);

      int maxIndex = (snapshot.data?.length ?? 1) - 1;
      Module module = snapshot.data!.elementAt(index);

      return Padding(
        padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: (index == 0) ? 12 : 0,
            bottom: (index == maxIndex) ? 96 : 0),
        child: ModuleItemCard(
          name: module.name,
          description: module.description,
          cardsCount: module.cards.length,
          filled: true,
        ),
      );},
        // Pass the amount of available items for the list
        // to render all available items
        childCount: snapshot.data?.length ?? 0
    ));
  }

  /// Function to render the placeholder that is shown on empty lists
  Widget _renderPlaceholder(BuildContext context) {
    return SliverFillRemaining(
      child: ErrorCard(
        title: "Keine Module gefunden",
        message: "Leg' ein neues Modul an, um deine Karteikarten zu organisieren. Sobald du ein Modul erstellt hast, wird es hier angezeigt.",
        actions: [
          renderRetryAction(),
          const DotDivider(),
          TextButton.icon(
            onPressed: () => _openModuleEditor(context),
            label: const Text("Erstes Modul anlegen"),
            icon: const Icon(Icons.add_circle),
          ),
        ],
      ),
    );
  }

  Widget renderRetryAction() {
    return TextButton.icon(
      onPressed: _reloadModules,
      label: const Text("Erneut versuchen"),
      icon: const Icon(Icons.sync),
    );
  }
}

