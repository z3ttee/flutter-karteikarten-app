
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/screens/module-info/widgets/moduleFilterSection.dart';
import 'package:flutter_karteikarten_app/screens/module-info/widgets/moduleRevealSection.dart';
import 'package:flutter_karteikarten_app/screens/module-info/widgets/moduleStartButton.dart';
import 'package:flutter_karteikarten_app/screens/module-info/widgets/moduleStatsSection.dart';

import '../../../entities/Module.dart';

class ModuleInfoHeader extends StatefulWidget {
  final Module module;

  final Stream<CardFilter> selectedFilter;
  final Stream<bool> revealedAnswers;

  final Function(CardFilter)? onFilterChanged;
  final Function(bool)? onRevealChanged;
  final Function()? onIterationStart;

  const ModuleInfoHeader({
    super.key,
    this.onFilterChanged,
    this.onIterationStart,
    required this.module,
    required this.selectedFilter,
    required this.revealedAnswers,
    this.onRevealChanged
  });

  @override
  State<StatefulWidget> createState() {
    return _ModuleInfoHeaderState();
  }

}

class _ModuleInfoHeaderState extends State<ModuleInfoHeader> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Card as background containing stats
        Card(
          elevation: 1,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            // Only show a border, if card type is not "filled"
              side: BorderSide(width: 0, color: Colors.transparent),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))
          ),
          /// Stats content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: Constants.sectionMarginX*1.5,
                  right: Constants.sectionMarginX*1.5,
                  top: 0,
                  bottom: Constants.sectionMarginY*2.5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Module description
                    widget.module.description == null ? Container() : Padding(padding: const EdgeInsets.only(top: Constants.listGap), child: Text(widget.module.description!, style: Theme.of(context).textTheme.labelLarge,),),
                    /// Basic stats (e.g.: Iteration count and last correct percentage)
                    Padding(padding: const EdgeInsets.only(bottom: Constants.sectionMarginY), child: ModuleStatsSection(module: widget.module),),
                    /// Render the start new iteration buttons
                    ModuleStartButton(
                      onStartIteration: () => widget.onIterationStart?.call(),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        /// Filter section
        Padding(
          padding: const EdgeInsets.only(
              left: Constants.sectionMarginX,
              right: Constants.sectionMarginX,
              top: Constants.sectionMarginY*3
          ),
          child: ModuleFilterSection(
            selectedFilter: widget.selectedFilter,
            onFilterChanged: (filter) => widget.onFilterChanged?.call(filter),
          ),
        ),
        /// Switch section
        Padding(
          padding: const EdgeInsets.only(
              left: Constants.sectionMarginX,
              right: Constants.sectionMarginX,
              top: Constants.sectionMarginY
          ),
          child: ModuleCardRevealSection(
            isRevealed: widget.revealedAnswers,
            onRevealChanged: (revealed) => widget.onRevealChanged?.call(revealed),
          ),
        ),
      ],
    );
  }

}