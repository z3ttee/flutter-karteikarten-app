import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/CardsManager.dart';
import 'package:flutter_karteikarten_app/entities/Iteration.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/notifiers/dataNotifiers.dart';
import 'package:flutter_karteikarten_app/utils/snackbars.dart';
import 'package:flutter_karteikarten_app/widgets/cards/errorCard.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import '../entities/Module.dart';

class IterationScreen extends StatefulWidget {
  final GoRouterState activatedRoute;

  const IterationScreen({
    super.key,
    required this.activatedRoute
  });

  @override
  State<StatefulWidget> createState() {
    return _IterationScreenState();
  }

}

class _IterationScreenState extends State<IterationScreen> {

  late final StreamController<Module?> moduleStreamController;
  late final StreamController<Iteration> iterationStreamController;
  late final StreamController<IndexCard> currentCardStreamController;
  late final StreamController<bool> revealAnswerStreamController;

  late final Stream<Module?> moduleStream;
  late final Stream<Iteration> iterationStream;
  late final Stream<IndexCard> currentCardStream;
  late final Stream<bool> revealAnswerStream;

  late final StreamSubscription<Module?> moduleSubscription;
  late final StreamSubscription<IndexCard?> cardSubscription;

  late final String? _moduleId;
  final StorageManager storageManager = StorageManager();
  final CardsManager cardsManager = CardsManager();

  late Iteration currentIteration;
  late IndexCard currentCard;

  @override
  void initState() {
    super.initState();

    // Extract module id from route
    _moduleId = widget.activatedRoute.params["moduleId"];

    // Initialize stream controllers for updating data
    moduleStreamController = BehaviorSubject();
    iterationStreamController = BehaviorSubject();
    currentCardStreamController = BehaviorSubject();
    revealAnswerStreamController = BehaviorSubject();

    // Initialize stream to listen to data changes
    moduleStream = moduleStreamController.stream;
    iterationStream = iterationStreamController.stream;
    currentCardStream = currentCardStreamController.stream;
    revealAnswerStream = revealAnswerStreamController.stream;

    // Fetch module and push result to stream
    _fetchAndPushModule(_moduleId);

    // Subscribe to changes to the filter value and re-fetch cards
    moduleSubscription = moduleStream.listen((module) {
      if(module != null) {
        _fetchAndPushIteration(module, CardFilter.filterAll);
      }
    });

    // Subscribe to changes to the current card value
    cardSubscription = currentCardStream.listen((card) {
      currentCard = card;
    });
  }

  _fetchAndPushModule(String? moduleId) {
    if (kDebugMode) print("[ModuleInfoScreen] Loading module info page for moduleId '$moduleId'");

    return Future<Module?>.delayed(const Duration(milliseconds: 150), () => storageManager.readOneModule(moduleId)).then((value) {
      moduleStreamController.add(value);
    });
  }

  _fetchAndPushIteration(Module module, CardFilter appliedFilter) {
    if(kDebugMode) print("[ModuleInfoScreen] Loading iteration using filter: \"$appliedFilter\"");

    return Future<Iteration>.delayed(const Duration(milliseconds: 250), () {
      Iteration iteration = Iteration(module, appliedFilter);
      currentIteration = iteration;
      iterationStreamController.add(iteration);

      return iteration.getNext().then((value) {
        if(value == null) return iteration;
        currentCardStreamController.add(value);
        return iteration;
      });
    });
  }

  _navigateToModule() {
    context.pop();
  }

  _navigateHome() {
    if(context.canPop()) {
      // If the context can pop this page,
      // then do this to navigate back to previous page
      context.pop();
    } else {
      // Use goNamed() to not add this info route to the
      // routing history.
      context.goNamed(RouteName.routeHome.value);
    }
  }

  _markWrong() {
    currentIteration.setCardState(currentCard.id, false);
    _nextCard();
  }

  _markCorrect() {
    currentIteration.setCardState(currentCard.id, true);
    _nextCard();
  }

  _showAnswer() {
    revealAnswerStreamController.add(true);
  }

  _hideAnswer() {
    revealAnswerStreamController.add(false);
  }

  _nextCard() {
    currentIteration.getNext().then((value) {
      if(value == null) {
        return currentIteration.complete().then((value){
          _showSummary();
        }).onError((error, stackTrace){
          Snackbars.message("Ein Fehler ist aufgetreten", context);
          _navigateToModule();
        });
      }

      _hideAnswer();
      currentCardStreamController.add(value);
    });
  }

  _showSummary() {
    var dialog = showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Coooonnnngratulations!!!!"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Du hast den aktuellen Durchlauf abgeschlossen!"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Constants.listGap),
            child: Column(
              children: [
                const Text("Du hast "),
                Text("${currentIteration.correctAnswers} von ${currentIteration.correctAnswers + currentIteration.wrongAnswers}"),
                const Text("richtig beantwortet."),
              ],
            ),
          )
        ],
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              // Dismiss dialog
              Navigator.pop(context);
            },
            child: const Text("Beenden")
        )
      ],
    ));

    // Wait for the dialog to be dismissed
    dialog.then((value){
      _closeIteration();
    });
  }

  _closeIteration() {
    _navigateToModule();
  }

  @override
  void dispose() {
    super.dispose();
    // Close streams to free resources
    moduleStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed module stream.");
    });
    iterationStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed iteration stream.");
    });
    currentCardStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed card stream.");
    });
    revealAnswerStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed revealAnswer stream.");
    });

    // Close subscriptions
    moduleSubscription.cancel();
    cardSubscription.cancel();

    // Notify info screen that data has changed
    Notifier.notify(NotifierName.notifierModuleInfo);
    Notifier.notify(NotifierName.notifierModuleList);
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
          onPressed: () => _navigateToModule(),
        ),
      ),
      /// Render body containing the contents of the page
      body: StreamBuilder<bool>(
        stream: revealAnswerStream,
        builder: (ctx, snapshot) {
          var answerRevealed = snapshot.data ?? false;

          return StreamBuilder<IndexCard>(
            stream: currentCardStream,
            builder: (ctx, snapshot) {
              if(!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(),);
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(Constants.sectionMarginX),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 256,
                        child: Card(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(snapshot.data!.question),
                                !answerRevealed ? Container() : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: Constants.listGap),
                                  child: Text(snapshot.data!.answer),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Constants.sectionMarginX, vertical: Constants.listGap),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            !answerRevealed ? Container() : IconButton(
                                onPressed: () => _markWrong(),
                                icon: const Icon(Icons.close)
                            ),
                            answerRevealed ? Container() : TextButton(
                                onPressed: () => _showAnswer(),
                                child: const Text("Antwort aufdecken")
                            ),
                            !answerRevealed ? Container() : IconButton(
                                onPressed: () => _markCorrect(),
                                icon: const Icon(Icons.check)
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      )
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