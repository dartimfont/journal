import 'package:flutter/material.dart';

Future<dynamic> buildShowDialog(BuildContext context, responseBody) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Error!",
          textAlign: TextAlign.center,
        ),
        content: Text(
          responseBody["error"],
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}