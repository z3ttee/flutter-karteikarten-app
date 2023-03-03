
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class ModuleCardRevealSection extends StatefulWidget {
  final Stream<bool> isRevealed;
  final Function(bool)? onRevealChanged;

  const ModuleCardRevealSection({
    super.key,
    this.onRevealChanged,
    required this.isRevealed
  });

  @override
  State<StatefulWidget> createState() {
    return _ModuleCardRevealSectionState();
  }

}

class _ModuleCardRevealSectionState extends State<ModuleCardRevealSection> {

  /// Switch icon based on state
  final MaterialStateProperty<Icon?> thumbIcon = MaterialStateProperty.resolveWith<Icon?>((Set<MaterialState> states) {
    // Thumb icon when the switch is selected.
    if (states.contains(MaterialState.selected)) {
      return const Icon(Icons.visibility);
    }
    return const Icon(Icons.visibility_off);
  },);

  _setRevealed(bool revealed) {
    widget.onRevealChanged?.call(revealed);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: widget.isRevealed,
        builder: (ctx, snapshot) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Switch(
                value: snapshot.data ?? false,
                thumbIcon: thumbIcon,
                onChanged: (revealed) => _setRevealed(revealed),
              ),
              const SizedBox(width: Constants.listGap,),
              const Text("Antworten anzeigen")
            ],
          );
        }
    );
  }

}