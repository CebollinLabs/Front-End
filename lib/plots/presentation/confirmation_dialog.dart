import 'package:flutter/material.dart';

Future<void> showConfirmationDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Información'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Aceptar'),
        ),
      ],
    ),
  );
}
