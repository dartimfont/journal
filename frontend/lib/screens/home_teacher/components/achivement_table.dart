import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:journal/constants.dart';
import 'package:journal/screens/home_admin/components/student_list.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:http/http.dart' as http;
import 'globals_teacher.dart' as globals_teacher;

import 'model.dart';
import 'table_head.dart';
import 'table_body.dart';

class AchievementTable extends StatefulWidget {
  @override
  _AchievementTableState createState() => _AchievementTableState();
}

class _AchievementTableState extends State<AchievementTable> {
  LinkedScrollControllerGroup _controllers;
  ScrollController _headController;
  ScrollController _bodyController;
  final List<Lab> _labs = [];

  Future<List<Lab>> fetchLabs() async {
    var data = jsonEncode({
      "login": globals_teacher.login,
      "group": globals_teacher.group,
      "discipline": globals_teacher.discipline,
    });
    dynamic response = await http.post(
      Uri.parse("http://" + hostAndPort + "/labs_get_for_teacher"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: data,
    );
    List<Lab> labList = [];
    if (response.statusCode == 200) {
      var urlJson = jsonDecode(utf8.decode(response.bodyBytes));
      for (dynamic jsonData in urlJson) {
        print(jsonData);
        labList.add(Lab.fromJson(jsonData));
      }
    }
    return labList;
  }

  @override
  void initState() {
    super.initState();
    fetchLabs().then((value) {
      setState(() {
        _labs.addAll(value);
      });
    });
    _controllers = LinkedScrollControllerGroup();
    _headController = _controllers.addAndGet();
    _bodyController = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _headController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableHead(
          scrollController: _headController,
          labs: _labs,
        ),
        Expanded(
          child: TableBody(
            scrollController: _bodyController,
          ),
        ),
      ],
    );
  }
}


