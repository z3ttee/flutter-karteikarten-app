
import 'package:flutter/material.dart';
import '../../constants.dart';

class ModuleListFilterSection extends StatelessWidget {
  final ValueSetter<String> onFilterSelected;
  final String selectedFilter;

  const ModuleListFilterSection({
    super.key,
    required this.onFilterSelected,
    required this.selectedFilter
  });

  _setFilter(String name) {
    onFilterSelected(name);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(left: Constants.sectionMarginX+4, right: Constants.sectionMarginX+4, bottom: Constants.sectionContentGap), child: Text("Karteikarten", style: Theme.of(context).textTheme.titleLarge,),),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(width: Constants.sectionMarginX+4,),
                ChoiceChip(
                    label: const Text(Constants.filterAll),
                    selected: selectedFilter == Constants.filterAll,
                    onSelected: (selected) => _setFilter(Constants.filterAll)
                ),
                const SizedBox(width: Constants.listGap,),
                ChoiceChip(
                    label: const Text(Constants.filterCorrect),
                    selected: selectedFilter == Constants.filterCorrect,
                    onSelected: (selected) => _setFilter(Constants.filterCorrect)
                ),
                const SizedBox(width: Constants.listGap,),
                ChoiceChip(
                    label: const Text(Constants.filterWrong),
                    selected: selectedFilter == Constants.filterWrong,
                    onSelected: (selected) => _setFilter(Constants.filterWrong)
                ),
                const SizedBox(width: Constants.sectionMarginX+4,),
              ],
            ),
          )
        ],
      ),
    );
  }

}