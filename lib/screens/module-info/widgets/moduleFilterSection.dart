
import 'dart:async';

import 'package:flutter/material.dart';
import '../../../constants.dart';

class ModuleFilterSection extends StatefulWidget {
  final Stream<CardFilter> selectedFilter;
  final Function(CardFilter)? onFilterChanged;

  const ModuleFilterSection({
    super.key,
    this.onFilterChanged,
    required this.selectedFilter
  });

  @override
  State<StatefulWidget> createState() {
    return _ModuleFilterSectionState();
  }

}

class _ModuleFilterSectionState extends State<ModuleFilterSection> {

  _setFilter(CardFilter filter) {
    widget.onFilterChanged?.call(filter);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CardFilter>(
        stream: widget.selectedFilter,
        builder: (ctx, snapshot) {
          CardFilter selectedFilter = snapshot.data ?? CardFilter.filterAll;

          return SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: Constants.sectionContentGap),
                  child: Text("Karteikarten", style: Theme.of(context).textTheme.titleLarge,),
                ),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      ChoiceChip(
                          label: Text(CardFilter.filterAll.value),
                          selected: selectedFilter == CardFilter.filterAll,
                          onSelected: (selected) => _setFilter(CardFilter.filterAll)
                      ),
                      const SizedBox(width: Constants.listGap,),
                      ChoiceChip(
                          label: Text(CardFilter.filterCorrect.value),
                          selected: selectedFilter == CardFilter.filterCorrect,
                          onSelected: (selected) => _setFilter(CardFilter.filterCorrect)
                      ),
                      const SizedBox(width: Constants.listGap,),
                      ChoiceChip(
                          label: Text(CardFilter.filterWrong.value),
                          selected: selectedFilter == CardFilter.filterWrong,
                          onSelected: (selected) => _setFilter(CardFilter.filterWrong)
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }
    );
  }

}