
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/dialogs/cardEditorDialog.dart';
import 'package:flutter_karteikarten_app/dialogs/moduleEditorDialog.dart';
import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/CardsManager.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/notifiers/dataNotifiers.dart';
import 'package:flutter_karteikarten_app/sections/moduleInfoScreen/moduleListFilterSection.dart';
import 'package:flutter_karteikarten_app/sections/moduleInfoScreen/moduleStatisticsSection.dart';
import 'package:flutter_karteikarten_app/utils/calc.dart';
import 'package:flutter_karteikarten_app/utils/snackbars.dart';
import 'package:flutter_karteikarten_app/widgets/backgrounds/dismissToDeleteBackground.dart';
import 'package:flutter_karteikarten_app/widgets/cards/errorCard.dart';
import 'package:flutter_karteikarten_app/widgets/cards/indexCardItemCard.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import '../dialogs/exportDialog.dart';
import '../entities/Module.dart';

class ModuleInfoData {
  final Module? module;
  final List<IndexCard> indexCards;

  ModuleInfoData(this.module, this.indexCards);
}

class _CardListState {
  final bool isLoading;
  final List<IndexCard> cards;

  _CardListState({
    required this.isLoading,
    required this.cards
  });
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

  late final StreamController<Module?> moduleStreamController;
  late final StreamController<_CardListState> cardStreamController;
  late final StreamController<CardFilter> filterStreamController;
  late final StreamController<double> progressStreamController;

  late final Stream<Module?> moduleStream;
  late final Stream<_CardListState> cardStream;
  late final Stream<CardFilter> filterStream;
  late final Stream<double> progressStream;

  late final StreamSubscription<CardFilter> filterSubscription;

  late final String? _currentModuleId;
  final StorageManager storageManager = StorageManager();
  final CardsManager cardsManager = CardsManager();

  CardFilter currentFilter = CardFilter.filterAll;
  List<IndexCard> currentCardsState = [];

  @override
  void initState() {
    super.initState();

    // Extract module id from route
    _currentModuleId = widget.activatedRoute.params["moduleId"];

    // Initialize stream controllers for updating data
    moduleStreamController = BehaviorSubject();
    cardStreamController = BehaviorSubject();
    filterStreamController = BehaviorSubject();
    progressStreamController = BehaviorSubject();

    // Initialize stream to listen to data changes
    moduleStream = moduleStreamController.stream;
    cardStream = cardStreamController.stream;
    filterStream = filterStreamController.stream;
    progressStream = progressStreamController.stream;

    // Fetch module and push result to stream
    _fetchAndPushModule(_currentModuleId);

    // Fetch cards and push result to stream
    _fetchAndPushCards(_currentModuleId, CardFilter.filterAll);

    // Subscribe to changes to the filter value and re-fetch cards
    filterSubscription = filterStream.listen((filter) {
      currentFilter = filter;
      _fetchAndPushCards(_currentModuleId, filter);
    });

    // Listen for notifications to update cards list
    Notifier.set(NotifierName.notifierModuleInfo, () {
      if(kDebugMode) print("[ModuleInfoScreen] Received notification: Updating cards list using current filter.");
      // If notification was triggered, reload all modules and card list
      _fetchAndPushModule(_currentModuleId);
      _fetchAndPushCards(_currentModuleId, currentFilter, silently: true);
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Close streams to free resources
    moduleStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed module stream.");
    });
    cardStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed card stream.");
    });
    filterStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed filter stream.");
    });
    progressStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed filter stream.");
    });

    // Close subscriptions
    filterSubscription.cancel();

    // Stop listening for notifications
    Notifier.unset(NotifierName.notifierModuleInfo);
  }

  /// Fetch a module identified by an id
  _fetchAndPushModule(String? moduleId) {
    if (kDebugMode) print("[ModuleInfoScreen] Loading module info page for moduleId '$moduleId'");

    // Create delayed future to prevent animation stuttering
    return Future<Module?>.delayed(const Duration(milliseconds: 200), () => storageManager.readOneModule(moduleId)).then((value) {
      moduleStreamController.add(value);

      if(value != null) {
        _fetchAndPushProgress(value);
      }
    });
  }

  /// Calculate progress bar for a module
  _fetchAndPushProgress(Module module) {
    // Asynchronously calculate progress and push the result to re-render UI
    Calc.calcModuleLearningProgress(module).then((value){
      progressStreamController.add(value);
    });
  }

  /// Fetch cards list by moduleId and applied filter
  _fetchAndPushCards(String? moduleId, CardFilter appliedFilter, {bool silently = false, int delay = 0}) {
    if(kDebugMode) print("[ModuleInfoScreen] Loading cards using filter: \"$appliedFilter\"");

    // Push loading state to the cards stream to conditionally show loading indicator
    // The loading indicator is shown, when the fetch is not done silently (silently = false)
    // as per default
    cardStreamController.add(_CardListState(isLoading: !silently, cards: currentCardsState));

    // Create a delayed future to artificially slow the app down (this can reduce stuttering of
    // animations as the UI is not re-rendered that frequently)
    return Future<List<IndexCard>>.delayed(Duration(milliseconds: !silently ? 250 : delay), () {
      if(appliedFilter == CardFilter.filterAll) {
        // Based on the applied filter, fetch all cards (wrong and correct)
        return cardsManager.getAllCards(moduleId);
      } else if(appliedFilter == CardFilter.filterCorrect) {
        // Based on the applied filter, fetch only correctly answered cards
        return cardsManager.getCorrectCards(moduleId);
      } else if(appliedFilter == CardFilter.filterWrong) {
        // Based on the applied filter, fetch only wrongly answered cards
        return cardsManager.getWrongCards(moduleId);
      } else {
        // If the selected filter is not valid or unknown, return empty list
        return [];
      }
    }).then((cards) {
      // Save current state
      currentCardsState = cards;
      // Push to stream on success
      cardStreamController.add(_CardListState(isLoading: false, cards: cards));
    });
  }

  /// Open editor to edit the current module
  _openModuleEditor(Module? module) {
    // Call native showDialog() provided by flutter
    showDialog(
      context: context,
      // Use the custom CardEditorDialog widget
      builder: (ctx) => ModuleEditorDialog(
        // Provide module data to set editor into edit-mode
        module: module,
        // Callback event when the module state has changed (this happens
        // when a new module was created or an existing one was updated)
        onDidChange: (module) {
          // Notify module list page that the module data has changed
          Notifier.notify(NotifierName.notifierModuleList);
          // Push updated module data to stream
          moduleStreamController.add(module);
        },
      ),
    );
  }

  /// Open editor to edit or create a new index card
  _openCardEditor(String moduleId, [IndexCard? indexCard]) {
    // Call native showDialog() provided by flutter
    showDialog(
      context: context,
      // Use the custom CardEditorDialog widget
      builder: (ctx) => CardEditorDialog(
        // Provide module's id
        moduleId: moduleId,
        // Provide card data, especially if the editor should be put into
        // edit-mode (when card already exists and needs to be edited)
        indexCard: indexCard,
        // Callback event when the card state has changed (this happens
        // when a new card was created or an existing one was updated)
        onDidChange: (card) {
          // Notify module list page that the module data has changed (cards count adjusted)
          Notifier.notify(NotifierName.notifierModuleList);

          // If changes occured, reload module and cards list
          _fetchAndPushModule(_currentModuleId);
          _fetchAndPushCards(_currentModuleId, currentFilter, silently: true);
        },
      ),
    );
  }

  /// Remove a card from storage
  _removeCard(IndexCard card) {
    // Call storageManager to delete the selected card
    storageManager.deleteOneCard(_currentModuleId, card.id).then((deleted) {
      // Check if card deletion was successful
      if(!deleted) {
        Snackbars.message("Karte konnte nicht gelöscht werden", context);
        return;
      }

      // Notify module list page that the module data has changed (cards count adjusted)
      Notifier.notify(NotifierName.notifierModuleList);

      // If it was successful, reload module and card list and show
      // a snackbar notifying the user
      Snackbars.message("Karte gelöscht", context);
      _fetchAndPushModule(_currentModuleId);
      _fetchAndPushCards(_currentModuleId, currentFilter, silently: true);
    }).onError((error, stackTrace){
      // Handle deletion errors
      Snackbars.error("Ein Fehler ist aufgetreten", context);
      if(kDebugMode) print(error);
    });
  }

  /// Reset selected list filters
  _resetFilter() {
    // Push the default filter to the filter stream to update UI
    filterStreamController.add(CardFilter.filterAll);
  }

  /// Navigate back to the module list
  _navigateHome() {
    // Check if there is a page before the current page in the
    // navigation stack (user navigated here via parent page)
    if(context.canPop()) {
      // If the context can pop this page,
      // then do this to navigate back to previous page
      context.pop();
    } else {
      // Use goNamed() to not add the current page (module info) to the
      // routing history, so that the home page would be the new "first"
      // page in navigation stack
      context.goNamed(RouteName.routeHome.value);
    }
  }

  /// Start a new iteration
  _startIteration() {
    // To start a new iteration, navigate to iteration screen and
    // pass the module id to the route via parameters
    context.pushNamed(RouteName.routeIteration.value, params: { "moduleId": _currentModuleId! });
  }

  /// Open dialog to confirm export
  _openExportDialog(Module module) {
    showDialog(
        context: context,
        builder: (ctx) => ExportModuleDialog(moduleId: module.id,),
    );
  }

  /// Delete the module
  _deleteModule(Module module) {
    storageManager.deleteOneModule(module.id).then((value){
      _navigateHome();
      Snackbars.message("Modul gelöscht", context);
    }).onError((error, stackTrace){
      Snackbars.error("Ein Fehler ist aufgetreten", context);
    });
  }

  /// Open bottom sheet for module options like editing and exporting the module
  _showModuleBottomSheet(Module module) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.sectionMarginX, vertical: Constants.sectionMarginX),
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Bearbeiten"),
                  subtitle: const Text("Modulinformationen anpassen"),
                  onTap: () {
                    ctx.pop();
                    _openModuleEditor(module);
                  },
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Löschen"),
                  subtitle: const Text("Modul löschen"),
                  onTap: () {
                    ctx.pop();
                    _deleteModule(module);
                  },
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.ios_share),
                  title: const Text("Exportieren"),
                  subtitle: const Text("Modul zum Teilen exportieren"),
                  onTap: () {
                    ctx.pop();
                    _openExportDialog(module);
                  },
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder(
        stream: moduleStream,
        initialData: null,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }

          return snapshot.data == null ? _renderErrorScreen() : _renderInfoScreen(snapshot.data!);
        }
      ),
    );
  }

  Widget _renderInfoScreen(Module module) {
    return Scaffold(
      /// Render appbar with back button and module name as title
      appBar: AppBar(
        title: Text(module.name),
        centerTitle: true,
        elevation: 1,
        leading: BackButton(
          onPressed: () => _navigateHome(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _showModuleBottomSheet(module),
              icon: const Icon(Icons.more_vert)
            ),
          )
        ],
      ),
      /// Render floating action button to create new cards
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCardEditor(module.id),
        child: const Icon(Icons.add),
      ),
      /// Render body containing the contents of the page
      body: StreamBuilder<_CardListState>(
        stream: cardStream,
        builder: (context, snapshot) {
          var isLoading = snapshot.data?.isLoading ?? false || snapshot.connectionState == ConnectionState.waiting;
          var indexCards = snapshot.data?.cards ?? [];

          /// If the cards are still loading, show stats and filter together with a loading indicator
          if(isLoading) {
            return ListView(
              // This physics prevent the overscroll effect on mobile devices.
              // Normal behaviour: On mobile devices, the page scroll further and revealing empty space
              // Because of the card at the top of the page (as background) a bug would appear. This is
              // prevented using this physics
              physics: const ClampingScrollPhysics(),
              children: [
                _renderTopSection(module),
                const SizedBox(height: 96, child: Center(child: CircularProgressIndicator(),),)
              ],
            );
          }

          /// If done loading, render the actual content
          return ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: (indexCards.length) + 3,
              itemBuilder: (context, itemIndex) {
                if(itemIndex == 0) {
                  return _renderTopSection(module);
                }

                // Render error screen on empty list or padding underneath
                // filter section at index 2 of the listview
                if(itemIndex == 1) {
                  var actualListSize = indexCards.length;

                  // Handle empty cards list after fetching
                  if(actualListSize <= 0) {

                    // Check if the module actually has no cards, then no card exists
                    if(module.cards.isEmpty) {
                      return ErrorCard(
                        title: "Keine Karten gefunden",
                        message: "Sobald du eine Karteikarte angelegt hast, wird diese hier angezeigt.",
                        actions: [
                          TextButton.icon(
                            onPressed: () => _openCardEditor(module.id),
                            label: const Text("Erste Karteikarte erstellen"),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      );
                    }

                    // If the module has cards, but no cards were fetched, this could probably mean
                    // that nothing was found for the selected filter.
                    return ErrorCard(
                      title: "Keine Karten gefunden",
                      message: "Für den gewählten Filter konnten keine Elemente gefunden werden",
                      actions: [
                        TextButton.icon(
                          onPressed: () => _resetFilter(),
                          label: const Text("Filter zurücksetzen"),
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    );
                  }

                  // Otherwise render padding to make space between filter and list items
                  return const SizedBox(height: Constants.sectionMarginY,);
                }

                // Render list elements. For that we have to convert the index
                // of the scrollview to a valid index of the cards list.
                // Because we have always 3 elements rendered before the first index card, we have to subtract by 3
                var index = itemIndex - 2;
                // Prevent index overflow. Because we have to add a padding to the bottom of the page, we have to
                // left one index free
                if(index <= (indexCards.length - 1)) {
                  var indexCard = indexCards.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(left: Constants.sectionMarginX, right: Constants.sectionMarginX, bottom: Constants.listGap),
                    child: Dismissible(
                      key: Key(indexCard.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _removeCard(indexCard),
                      background: const DismissToDeleteBackground(),
                      child: IndexCardItemCard(
                        indexCard: indexCard,
                        onEditPressed: (card) => _openCardEditor(_currentModuleId!, card),
                        onDeletePressed: (card) => _removeCard(card),
                      ),
                    ),
                  );
                }

                // Add padding to the bottom of the list to avoid FAB to cover cards
                return const SizedBox(height: Constants.bottomPaddingFab,);
              }
          );
        },
      ),
    );
  }

  /// Render function returning the error screen when fetching module failed
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

  /// Render function returning the statistics section
  _renderStartButton() {
    return Row(
        children: [
          Expanded(child: SizedBox(
            height: 44,
            child: FilledButton.tonalIcon(
              onPressed: () => _startIteration(),
              label: const Text("Durchlauf starten"),
              icon: const Icon(Icons.school),
            ),
          )),
          const SizedBox(width: Constants.listGap,),
          // Render button for selecting a mode
          // This is currently a planned feature and not implemented
          // in production, so it is only shown when app is in debug mode
          !kDebugMode ? Container() : SizedBox(
            height: 44,
            width: 44,
            child: FilledButton.tonal(
              onPressed: () => _startIteration(),
              style: FilledButton.styleFrom(
                // Set 0 padding, to have a icon button with tonal colour
                padding: EdgeInsets.zero
              ),
              child: const Icon(Icons.arrow_drop_down),
            ),
          )
        ],
    );
  }

  /// Render function returning the statistics section
  _renderStatsSection(Module module) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.sectionMarginY),
      /// Show custom widget for stats
      child: ModuleStatisticsSection(module: module, progress: progressStream,),
    );
  }

  /// Render function returning the filter section
  _renderFilterSection() {
    return StreamBuilder<CardFilter>(
      stream: filterStream,
      builder: (ctx, snapshot) {
        return ModuleListFilterSection(
          onFilterSelected: (name) => filterStreamController.add(name),
          selectedFilter: snapshot.data ?? CardFilter.filterAll,
        );
      }
    );
  }

  /// Render top section of the info page that contains stats
  _renderTopSection(Module module) {
    return Column(
      children: [
        /// Card as background containing stats
        Card(
          elevation: 1,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            // Only show a border, if card type is not "filled"
              side: BorderSide(width: 0, color: Colors.transparent),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))
          ),
          /// Stats content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: Constants.sectionMarginX*1.5,
                  right: Constants.sectionMarginX*1.5,
                  top: 0,
                  bottom: Constants.sectionMarginY*2.5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Basic stats (e.g.: Iteration count and last correct percentage)
                    Padding(padding: const EdgeInsets.only(bottom: Constants.sectionMarginY), child: _renderStatsSection(module),),
                    /// Render the start new iteration buttons
                    _renderStartButton()
                  ],
                ),
              )
            ],
          ),
        ),
        /// Filter section
        Padding(
          padding: const EdgeInsets.only(
            left: Constants.sectionMarginX,
            right: Constants.sectionMarginX,
            top: Constants.sectionMarginY*3
          ),
          child: _renderFilterSection(),
        ),
      ],
    );
  }

}