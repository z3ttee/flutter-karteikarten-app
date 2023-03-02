
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';

class ImportModuleDialog extends StatefulWidget {
  final Function(String?)? onDismissed;

  const ImportModuleDialog({
    super.key,
    this.onDismissed
  });

  @override
  State<StatefulWidget> createState() {
    return _ImportModuleDialogState();
  }

}

class _ImportModuleDialogState extends State<ImportModuleDialog> {

  late final GlobalKey<FormState> formKey;
  late final TextEditingController importInputController;

  _dismiss(String? value) {
    if(!context.canPop()) return;
    context.pop();
    widget.onDismissed?.call(value);
  }

  _validateAndDismiss() {
    if(formKey.currentState?.validate() ?? false) {
      // Form inputs are valid
      _dismiss(importInputController.value.text);
    }
  }

  /// Validate json input. Return string on error, otherwise null is to be returned
  String? _validateJson(String? value) {
    if(value == null || value.isEmpty) return "Dieses Feld wird benötigt.";
    return null;
  }

  @override
  void initState() {
    super.initState();

    formKey = GlobalKey();
    importInputController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Importieren"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Hier kannst du die Daten einfügen, die aus zuvor exportiert wurden."),
          const SizedBox(height: Constants.listGap,),
          Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Input field for inputting json string
                TextFormField(
                  controller: importInputController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Datensatz zum Importieren *',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) => _validateJson(value),
                ),
              ],
            ),
          )
        ],
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text("Abbrechen")),
        FilledButton.tonal(
            onPressed: () => _validateAndDismiss(),
            child: const Text("Importieren")
        ),
      ],
    );
  }

}