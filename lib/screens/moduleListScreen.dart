import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_karteikarten_app/notifiers/dataNotifiers.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import "package:universal_html/html.dart" as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/dialogs/moduleEditorDialog.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/widgets/cards/errorCard.dart';
import 'package:flutter_karteikarten_app/widgets/cards/moduleItemCard.dart';
import '../entities/Module.dart';
import '../utils/snackbars.dart';
import '../widgets/backgrounds/dismissToDeleteBackground.dart';

class ModuleListScreen extends StatefulWidget {
  const ModuleListScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ModuleListState();
  }

}

class _ModuleListState extends State<ModuleListScreen> {

  late final StreamController<List<Module>> moduleStreamController;
  late final Stream<List<Module>> moduleStream;

  final TextEditingController importInputController = TextEditingController();

  final StorageManager storageManager = StorageManager();
  
  void _navigateToModule(String moduleId) {
    context.pushNamed(RouteName.routeModuleInfo.value, params: { "moduleId": moduleId });
  }

  _fetchAndPushModules({bool silently = false}) {
    if (kDebugMode) {
      print("[ModuleListScreen] Fetching modules...");
    }

    storageManager.readAll().then((modules){
      moduleStreamController.add(modules.values.toList());
    });
  }

  @override
  void initState() {
    super.initState();

    moduleStreamController = BehaviorSubject();
    moduleStream = moduleStreamController.stream;

    _fetchAndPushModules();

    // Register notifier to receive information when a module was updated.
    Notifier.set(NotifierName.notifierModuleList, () {
      if(kDebugMode) print("[ModuleListScreen] Received notification: Updating module list.");
      // If notification was triggered, reload all modules
      _fetchAndPushModules();
    });
  }
  
  @override
  void dispose() {
    super.dispose();
    // Unregister notifier if page is completely destroyed
    Notifier.unset(NotifierName.notifierModuleList);
  }

  _openModuleEditor(BuildContext ctx, Module? module) {
    showDialog(
        context: ctx,
        builder: (context) {
          return ModuleEditorDialog(
            module: module,
            onDidChange: (module) {
              if(kDebugMode) {
                print("[ModuleListScreen] Module value changed");
              }

              _fetchAndPushModules();
            },
          );
        }
    );
  }

  _deleteModule(Module module) {
    storageManager.deleteOneModule(module.id).then((value){
      Snackbars.message("Modul gelöscht", context);
      _fetchAndPushModules();
    });
  }

  /// Export full module list into the users clipboard
  _exportAllModules() {
    // Call storage manager to export all modules
    storageManager.exportAll().then((value){
      // On success, module list is retrieved as json string
      // This string is now copied to clipboard
      ClipboardData data = ClipboardData(text: value);
      Clipboard.setData(data).then((value) {
        // Show snackbar on success
        Snackbars.message("Exportierte Daten in Zwischenablage gespeichert", context);
      });
    }).onError((error, stackTrace){
      Snackbars.message("Ein Fehler ist aufgetreten", context);
    });
  }

  _importModules(String jsonAsString) {
    if(kDebugMode) print(jsonAsString);
  }

  _openShareDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Exportieren"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("Möchtest du die gesamte Modulliste exportieren, um diese mit anderen zu teilen?"),
              SizedBox(height: Constants.listGap,),
              Text("Falls du nur ein Modul exportieren möchtest, kannst du dies auf der Kartenübersicht des Moduls tun."),
            ],
          ),
          actions: [
            TextButton(onPressed: () => context.pop(), child: const Text("Abbrechen")),
            FilledButton.tonal(
              onPressed: () {
                context.pop();
                _exportAllModules();
              },
              child: const Text("Alles exportieren"),
            ),
          ],
        );
      }
    );
  }

  _openImportDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text("Importieren"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Hier kannst du die Daten einfügen, die aus zuvor exportiert wurden."),
                const SizedBox(height: Constants.listGap,),
                TextFormField(
                  controller: importInputController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Datensatz zum Importieren *',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Dieses Feld wird benötigt';
                    }

                    return null;
                  },
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => context.pop(), child: const Text("Abbrechen")),
              FilledButton.tonal(
                  onPressed: () {
                    if(importInputController.value.text.isEmpty) {
                      return;
                    }

                    context.pop();
                    _importModules(importInputController.value.text);
                  },
                  child: const Text("Importieren")
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => _openModuleEditor(context, null),
          child: const Icon(Icons.add)
      ),
      body: StreamBuilder(
          stream: moduleStream,
          builder: (context, snapshot) {

            // Check if future produced an error
            if(snapshot.connectionState != ConnectionState.active) {
              // If true, show an error card
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
                // App Bar
                SliverAppBar.medium(
                  title: const Text("Modulübersicht"),
                  centerTitle: true,
                  // App Bar actions
                  actions: <Widget>[
                    IconButton(onPressed: () => _openImportDialog(), icon: const Icon(Icons.download_rounded)),
                    IconButton(onPressed: () => _openShareDialog(), icon: const Icon(Icons.ios_share)),
                    kIsWeb ? Padding(padding: const EdgeInsets.only(right: 12), child: IconButton(onPressed: () => html.window.open(Constants.repoUrl, "GitHub Repository"), icon: const Icon(Octicons.mark_github)),) : Container(),
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
            left: Constants.sectionMarginX,
            right: Constants.sectionMarginX,
            top: (index == 0) ? 0 : Constants.listGap,
            bottom: (index == maxIndex) ? Constants.bottomPaddingFab : 0),
        child: Dismissible(
          key: Key(module.id),
          background: const DismissToDeleteBackground(),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => _deleteModule(module),
          child: ModuleItemCard(
            module: module,
            filled: true,
            onPressed: (module) => _navigateToModule(module.id),
            onEditPressed: (module) {
              _openModuleEditor(context, module);
            },
          )
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
          const SizedBox(height: 4,),
          TextButton.icon(
            onPressed: () => _openModuleEditor(context, null),
            label: const Text("Erstes Modul anlegen"),
            icon: const Icon(Icons.add_circle),
          ),
        ],
      ),
    );
  }

  Widget renderRetryAction() {
    return TextButton.icon(
      onPressed: () => _fetchAndPushModules(),
      label: const Text("Erneut versuchen"),
      icon: const Icon(Icons.sync),
    );
  }
}

