import 'dart:async';

import 'package:flutter_karteikarten_app/dialogs/confirmDeleteDialog.dart';
import 'package:flutter_karteikarten_app/dialogs/exportDialog.dart';
import 'package:flutter_karteikarten_app/dialogs/importDialog.dart';
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

class ModuleListData {
  final bool loading;
  final List<Module> modules;

  ModuleListData(this.loading, this.modules);
}

class ModuleListScreen extends StatefulWidget {
  const ModuleListScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ModuleListState();
  }

}

class _ModuleListState extends State<ModuleListScreen> {

  late final StreamController<ModuleListData> moduleStreamController;
  late final Stream<ModuleListData> moduleStream;
  late final StreamSubscription<ModuleListData> moduleSub;

  final TextEditingController importInputController = TextEditingController();

  final StorageManager storageManager = StorageManager();
  late ModuleListData currentData = ModuleListData(true, []);

  /// Navigate to the page to show module details
  void _navigateToModule(String moduleId) {
    context.pushNamed(RouteName.routeModuleInfo.value, params: { "moduleId": moduleId });
  }

  /// Load module list and update stream
  _fetchAndPushModules({bool silently = true}) {
    if (kDebugMode) {
      print("[ModuleListScreen] Fetching modules...");
    }

    // Push loading state
    _setLoading(!silently);

    // Read module list using storage manager
    storageManager.readAll().onError((error, stackTrace){
      // Handle errors and return empty map
      Snackbars.error("Fehler beim Laden der Module-Liste", context);
      return {};
    }).then((data){
      // Push modules to controller
      //print(ModuleListData(false, data.values.toList()));
      moduleStreamController.add(ModuleListData(false, data.values.toList()));
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize controller
    moduleStreamController = BehaviorSubject();
    // Get stream of controller
    moduleStream = moduleStreamController.stream;

    // Subscribe to module data stream
    moduleSub = moduleStream.listen((data) {
      currentData = data;
    });

    // Load module list and push to controller
    _fetchAndPushModules(silently: false);

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
    // Destroy streams
    moduleStreamController.close();
    moduleSub.cancel();

    // Unregister notifier if page is completely destroyed
    Notifier.unset(NotifierName.notifierModuleList);
  }

  /// Open module editor dialog
  _openModuleEditor(BuildContext ctx, Module? module) {
    showDialog(
        context: ctx,
        builder: (context) {
          // Use custom editor widget
          return ModuleEditorDialog(
            module: module,
            onDidChange: (module) {
              if(kDebugMode) {
                print("[ModuleListScreen] Module value changed");
              }

              // If module has changed, reload list to retrieve changes
              _fetchAndPushModules();
            },
          );
        }
    );
  }

  /// Delete a module
  Future<bool> _deleteModule(Module module) async {
    return await showDialog(
      context: context,
      builder: (ctx) => ConfirmDeleteDialog(
        title: "Modul löschen?",
        message: "Möchtest du das Modul wirklich löschen? Die Aktion kann nicht rückgängig gemacht werden.",
        onConfirmed: (confirmed) {
          if(confirmed) {
            ctx.pop(true);
          } else {
            ctx.pop(false);
          }
        },
      ),
    );
  }

  _forceDeleteModule(String moduleId) {
    // Call storage manager to delete a module identified by its id
    storageManager.deleteOneModule(moduleId).then((value){
      // Show snackbar
      Snackbars.message("Modul gelöscht", context);
      // Reload module list
      _fetchAndPushModules();
    }).onError((error, stackTrace){
      // Handle error
      Snackbars.error("Ein Fehler ist aufgetreten", context);
    });
  }

  /// Import json string to transfer modules
  _importModules(String jsonAsString) {
    // Set loading state
    _setLoading(true);

    // Import
    storageManager.import(jsonAsString).then((imported){
      if(imported) {
        // Reload module list on successful import
        _fetchAndPushModules();
      } else {
        Snackbars.message("Module konnten nicht importiert werden", context);
      }
    }).onError((error, stackTrace){
      // Reset loading state
      Snackbars.error("Beim Importieren ist ein Fehler aufgetreten", context);
    }).whenComplete(() {
      _setLoading(false);
    });
  }

  /// Set loading state
  _setLoading(bool loading) {
    // Push current module list but with the updated loading state
    moduleStreamController.add(ModuleListData(loading, currentData.modules));
  }

  _openShareDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const ExportModuleDialog()
    );
  }

  /// Open import dialog
  _openImportDialog() {
    showDialog(
        context: context,
        /// Use custom dialog widget
        builder: (ctx) => ImportModuleDialog(
          onDismissed: (data) {
            // Check if data was provided on dismiss
            // If true, data was validated and can be imported
            if(data != null) _importModules(data);
          },
        ),
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
            var isLoading = snapshot.data?.loading ?? false || snapshot.connectionState == ConnectionState.waiting;

            // Check if future produced an error
            if(isLoading) {
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
                /// App Bar
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
                /// Render list if list is not empty. Otherwise render placeholder
                ((snapshot.data?.modules.length ?? 0) > 0) ? _renderList(snapshot) : _renderPlaceholder(context),
              ],
            );
          }
      ),
    );
  }

  /// Function to render the list of modules
  Widget _renderList(AsyncSnapshot<ModuleListData> snapshot) {
    return SliverList(delegate: SliverChildBuilderDelegate((context, index) {
      if (snapshot.data == null) return _renderPlaceholder(context);

      int maxIndex = (snapshot.data?.modules.length ?? 1) - 1;
      Module module = snapshot.data!.modules.elementAt(index);

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
          onDismissed: (direction) => _forceDeleteModule(module.id),
          child: ModuleItemCard(
            module: module,
            filled: true,
            onPressed: (module) => _navigateToModule(module.id),
            onEditPressed: (module) {
              _openModuleEditor(context, module);
            },
          ),
          confirmDismiss: (direction) => _deleteModule(module),
        ),

      );
    },
      // Pass the amount of available items for the list
      // to render all available items
      childCount: snapshot.data?.modules.length ?? 0
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
      onPressed: () => _fetchAndPushModules(silently: false),
      label: const Text("Erneut versuchen"),
      icon: const Icon(Icons.sync),
    );
  }
}

