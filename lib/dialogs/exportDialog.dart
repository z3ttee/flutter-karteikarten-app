
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../utils/snackbars.dart';

class ExportModuleDialog extends StatefulWidget {
  final String? moduleId;

  const ExportModuleDialog({
    super.key,
    this.moduleId,
  });

  @override
  State<StatefulWidget> createState() {
    return _ExportModuleDialogState();
  }

}

class _ExportModuleDialogState extends State<ExportModuleDialog> {

  final StorageManager storageManager = StorageManager();

  _dismiss() {
    if(!context.canPop()) return;
    context.pop();
  }

  /// Export full module list into the users clipboard
  _exportAllModules() {
    _dismiss();

    Future<String> exportFuture;

    if(widget.moduleId == null) {
      exportFuture = storageManager.exportAll();
    } else {
      exportFuture = storageManager.exportModule(widget.moduleId!);
    }

    // Call storage manager to export all modules
    exportFuture.then((value){
      // On success, module list is retrieved as json string
      // This string is now copied to clipboard
      ClipboardData data = ClipboardData(text: value);
      Clipboard.setData(data).then((value) {
        // Show snackbar on success
        Snackbars.message("Exportierte Daten in Zwischenablage gespeichert", context);
      });
    }).onError((error, stackTrace){
      // Handle export errors
      Snackbars.message("Ein Fehler ist aufgetreten", context);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Exportieren"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.moduleId == null ? const Text("Möchtest du die gesamte Modulliste exportieren, um diese mit anderen zu teilen?") : const Text("Möchtest du dieses Modul exportieren? Darin enthalten sind alle angelegten Karten. Daten, bezogen auf den Lernfortschritt und Durchläufe, werden ignoriert."),
          widget.moduleId == null ? const SizedBox(height: Constants.listGap,) : Container(),
          widget.moduleId == null ? const Text("Falls du nur ein Modul exportieren möchtest, kannst du dies auf der Kartenübersicht des Moduls tun.") : Container(),
        ],
      ),
      actions: [
        TextButton(onPressed: () => _dismiss(), child: const Text("Abbrechen")),
        FilledButton.tonal(
          onPressed: () => _exportAllModules(),
          child: const Text("Alles exportieren"),
        ),
      ],
    );
  }

}