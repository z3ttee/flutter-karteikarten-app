
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants.dart';
import '../../entities/Module.dart';

class ModuleBottomSheet extends StatefulWidget {
  final Module module;

  final Function(Module)? onEdit;
  final Function(Module)? onDelete;
  final Function(Module)? onExport;

  const ModuleBottomSheet({
    super.key,
    required this.module,
    this.onEdit,
    this.onDelete,
    this.onExport
  });

  @override
  State<StatefulWidget> createState() {
    return _ModuleBottomSheetState();
  }

}

class _ModuleBottomSheetState extends State<ModuleBottomSheet> {

  _dismiss() {
    if(!context.canPop()) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Constants.sectionMarginX, vertical: Constants.sectionMarginX),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Render edit list item
            widget.onEdit == null ? Container() : ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Bearbeiten"),
              subtitle: const Text("Modulinformationen anpassen"),
              onTap: () {
                _dismiss();
                widget.onEdit?.call(widget.module);
              },
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Constants.bottomSheetTileRadius))
              ),
            ),
            /// Render delete list item
            widget.onDelete == null ? Container() : ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Löschen"),
              subtitle: const Text("Modul löschen"),
              onTap: () {
                _dismiss();
                widget.onDelete?.call(widget.module);
              },
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Constants.bottomSheetTileRadius))
              ),
            ),
            /// Render export list item
            widget.onExport == null ? Container() : ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text("Exportieren"),
              subtitle: const Text("Modul zum Teilen exportieren"),
              onTap: () {
                _dismiss();
                widget.onExport?.call(widget.module);
              },
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Constants.bottomSheetTileRadius))
              ),
            ),
          ],
        ),
      ),
    );
  }

}