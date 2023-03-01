import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:flutter_karteikarten_app/entities/StorageManger.dart';
import 'package:flutter_karteikarten_app/forms/cardForm.dart';
import 'package:flutter_karteikarten_app/forms/controllers/weigthInputController.dart';
import 'package:flutter_karteikarten_app/utils/snackbars.dart';

class CardEditorDialog extends StatefulWidget {
  final IndexCard? indexCard;
  final Function(IndexCard)? onDidChange;
  final String moduleId;

  const CardEditorDialog({
    super.key,
    this.onDidChange,
    this.indexCard,
    required this.moduleId
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
  final WeightInputController weightInputController = WeightInputController();

  final StorageManager storageManager = StorageManager();

  late bool _isSaving;

  @override
  void initState() {
    super.initState();
    _setIsSaving(false);

    if(widget.indexCard != null) {
      nameController.text = widget.indexCard!.question;
      descriptionController.text = widget.indexCard!.answer;
      weightInputController.value = widget.indexCard!.cardWeight;
    }
  }

  _closeDialog() {
    Navigator.pop(context);
  }

  _saveCard() {
    if(_formKey.currentState?.validate() ?? false) {
      _setIsSaving(true);

      if (kDebugMode) {
        print("[CardEditorDialog] Form successfully validated.");
      }

      IndexCard card;
      // Update the card if a valid index card was passed to dialog
      if(widget.indexCard != null) {
        card = widget.indexCard ?? IndexCard(nameController.value.text, descriptionController.value.text);
        card.question = nameController.value.text;
        card.answer = descriptionController.value.text;
        card.cardWeight = weightInputController.value;
      } else {
        // Otherwise create new card
        card = IndexCard(nameController.value.text, descriptionController.value.text);
        card.cardWeight = weightInputController.value;
      }

      storageManager.saveCard(widget.moduleId, card).then((succeeded) {
        if(succeeded) {
          if (kDebugMode) {
            print("[CardEditorDialog] Saved card: ${card.toJson()}");
          }

          widget.onDidChange?.call(card);
          _closeDialog();
          Snackbars.message("Die Karte wurde ${widget.indexCard != null ? 'bearbeitet' : 'erstellt'}.", context);
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
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.indexCard != null ? "Karte bearbeiten" : "Neue Karte erstellen"),
          leading: IconButton(onPressed: () => _closeDialog(), icon: const Icon(Icons.close)),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(onPressed: () => _saveCard(), icon: _isSaving ? _renderProgress() : const Icon(Icons.save)),
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
                weightInputController: weightInputController,
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
                  onPressed: () => _saveCard(),
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