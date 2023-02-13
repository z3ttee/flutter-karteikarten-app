
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/entities/Module.dart';
import 'package:flutter_karteikarten_app/forms/moduleForm.dart';

class ModuleEditorDialog extends StatefulWidget {
  final Module? module;
  const ModuleEditorDialog({super.key, this.module});

  @override
  State<StatefulWidget> createState() {
    return _ModuleEditorState();
  }

}

class _ModuleEditorState extends State<ModuleEditorDialog> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  _closeDialog(BuildContext context) {
    Navigator.pop(context);
  }

  _saveModule() {

  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Modul bearbeiten"),
          leading: IconButton(onPressed: () => _closeDialog(context), icon: const Icon(Icons.close)),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(onPressed: () => _saveModule(), icon: const Icon(Icons.save)),
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
                  onPressed: () => _closeDialog(context),
                  child: const Text("Abbrechen")
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: ElevatedButton(
                  onPressed: () => _saveModule(),
                  child: const Text("Speichern"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}