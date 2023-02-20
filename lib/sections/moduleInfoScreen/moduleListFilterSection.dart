
import 'package:flutter/material.dart';
import '../../constants.dart';

class ModuleListFilterSection extends StatelessWidget {
  final ValueSetter<CardFilter> onFilterSelected;
  final CardFilter selectedFilter;

  const ModuleListFilterSection({
    super.key,
    required this.onFilterSelected,
    required this.selectedFilter
  });

  _setFilter(CardFilter filter) {
    onFilterSelected(filter);
  }

  @override
  Widget build(BuildContext context) {
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

}