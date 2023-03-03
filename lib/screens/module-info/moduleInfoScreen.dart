
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
import 'package:flutter_karteikarten_app/screens/module-info/widgets/moduleInfoHeader.dart';
import 'package:flutter_karteikarten_app/utils/calc.dart';
import 'package:flutter_karteikarten_app/utils/snackbars.dart';
import 'package:flutter_karteikarten_app/widgets/backgrounds/dismissToDeleteBackground.dart';
import 'package:flutter_karteikarten_app/widgets/cards/errorCard.dart';
import 'package:flutter_karteikarten_app/widgets/cards/indexCardItemCard.dart';
import 'package:flutter_karteikarten_app/widgets/sheets/moduleBottomSheet.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import '../../dialogs/exportDialog.dart';
import '../../entities/Module.dart';

class ModuleInfoData {
  final Module? module;
  final List<IndexCard> indexCards;

  ModuleInfoData(this.module, this.indexCards);
}

class CardListState {
  final bool isLoading;
  final List<IndexCard> cards;

  CardListState({
    required this.isLoading,
    required this.cards
  });
}

/// Class to store state about currently selected filter
/// and if answers should be revealed or not
class CardFilterState {
  final CardFilter selectedFilter;
  final bool answersRevealed;

  CardFilterState({
    required this.selectedFilter,
    required this.answersRevealed
  });
}

/// Stateful Widget for ModuleInfoScreen
class ModuleInfoScreen extends StatefulWidget {
  /// Current route
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

/// State for ModuleInfoScreen
class _ModuleInfoScreenState extends State<ModuleInfoScreen> {

  late final StreamController<Module?> moduleStreamController;
  late final StreamController<CardListState> cardStreamController;
  late final StreamController<CardFilter> filterStreamController;
  late final StreamController<bool> revealedStreamController = BehaviorSubject();

  late final Stream<Module?> moduleStream;
  late final Stream<CardListState> cardStream;
  late final Stream<CardFilter> filterStream;
  late final Stream<bool> revealedStream = revealedStreamController.stream;

  late final StreamSubscription<CardFilter> filterSubscription;

  late final String? _currentModuleId;
  final StorageManager storageManager = StorageManager();
  final CardsManager cardsManager = CardsManager();

  late CardFilter currentFilter;
  List<IndexCard> currentCardsState = [];

  @override
  void initState() {
    super.initState();

    // Set initial card filter state
    currentFilter = CardFilter.filterAll;

    // Extract module id from route
    _currentModuleId = widget.activatedRoute.params["moduleId"];

    // Initialize stream controllers for updating data
    moduleStreamController = BehaviorSubject();
    cardStreamController = BehaviorSubject();
    filterStreamController = BehaviorSubject();

    // Initialize stream to listen to data changes
    moduleStream = moduleStreamController.stream;
    cardStream = cardStreamController.stream;
    filterStream = filterStreamController.stream;

    // Fetch module and push result to stream
    _fetchAndPushModule(_currentModuleId);

    // Fetch cards and push result to stream
    _fetchAndPushCards(_currentModuleId, currentFilter);

    // Subscribe to changes to the filter value and re-fetch cards
    filterSubscription = filterStream.listen((filterState) {
      currentFilter = filterState;
      _fetchAndPushCards(_currentModuleId, filterState);
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
    revealedStreamController.close();

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
    });
  }

  /// Fetch cards list by moduleId and applied filter
  _fetchAndPushCards(String? moduleId, CardFilter appliedFilter, {bool silently = false, int delay = 0}) {
    if(kDebugMode) print("[ModuleInfoScreen] Loading cards using filter: \"$appliedFilter\"");

    // Push loading state to the cards stream to conditionally show loading indicator
    // The loading indicator is shown, when the fetch is not done silently (silently = false)
    // as per default
    cardStreamController.add(CardListState(isLoading: !silently, cards: currentCardsState));

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
      cardStreamController.add(CardListState(isLoading: false, cards: cards));
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

  /// Update selected list filters
  _setFilter(CardFilter filter) {
    filterStreamController.add(filter);
    _fetchAndPushCards(_currentModuleId, filter);
  }

  /// Toggle revealed answers
  _setAnswersRevealed(bool isRevealed) {
    revealedStreamController.add(isRevealed);
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
      builder: (ctx) => ModuleBottomSheet(
        module: module,
        onDelete: (module) => _deleteModule(module),
        onExport: (module) => _openExportDialog(module),
        onEdit: (module) => _openModuleEditor(module),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder(
        stream: moduleStream,
        initialData: null,
        builder: (context, snapshot) {
          /// When stream is not ready yet, show loading indicator
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }

          /// If there is data, show info screen, otherwise show error
          return snapshot.data == null ? _renderErrorScreen() : _renderInfoScreen(snapshot.data!);
        }
      ),
    );
  }

  /// Render the info screen
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
          /// More-Menu
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
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          /// Top section
          SliverToBoxAdapter(
            child: ModuleInfoHeader(
              module: module,
              selectedFilter: filterStream,
              revealedAnswers: revealedStream,
              onFilterChanged: (filter) => _setFilter(filter),
              onRevealChanged: (revealed) => _setAnswersRevealed(revealed),
              onIterationStart: () => _startIteration(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Constants.sectionMarginY,),),
          /// List content
          StreamBuilder(
            stream: cardStream,
            builder: (ctx, snapshot) {

              CardListState? listState = snapshot.data;
              bool isLoading = listState?.isLoading ?? false || snapshot.connectionState == ConnectionState.waiting;

              /// If the cards are still loading, show stats and filter together with a loading indicator
              if(isLoading) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator(),),
                );
              }

              /// Check if the module actually has no cards, then no card exists
              if(module.cards.isEmpty) {
                return SliverToBoxAdapter(
                  child: ErrorCard(
                    title: "Keine Karten gefunden",
                    message: "Sobald du eine Karteikarte angelegt hast, wird diese hier angezeigt.",
                    actions: [
                      TextButton.icon(
                        onPressed: () => _openCardEditor(module.id),
                        label: const Text("Erste Karteikarte erstellen"),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                );
              }

              /// If the module has cards, but no cards were fetched, this could probably mean
              /// that nothing was found for the selected filter.
              if(listState!.cards.isEmpty) {
                return SliverToBoxAdapter(
                  child: ErrorCard(
                    title: "Keine Karten gefunden",
                    message: "Für den gewählten Filter konnten keine Elemente gefunden werden",
                    actions: [
                      TextButton.icon(
                        onPressed: () => _setFilter(CardFilter.filterAll),
                        label: const Text("Filter zurücksetzen"),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                );
              }

              List<IndexCard> cards = snapshot.data?.cards ?? [];

              /// If done loading, render the actual list of cards
              return StreamBuilder(
                stream: revealedStream,
                builder: (ctx, snapshot) {
                  bool isRevealed = snapshot.data ?? false;

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      var indexCard = cards.elementAt(index);
                      /// Render card with dismissable content
                      return Padding(
                        padding: const EdgeInsets.only(left: Constants.sectionMarginX, right: Constants.sectionMarginX, bottom: Constants.listGap),
                        child: Dismissible(
                          key: Key(indexCard.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) => _removeCard(indexCard),
                          background: const DismissToDeleteBackground(),
                          child: IndexCardItemCard(
                            answerRevealed: isRevealed,
                            indexCard: indexCard,
                            onEditPressed: (card) => _openCardEditor(_currentModuleId!, card),
                            onDeletePressed: (card) => _removeCard(card),
                          ),
                        ),
                      );
                    },
                    childCount: cards.length),
                  );
                },
              );
            }
          ),
          /// Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: Constants.bottomPaddingFab,),),
        ],
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

}