
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/utils/calc.dart';
import 'package:flutter_karteikarten_app/widgets/cards/statisticsCard.dart';

class ModuleStatisticsSection extends StatelessWidget {
  final Module module;

  const ModuleStatisticsSection({
    super.key,
    required this.module
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Constants.sectionMarginX),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(bottom: Constants.sectionContentGap), child: Text("Statistiken", style: Theme.of(context).textTheme.titleLarge,),),
          Row(
            children: [
              Expanded(child: StatCard(title: "Karten", value: "${module.cards.length}")),
              const SizedBox(width: Constants.listGap,),
              Expanded(child: StatCard(title: "Durchläufe", value: "${module.iterations}")),
              const SizedBox(width: Constants.listGap,),
              Expanded(child: StatCard(title: "Fortschritt", value: "${Calc.calcModuleProgress(module)}", unit: "%",)),
            ],
          )
        ],
      ),
    );
  }

}