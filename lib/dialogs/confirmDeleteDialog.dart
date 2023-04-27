
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfirmDeleteDialog extends StatefulWidget {
  final String title;
  final String message;
  final Function(bool) onConfirmed;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirmed,
  });

  @override
  State<StatefulWidget> createState() {
    return _ConfirmDeleteDialogState();
  }

}

class _ConfirmDeleteDialogState extends State<ConfirmDeleteDialog> {

  _dismiss() {
    if(!context.canPop()) return;
    context.pop();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Text(widget.message),
      actions: [
        TextButton(
            onPressed: () {
              //_dismiss();
              widget.onConfirmed(false);
            },
            child: const Text("Nicht löschen")
        ),
        FilledButton.tonal(
            onPressed: () {
              //_dismiss();
              widget.onConfirmed(true);
            },
            child: const Text("Löschen")
        )
      ],
    );
  }

}