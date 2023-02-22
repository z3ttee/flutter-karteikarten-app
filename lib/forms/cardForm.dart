
import 'package:flutter/material.dart';

class CardForm extends StatefulWidget {
  // Form key to uniquely identify the form
  // for validation tasks
  final GlobalKey<FormState> formKey;

  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const CardForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController
  });

  @override
  State<StatefulWidget> createState() {
    return _CardFormState();
  }

}

class _CardFormState extends State<CardForm> {
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
          const SizedBox(height: 12,),
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
            maxLength: 250,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte gib einen Wert ein';
              }
              return null;
            }
          )
        ],
      ),
    );
  }

}