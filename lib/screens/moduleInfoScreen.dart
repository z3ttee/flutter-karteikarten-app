
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
import 'package:flutter_karteikarten_app/routes.dart';
import 'package:flutter_karteikarten_app/sections/moduleInfoScreen/moduleListFilterSection.dart';
import 'package:flutter_karteikarten_app/sections/moduleInfoScreen/moduleStatisticsSection.dart';
import 'package:flutter_karteikarten_app/widgets/cards/errorCard.dart';
import 'package:flutter_karteikarten_app/widgets/cards/indexCardItemCard.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import '../entities/Module.dart';

class ModuleInfoData {
  final Module? module;
  final List<IndexCard> indexCards;

  ModuleInfoData(this.module, this.indexCards);
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
  late final StreamController<List<IndexCard>> cardStreamController;
  late final StreamController<String> filterStreamController;

  late final Stream<Module?> moduleStream;
  late final Stream<List<IndexCard>> cardStream;
  late final Stream<String> filterStream;

  late final StreamSubscription<String> filterSubscription;

  late final String? _moduleId;
  final StorageManager storageManager = StorageManager();
  final CardsManager cardsManager = CardsManager();

  @override
  void initState() {
    super.initState();

    // Extract module id from route
    _moduleId = widget.activatedRoute.params["moduleId"];

    // Initialize stream controllers for updating data
    moduleStreamController = BehaviorSubject();
    cardStreamController = BehaviorSubject();
    filterStreamController = BehaviorSubject();

    // Initialize stream to listen to data changes
    moduleStream = moduleStreamController.stream;
    cardStream = cardStreamController.stream;
    filterStream = filterStreamController.stream;

    // Fetch module and push result to stream
    _fetchAndPushModule(_moduleId);

    // Fetch cards and push result to stream
    _fetchAndPushCards(_moduleId, Constants.filterAll);

    // Subscribe to changes to the filter value and re-fetch cards
    filterSubscription = filterStream.listen((filterName) {
      _fetchAndPushCards(_moduleId, filterName);
    });
  }

  _fetchAndPushModule(String? moduleId) {
    if (kDebugMode) print("[ModuleInfoScreen] Loading module info page for moduleId '$moduleId'");

    return Future<Module?>.delayed(const Duration(milliseconds: 150), () => storageManager.readOneModule(moduleId)).then((value) {
      moduleStreamController.add(value);
    });
  }

  _fetchAndPushCards(String? moduleId, String appliedFilter) {
    if(kDebugMode) print("[ModuleInfoScreen] Loading cards using filter: \"$appliedFilter\"");

    return Future<List<IndexCard>>.delayed(const Duration(milliseconds: 250), () {
      if(appliedFilter == Constants.filterAll) {
        return cardsManager.getAllCards(moduleId);
      } else if(appliedFilter == Constants.filterCorrect) {
        return cardsManager.getCorrectCards(moduleId);
      } else if(appliedFilter == Constants.filterWrong) {
        return cardsManager.getWrongCards(moduleId);
      } else {
        return [];
      }
    }).then((value) {
      // Push to stream on success
      cardStreamController.add(value);
    });
  }

  _openModuleEditor(Module? module) {
    showDialog(
      context: context,
      builder: (ctx) => ModuleEditorDialog(
        module: module,
        onDidChange: (module) {
          Notifier.notify(Constants.notifierModuleList);
          moduleStreamController.add(module);
        },
      ),
    );
  }

  _openCardEditor(String moduleId, [IndexCard? indexCard]) {
    showDialog(
      context: context,
      builder: (ctx) => CardEditorDialog(
        moduleId: moduleId,
        indexCard: indexCard,
        onDidChange: (card) {
          // TODO
        },
      ),
    );
  }

  _resetFilter() {
    filterStreamController.add(Constants.filterAll);
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
        leading: BackButton(
          onPressed: () => _navigateHome(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _openModuleEditor(module),
              icon: const Icon(Icons.edit)
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
      body: StreamBuilder<List<IndexCard>>(
        stream: cardStream,
        builder: (context, snapshot) {
          var indexCards = snapshot.data ?? [];

          /// If the cards are still loading, show stats and filter together with a loading indicator
          if(snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              children: [
                _renderStatsSection(module),
                _renderFilterSection(),
                const SizedBox(height: 96, child: Center(child: CircularProgressIndicator(),),)
              ],
            );
          }

          /// If done loading, render the actual content
          return ListView.builder(
              itemCount: (indexCards.length) + 4,
              itemBuilder: (context, itemIndex) {
                // Render statistics at index 0 of the listview
                if(itemIndex == 0) return _renderStatsSection(module);
                // Render filter section at index 1 of the listview
                if(itemIndex == 1) return _renderFilterSection();

                // Render error screen on empty list or padding underneath
                // filter section at index 2 of the listview
                if(itemIndex == 2) {
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
                var index = itemIndex - 3;
                // Prevent index overflow. Because we have to add a padding to the bottom of the page, we have to
                // left one index free
                if(index <= (indexCards.length - 1)) {
                  var indexCard = indexCards.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(left: Constants.sectionMarginX, right: Constants.sectionMarginX, bottom: Constants.listGap),
                    child: IndexCardItemCard(
                      indexCard: indexCard,
                      /*onChanged: (card) {
                        // Update card on module internally without saving to disc (already done in internal dialog)
                        module.cards[card.id] = card;
                      },*/
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
  _renderStatsSection(Module module) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.sectionMarginY),
      child: ModuleStatisticsSection(module: module,),
    );
  }

  /// Render function returning the filter section
  _renderFilterSection() {
    return StreamBuilder<String>(
      stream: filterStream,
      builder: (ctx, snapshot) {
        return ModuleListFilterSection(
          onFilterSelected: (name) => filterStreamController.add(name),
          selectedFilter: snapshot.data ?? Constants.filterAll,
        );
      }
    );
  }

}