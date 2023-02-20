
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/utils/calc.dart';
import 'package:flutter_karteikarten_app/widgets/cards/statisticsCard.dart';
import 'package:flutter_karteikarten_app/widgets/progress-indicator/roundedProgressIndicator.dart';
import 'package:rxdart/rxdart.dart';

class ModuleStatisticsSection extends StatefulWidget {
  final Module module;

  const ModuleStatisticsSection({
    super.key,
    required this.module
  });

  @override
  State<StatefulWidget> createState() {
    return _ModuleStatisticsSectionState();
  }

}

class _ModuleStatisticsSectionState extends State<ModuleStatisticsSection> {

  late final StreamController<double> progressStreamController;
  late final Stream<double> progressStream;

  @override
  void initState() {
    super.initState();

    progressStreamController = BehaviorSubject();
    progressStream = progressStreamController.stream;

    Calc.calcModuleLearningProgress(widget.module).then((value){
      progressStreamController.add(value);
    });
  }

  @override
  void dispose() {
    super.dispose();

    progressStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StreamBuilder(
                stream: progressStream,
                builder: (ctx, snapshot) {
                  return Expanded(
                    child: StatCard(
                      title: snapshot.data != null && snapshot.data! >= 1 ? "Du hast alles richtig beantwortet!" : "Dein Lernfortschritt:",
                      backgroundColor: Colors.transparent,
                      disablePaddingX: true,
                      customChild: RoundedProgressIndicator(progress: snapshot.data,),
                    ),
                  );
                }
              ),
            ],
          ),
          const SizedBox(height: Constants.listGap,),
          Row(
            children: [
              // Expanded(child: StatCard(title: "Karten", value: "${widget.module.cards.length}")),
              // const SizedBox(width: Constants.listGap,),
              Expanded(child: StatCard(title: "Durchläufe", value: "${widget.module.iterations}")),
              const SizedBox(width: Constants.listGap,),
              Expanded(child: StatCard(title: "Zuletzt richtig", value: "${Calc.calcModuleProgress(widget.module)}", unit: "%",)),
            ],
          )
        ],
      ),
    );
  }
}