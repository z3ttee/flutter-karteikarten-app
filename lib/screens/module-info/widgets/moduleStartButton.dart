
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class ModuleStartButton extends StatelessWidget {
  final Function? onStartIteration;
  final Function? onStartIterationMode;

  const ModuleStartButton({
    super.key,
    this.onStartIteration,
    this.onStartIterationMode
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SizedBox(
          height: 44,
          child: FilledButton.tonalIcon(
            onPressed: () => onStartIteration?.call(),
            label: const Text("Durchlauf starten"),
            icon: const Icon(Icons.school),
          ),
        )),
        const SizedBox(width: Constants.listGap,),
        // Render button for selecting a mode
        // This is currently a planned feature and not implemented
        // in production, so it is only shown when app is in debug mode
        !kDebugMode ? Container() : SizedBox(
          height: 44,
          width: 44,
          child: FilledButton.tonal(
            onPressed: () => onStartIterationMode?.call(),
            style: FilledButton.styleFrom(
              // Set 0 padding, to have a icon button with tonal colour
                padding: EdgeInsets.zero
            ),
            child: const Icon(Icons.arrow_drop_down),
          ),
        )
      ],
    );
  }

}