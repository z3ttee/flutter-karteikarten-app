
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/dialogs/cardEditorDialog.dart';
import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/CardsManager.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/routes.dart';
import 'package:flutter_karteikarten_app/sections/moduleInfoScreen/moduleListFilterSection.dart';
import 'package:flutter_karteikarten_app/sections/moduleInfoScreen/moduleStatisticsSection.dart';
import 'package:flutter_karteikarten_app/widgets/cards/errorCard.dart';
import 'package:flutter_karteikarten_app/widgets/cards/indexCardItemCard.dart';
import 'package:go_router/go_router.dart';
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

  String? _moduleId;
  late Future<Module?> _module;

  String _activeFilter = Constants.filterAllName;
  CardsManager cardsManager = CardsManager();

  _openModuleEditor() {

  }

  _openCardEditor(String moduleId, [IndexCard? indexCard]) {
    showDialog(
      context: context,
      builder: (ctx) => CardEditorDialog(
        moduleId: moduleId,
        indexCard: indexCard,
      ),
    );
  }

  _setFilter(String name) {
    setState(() {
      _activeFilter = name;
    });
  }

  _resetFilter() {
    _setFilter(Constants.filterAllName);
  }

  Future<List<IndexCard>> _fetchCards(String? moduleId) {
    if(kDebugMode) print("[ModuleInfoScreen] Loading cards using filter: \"$_activeFilter\"");

    return Future.delayed(const Duration(milliseconds: 250), () {
      if(_activeFilter == Constants.filterAllName) {
        return cardsManager.getAllCards(moduleId);
      } else if(_activeFilter == Constants.filterCorrectName) {
        return cardsManager.getCorrectCards(moduleId);
      } else if(_activeFilter == Constants.filterWrongName) {
        return cardsManager.getWrongCards(moduleId);
      } else {
        return [];
      }
    });
  }

  Future<Module?> _fetchModule() {
    if (kDebugMode) print("[ModuleInfoScreen] Loading module info page for moduleId '$_moduleId'");

    StorageManager manager = StorageManager();
    return Future.delayed(const Duration(milliseconds: 150), () {
      return manager.readOneModule(_moduleId);
    });
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
  void initState() {
    super.initState();

    _moduleId = widget.activatedRoute.params["moduleId"];
    _module = _fetchModule();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder<Module?>(
        future: _module,
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
      // Render appbar with back button and module name as title
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
      // Render floating action button to create new cards
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCardEditor(module.id),
        child: const Icon(Icons.add),
      ),
      // Render body containing the contents of the page
      body: FutureBuilder(
        future: _fetchCards(module.id),
        builder: (context, snapshot) {
          var indexCards = snapshot.data ?? [];

          // If the cards are still loading, show stats and filter together with a loading indicator
          if(snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              children: [
                _renderStatsSection(module),
                _renderFilterSection(),
                const SizedBox(height: 96, child: Center(child: CircularProgressIndicator(),),)
              ],
            );
          }

          // If done loading, render the actual content
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
                      onEditPressed: (indexCard) => _openCardEditor(module.id, indexCard),
                    ),
                  );
                }

                // Add padding to the bottom of the list to avoid FAB to cover cards
                return const SizedBox(height: Constants.bottomPaddingFab,);
              }
          );
        }
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
    return ModuleListFilterSection(
      onFilterSelected: (name) => _setFilter(name),
      selectedFilter: _activeFilter,
    );
  }

}