import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:journal/components/error_message.dart';
import 'package:journal/constants.dart';

import 'package:http/http.dart' as http;

Future<T> showTextDialog<T>(
    BuildContext context, {
      @required String title,
      @required int id_group,
      @required String group,
    }) =>
    showDialog<T>(
      context: context,
      builder: (context) => TextDialogWidget(
        title: title,
        id_group: id_group,
        group: group,
      ),
    );

class TextDialogWidget extends StatefulWidget {
  final String title;
  final int id_group;
  final String group;

  const TextDialogWidget({
    Key key,
    @required this.title,
    @required this.id_group,
    @required this.group,
  }) : super(key: key);

  @override
  _TextDialogWidgetState createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.group);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Text(widget.title),
    content:
      TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
    actions: [
      ElevatedButton(
        child: Text('Done'),
        onPressed: () async {
            print(widget.id_group);
            print(controller.text);

            var data = jsonEncode({
              "id_group": widget.id_group,
              "group": controller.text,
            });

            final response = await http.put(
                Uri.parse('http://' + hostAndPort + '/groups'),
                headers: <String, String>{
                  "Content-Type": "application/json; charset=UTF-8",
                },
                body: data
            );

            int status = response.statusCode;
            dynamic responseBody = jsonDecode(response.body);
            print(response.statusCode);
            print(jsonDecode(response.body));

            if (status == 200) {

            } else {
              buildShowDialog(context, responseBody);
            }

            Navigator.of(context).pop(controller.text);
        },
      )
    ],
  );
}