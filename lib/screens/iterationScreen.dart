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
import 'package:flutter_karteikarten_app/widgets/buttons/labeledButton.dart';
import 'package:flutter_karteikarten_app/widgets/cards/errorCard.dart';
import 'package:flutter_karteikarten_app/widgets/cards/statisticsCard.dart';
import 'package:flutter_karteikarten_app/widgets/progress-indicator/roundedProgressIndicator.dart';
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

  late final StreamController<Iteration> iterationStreamController;
  late final StreamController<IndexCard> currentCardStreamController;
  late final StreamController<bool> revealAnswerStreamController;
  late final StreamController<double> progressStreamController;

  late final Stream<Iteration> iterationStream;
  late final Stream<IndexCard> currentCardStream;
  late final Stream<bool> revealAnswerStream;
  late final Stream<double> progressStream;

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
    iterationStreamController = BehaviorSubject();
    currentCardStreamController = BehaviorSubject();
    revealAnswerStreamController = BehaviorSubject();
    progressStreamController = BehaviorSubject();

    // Initialize stream to listen to data changes
    iterationStream = iterationStreamController.stream;
    currentCardStream = currentCardStreamController.stream;
    revealAnswerStream = revealAnswerStreamController.stream;
    progressStream = progressStreamController.stream;

    // Fetch module and push result to stream
    _fetchAndPushModule(_moduleId);

    // Subscribe to changes to the current card value
    cardSubscription = currentCardStream.listen((card) {
      currentCard = card;
    });
  }

  _fetchAndPushModule(String? moduleId) {
    if (kDebugMode) print("[ModuleInfoScreen] Loading module info page for moduleId '$moduleId'");

    return Future<Module?>.delayed(const Duration(milliseconds: 150), () => storageManager.readOneModule(moduleId)).then((value) {
      if(value == null) {
        Snackbars.message("Module konnt nicht geladen werden", context);
        return;
      }
      _fetchAndPushIteration(value, CardFilter.filterAll);
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
        _recalcProgressAndPush();
        return iteration;
      });
    });
  }

  _navigateToModule([bool mustConfirm = false]) {
    if(!mustConfirm) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Durchlauf beenden?"),
        content: const Text("Wenn du den Durchlauf frühzeitig beendest werden deine bisherigen Ergebnisse nicht gespeichert. Möchtest du trotzdem fortfahren?"),
        actions: [
          TextButton(
              onPressed: () => context.pop(),
              child: const Text("Nicht abbrechen")
          ),
          FilledButton.tonal(
            onPressed: () {
              // Pop two times, because first one just closes dialog
              context.pop();
              context.pop();
            },
            child: const Text("Durchlauf beenden")
          ),
        ],
      )
    );

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
    currentIteration.setCardAnswerState(CardAnswer.wrong);
    currentIteration.setCardState(false);
    _nextCard();
  }

  _markNeutral() {
    currentIteration.setCardAnswerState(CardAnswer.neutral);
    currentIteration.setCardState(false);
    _nextCard();
  }

  _markCorrect() {
    currentIteration.setCardAnswerState(CardAnswer.correct);
    currentIteration.setCardState(true);
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
      _recalcProgressAndPush();
    });
  }

  _recalcProgressAndPush() {
    var current = currentIteration.currentCardCount;
    var total = currentIteration.totalCardCount <= 0 ? 1 : currentIteration.totalCardCount;
    var result = current / total;
    progressStreamController.add(result);
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
                Text("${currentIteration.correctAnswers} von ${currentIteration.totalCardCount}"),
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
    iterationStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed iteration stream.");
    });
    currentCardStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed card stream.");
    });
    revealAnswerStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed revealAnswer stream.");
    });
    progressStreamController.close().then((value) {
      if(kDebugMode) print("[ModuleInfoScreen] Closed revealAnswer stream.");
    });

    // Close subscriptions
    cardSubscription.cancel();

    // Notify info screen that data has changed
    Notifier.notify(NotifierName.notifierModuleInfo);
    Notifier.notify(NotifierName.notifierModuleList);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder(
        stream: iterationStream,
        initialData: null,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }

          return snapshot.data == null ? _renderErrorScreen() : _renderIterationScreen(snapshot.data!);
        }
      ),
    );
  }

  Widget _renderIterationScreen(Iteration iteration) {
    var module = iteration.module;
    return Scaffold(

      /// Render body containing the contents of the page
      body: Column(
        children: [
          /// Render appbar with back button and module name as title
          AppBar(
            elevation: 1,
            title: Text(module.name),
            centerTitle: true,
            leading: IconButton(
                onPressed: () => _navigateToModule(true),
                icon: const Icon(Icons.close)
            ),
          ),
          /// Render current card section
          StreamBuilder<bool>(
            stream: revealAnswerStream,
            builder: (ctx, snapshot) {
              var answerRevealed = snapshot.data ?? false;

              return StreamBuilder<IndexCard>(
                stream: currentCardStream,
                builder: (ctx, snapshot) {
                  if(!snapshot.hasData) {
                    return Column(
                      children: [
                        _renderTopSection(iteration),
                        const Center(child: CircularProgressIndicator(),)
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _renderTopSection(iteration),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(Constants.sectionMarginX),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /// Card
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
                              /// Reveal answer button row
                              answerRevealed ? Container() : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Constants.sectionMarginX, vertical: Constants.listGap),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextButton(
                                        onPressed: () => _showAnswer(),
                                        child: const Text("Antwort aufdecken")
                                    ),
                                  ],
                                ),
                              ),
                              /// Buttons row
                              !answerRevealed ? Container() : Padding(
                                padding: const EdgeInsets.symmetric(vertical: Constants.listGap),
                                child: SizedBox(
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: LabeledButton(
                                              onPressed: () => _markWrong(),
                                              text: "Falsch",
                                              icon: Icons.sentiment_dissatisfied_outlined
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: LabeledButton(
                                              onPressed: () => _markNeutral(),
                                              text: "Neutral",
                                              icon: Icons.sentiment_neutral_outlined
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: LabeledButton(
                                              onPressed: () => _markCorrect(),
                                              text: "Richtig",
                                              icon: Icons.sentiment_very_satisfied_outlined
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
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

  /// Render card containing the progress bar
  Widget _renderTopSection(Iteration iteration) {
    return Card(
      elevation: 1,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        // Only show a border, if card type is not "filled"
          side: BorderSide(width: 0, color: Colors.transparent),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: Constants.sectionMarginX,
          right: Constants.sectionMarginX,
          top: 0,
          bottom: Constants.sectionMarginY*2,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    backgroundColor: Colors.transparent,
                    title: (iteration.totalCardCount-iteration.currentCardCount) > 0 ? "Noch ${iteration.totalCardCount-iteration.currentCardCount} Karten" : "Das ist deine letzte Karte!",
                    customChild: StreamBuilder<double>(
                      stream: progressStream,
                      builder: (ctx, snapshot) {
                        if(snapshot.connectionState != ConnectionState.active) {
                          return const RoundedProgressIndicator();
                        }

                        // return const RoundedProgressIndicator();
                        return RoundedProgressIndicator(progress: snapshot.data ?? 0,);
                      },
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

}