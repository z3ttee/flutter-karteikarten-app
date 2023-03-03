
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../../constants.dart';
import '../../../entities/Module.dart';
import '../../../utils/calc.dart';
import '../../../widgets/cards/statisticsCard.dart';
import '../../../widgets/progress-indicator/roundedProgressIndicator.dart';

class ModuleStatsSection extends StatefulWidget {
  final Module module;

  const ModuleStatsSection({
    super.key,
    required this.module
  });

  @override
  State<StatefulWidget> createState() {
    return _ModuleStatsSectionState();
  }

}

class _ModuleStatsSectionState extends State<ModuleStatsSection> {

  late final StreamController<double> streamController;
  late final Stream<double> stream;

  double currentVal = -1;

  @override
  void didUpdateWidget(covariant ModuleStatsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    Calc.calcModuleLearningProgress(widget.module).then((value){
      _setProgress(value);
    });
  }

  _setProgress(double val) {
    if(currentVal == val) return;
    streamController.add(val);
    currentVal = val;
  }

  @override
  void initState() {
    super.initState();

    streamController = BehaviorSubject();
    stream = streamController.stream;

    Calc.calcModuleLearningProgress(widget.module).then((value){
      _setProgress(value);
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (ctx, snapshot) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Render progress bar to indicate learning progress
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: snapshot.data != null && snapshot.data! >= 1 ? "Du hast alles richtig beantwortet!" : "Dein Lernfortschritt:",
                        backgroundColor: Colors.transparent,
                        disablePaddingX: true,
                        customChild: RoundedProgressIndicator(progress: snapshot.data,),
                      ),
                    ),
                  ],
                ),
                /// Padding between contents
                const SizedBox(height: Constants.listGap,),
                /// Cards for stats
                Row(
                  children: [
                    Expanded(child: StatCard(title: "Durchläufe", value: "${widget.module.iterations}")),
                    const SizedBox(width: Constants.listGap,),
                    Expanded(child: StatCard(title: "Zuletzt richtig", value: "${Calc.calcModuleProgress(widget.module)}", unit: "%",)),
                  ],
                )
              ],
            ),
          );
        }
    );
  }

}