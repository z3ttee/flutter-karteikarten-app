
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/forms/moduleForm.dart';
import 'package:flutter_karteikarten_app/utils/snackbars.dart';

class ModuleEditorDialog extends StatefulWidget {
  final Module? module;
  final Function? onDidChange;

  const ModuleEditorDialog({
    super.key,
    this.module,
    this.onDidChange
  });

  @override
  State<StatefulWidget> createState() {
    return _ModuleEditorState();
  }

}

class _ModuleEditorState extends State<ModuleEditorDialog> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  late bool _isSaving;

  _closeDialog() {
    Navigator.pop(context);
  }

  _saveModule() {
    if(_formKey.currentState?.validate() ?? false) {
      _setIsSaving(true);

      if (kDebugMode) {
        print("[ModuleEditorDialog] Form successfully validated.");
      }

      Module module;
      // Update the module if editor is in edit mode
      if(widget.module != null) {
        module = widget.module ?? Module(nameController.value.text, descriptionController.value.text.isEmpty ? null : descriptionController.value.text);
        module.name = nameController.value.text;
        module.description = descriptionController.value.text.isEmpty ? null : descriptionController.value.text;
      } else {
        // Otherwise create new module
        module = Module(nameController.value.text, descriptionController.value.text.isEmpty ? null : descriptionController.value.text);
      }

      var manager = StorageManager();
      manager.saveModule(module).then((succeeded) {
        if(succeeded) {
          if (kDebugMode) {
            print("[ModuleEditorDialog] Saved module: ${module.toJson()}");
          }

          widget.onDidChange?.call();
          _closeDialog();
          Snackbars.message("Das Modul wurde ${widget.module != null ? 'bearbeitet' : 'erstellt'}.", context);
        } else {
          Snackbars.message("Das Modul konnte nicht gespeichert werden", context);
        }
      }).onError((error, stackTrace) {
        _setIsSaving(false);
      });
    } else {
      if (kDebugMode) {
        print("[ModuleEditorDialog] Form values not valid.");
      }
    }
  }

  _setIsSaving(bool val) {
    setState(() { _isSaving = val; });
  }

  @override
  void initState() {
    super.initState();
    _setIsSaving(false);

    if(widget.module != null) {
      nameController.text = widget.module!.name;
      descriptionController.text = widget.module!.description ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.module != null ? "Modul bearbeiten" : "Neues Modul erstellen"),
          leading: IconButton(onPressed: () => _closeDialog(), icon: const Icon(Icons.close)),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(onPressed: () => _saveModule(), icon: _isSaving ? _renderProgress() : const Icon(Icons.save)),
            )
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: ModuleForm(
                formKey: _formKey,
                nameController: nameController,
                descriptionController: descriptionController,
              ),
            )
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () => _closeDialog(),
                  child: const Text("Abbrechen")
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ElevatedButton(
                  onPressed: () => _saveModule(),
                  child: _isSaving ? _renderProgress() : const Text("Speichern"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderProgress() {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
      ),
    );
  }

}