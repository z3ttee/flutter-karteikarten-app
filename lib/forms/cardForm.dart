
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/forms/controllers/weigthInputController.dart';

class CardForm extends StatefulWidget {
  // Form key to uniquely identify the form
  // for validation tasks
  final GlobalKey<FormState> formKey;

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final WeightInputController weightInputController;

  const CardForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.weightInputController
  });

  @override
  State<StatefulWidget> createState() {
    return _CardFormState();
  }

}

class _CardFormState extends State<CardForm> {

  late final List<bool> _weights;
  
  _setSelectedWeight(int index) {
    widget.weightInputController.value = CardWeight.getByIndex(index);
  }

  _handleWeightControllerValue() {
    var index = CardWeight.idToIndex(widget.weightInputController.value.value);
    setState(() {
      // The button that is tapped is set to true, and the others to false.
      for (int i = 0; i < _weights.length; i++) {
        _weights[i] = i == index;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _weights = [true, false, false];
    widget.weightInputController.addListener(_handleWeightControllerValue);
  }

  @override
  void dispose() {
    super.dispose();
    widget.weightInputController.removeListener(_handleWeightControllerValue);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 32, left: 16, right: 16),
            child: Text(
              "Ein Modul kannst du nutzen, um deine Karteikarten besser zu organisieren. Zum Beispiel kannst du pro Thema ein Modul erstellen und darin deine Karteikarten verwalten.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // TextFormField for module name
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: TextFormField(
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Begriff / Frage der Karte',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              maxLines: 1,
              maxLength: 120,
              controller: widget.nameController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib einen Wert ein';
                }
                return null;
              },
            )
          ),
          // Add some space between form fields
          const SizedBox(height: Constants.sectionMarginY,),
          // TextFormField for module description
          TextFormField(
            decoration: const InputDecoration(
                filled: true,
                labelText: 'Wie lautet die Antwort für diese Karte?',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
            controller: widget.descriptionController,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte gib einen Wert ein';
              }
              return null;
            }
          ),
          const SizedBox(height: Constants.sectionMarginY,),
          Padding(
            padding: const EdgeInsets.only(bottom: Constants.listGap*2, left: Constants.listGap, right: Constants.listGap),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Wie schwer ist die Frage zu beantworten?", textAlign: TextAlign.left, style: Theme.of(context).textTheme.labelLarge,),
            ),
          ),
          ToggleButtons(
            borderRadius: BorderRadius.circular(Constants.cardBorderRadius),
            isSelected: _weights,
            onPressed: (int index) => _setSelectedWeight(index),
            constraints: BoxConstraints(
              minWidth: (MediaQuery.of(context).size.width - 36) / 3,
              minHeight: 40
            ),
            children: const [
              Text("Leicht"),
              Text("Mittel"),
              Text("Schwer")
            ],
          )
        ],
      ),
    );
  }

}