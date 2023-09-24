import 'package:flutter/material.dart';

Future<bool> showDeleteConfirmationDialog(
    BuildContext context, String message) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmación'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      ) ??
      false; // Si se hace clic fuera del cuadro de diálogo, devuelve false
}
