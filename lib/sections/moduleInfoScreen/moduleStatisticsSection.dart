
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/utils/calc.dart';
import 'package:flutter_karteikarten_app/widgets/cards/statisticsCard.dart';
import 'package:flutter_karteikarten_app/widgets/progress-indicator/roundedProgressIndicator.dart';

class ModuleStatisticsSection extends StatefulWidget {
  final Module module;
  final Stream<double> progress;

  const ModuleStatisticsSection({
    super.key,
    required this.module,
    required this.progress
  });

  @override
  State<StatefulWidget> createState() {
    return _ModuleStatisticsSectionState();
  }

}

class _ModuleStatisticsSectionState extends State<ModuleStatisticsSection> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Render progress bar to indicate learning progress
          Row(
            children: [
              StreamBuilder(
                stream: widget.progress,
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
          /// Padding between contents
          const SizedBox(height: Constants.listGap,),
          /// Cards for stats
          Row(
            children: [
              // Expanded(child: StatCard(title: "Karten", value: "${widget.module.cards.length}")),
              // const SizedBox(width: Constants.listGap,),
              Expanded(child: StatCard(title: "Durchläufe", value: "${widget.module.iterations ?? 0}")),
              const SizedBox(width: Constants.listGap,),
              Expanded(child: StatCard(title: "Zuletzt richtig", value: "${Calc.calcModuleProgress(widget.module)}", unit: "%",)),
            ],
          )
        ],
      ),
    );
  }
}