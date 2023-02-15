
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/CardsManager.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/routes.dart';
import 'package:flutter_karteikarten_app/sections/moduleInfoScreen/moduleListFilterSection.dart';
import 'package:flutter_karteikarten_app/sections/moduleInfoScreen/moduleStatisticsSection.dart';
import 'package:flutter_karteikarten_app/utils/snackbars.dart';
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
  Future<ModuleInfoData?>? _data;

  String _activeFilter = Constants.filterAllName;
  CardsManager cardsManager = CardsManager();



  _openModuleEditor() {

  }

  _openCardEditor([IndexCard? indexCard]) {

  }

  _setFilter(String name) {
    setState(() {
      _activeFilter = name;
    });
  }

  _fetchData() {
    if(kDebugMode) print("[ModuleInfoScreen] Loading module and cards");

    return Future.delayed(const Duration(milliseconds: 300), () async {
      var moduleId = widget.activatedRoute.params["moduleId"];
      var module = await _fetchModule(moduleId);
      var cards = await _fetchCards(moduleId);
      var data = ModuleInfoData(module, cards);

      return data;
    }).onError((error, stackTrace) {
      Snackbars.message("Ein unerwarteter Fehler ist aufgetreten.", context);
      return ModuleInfoData(null, []);
    });
  }

  Future<List<IndexCard>> _fetchCards(String? moduleId) {
    if(kDebugMode) print("[ModuleInfoScreen] Loading cards using filter: \"$_activeFilter\"");

    return Future.delayed(const Duration(milliseconds: 1), () {
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
    if (kDebugMode) print("[ModuleInfoScreen] Loading module info page for moduleId '$moduleId'");

    StorageManager manager = StorageManager();
    return manager.readOneModule(moduleId);
  }


  @override
  void initState() {
    super.initState();

    _data = _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder<ModuleInfoData?>(
        future: _data,
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(),);
          }

          print("Rebuilt UI");
          return snapshot.data == null || snapshot.data?.module == null ? _renderErrorScreen() : _renderInfoScreen(snapshot.data!);
        }
      ),
    );
  }

  Widget _renderInfoScreen(ModuleInfoData data) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data.module!.name),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCardEditor(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
            itemCount: (data.indexCards.length) + 4,
            itemBuilder: (context, itemIndex) {
              if(itemIndex == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: Constants.sectionMarginY),
                  child: ModuleStatisticsSection(module: data.module!,),
                );
              }

              if(itemIndex == 1) {
                return ModuleListFilterSection(
                  onFilterSelected: (name) => _setFilter(name),
                  selectedFilter: _activeFilter,
                );
              }

              if(itemIndex == 2) {
                var actualListSize = data.indexCards.length;
                if(data.module == null || actualListSize <= 0) {
                  return ErrorCard(
                    title: "Keine Karten gefunden",
                    message: "Sobald du eine Karteikarte angelegt hast, wird diese hier angezeigt.",
                    actions: [
                      TextButton.icon(
                        onPressed: () => _openCardEditor(),
                        label: const Text("Erste Karteikarte erstellen"),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  );
                }

                return const SizedBox(height: Constants.sectionMarginY,);
              }

              var index = itemIndex - 3;

              if(index <= (data.indexCards.length - 1)) {
                var indexCard = data.indexCards.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(left: Constants.sectionMarginX, right: Constants.sectionMarginX, bottom: Constants.listGap),
                  child: IndexCardItemCard(
                    indexCard: indexCard,
                    onEditPressed: (indexCard) => _openCardEditor(indexCard),
                  ),
                );
              }

              return const SizedBox(height: Constants.bottomPaddingFab,);
            }
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