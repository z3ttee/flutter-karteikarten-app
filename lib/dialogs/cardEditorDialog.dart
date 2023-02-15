
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/forms/cardForm.dart';
import 'package:flutter_karteikarten_app/forms/moduleForm.dart';
import 'package:flutter_karteikarten_app/utils/snackbars.dart';

enum CardEditorMode {
  create("create"),
  edit("edit");

  final String value;
  const CardEditorMode(this.value);
}

class CardEditorDialog extends StatefulWidget {
  final IndexCard? indexCard;
  final CardEditorMode? mode;
  final Function? onDidChange;
  final String moduleId;

  const CardEditorDialog({
    super.key,
    this.mode = CardEditorMode.create,
    this.onDidChange,
    this.indexCard, required this.moduleId
  });

  @override
  State<StatefulWidget> createState() {
    return _CardEditorState();
  }

}

class _CardEditorState extends State<CardEditorDialog> {

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

      IndexCard card;
      // Update the module if editor is in edit mode
      if(widget.mode == CardEditorMode.edit) {
        card = widget.indexCard ?? IndexCard(nameController.value.text, descriptionController.value.text);
        card.question = nameController.value.text;
        card.answer = descriptionController.value.text;
      } else {
        // Otherwise create new module
        card = IndexCard(nameController.value.text, descriptionController.value.text);
      }

      var manager = StorageManager();
      manager.saveCard(widget.moduleId, card).then((succeeded) {
        if(succeeded) {
          if (kDebugMode) {
            print("[CardEditorDialog] Saved card: ${card.toJson()}");
          }

          widget.onDidChange?.call();
          _closeDialog();
          Snackbars.message("Die Karte wurde ${widget.mode == CardEditorMode.edit ? 'bearbeitet' : 'erstellt'}.", context);
        } else {
          Snackbars.message("Die Karte konnte nicht gespeichert werden", context);
        }
      }).onError((error, stackTrace) {
        _setIsSaving(false);
      });
    } else {
      if (kDebugMode) {
        print("[CardEditorDialog] Form values not valid.");
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

    if(widget.indexCard != null) {
      nameController.text = widget.indexCard!.question;
      descriptionController.text = widget.indexCard!.answer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.mode == CardEditorMode.edit ? "Karte bearbeiten" : "Neue Karte erstellen"),
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
              child: CardForm(
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