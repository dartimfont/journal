import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:journal/components/error_message.dart';
import 'package:journal/constants.dart';

import 'globals_student.dart' as globals_student;
import 'package:journal/size_config.dart';

class AchievementList extends StatefulWidget {
  @override
  _AchievementListState createState() => _AchievementListState();
}

class _AchievementListState extends State<AchievementList> {
  final List<Lab> _achievements = [];

  Future<List<Lab>> fetchJson() async {
    dynamic params = jsonEncode({
      "id_group": globals_student.id_group,
      "id_discipline": globals_student.id_discipline,
      "id_student": globals_student.id_student
    });
    dynamic response =
        await http.post(Uri.parse("http://" + hostAndPort + "/selected_labs"),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: params);

    int status = response.statusCode;
    dynamic responseBody = jsonDecode(response.body);
    print(status);
    print(responseBody);

    List<Lab> achievementList = [];
    if (status == 200) {
      var urlJson = responseBody;
      for (dynamic jsonData in urlJson) {
        achievementList.add(Lab.fromJson(jsonData));
      }
    } else {
      buildShowDialog(context, responseBody);
    }
    return achievementList;
  }

  @override
  void initState() {
    fetchJson().then((value) {
      setState(() {
        _achievements.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          SizedBox(width: SizeConfig.screenWidth * 0.04),
          Text(
            "Labs" + " " + globals_student.group + " " + globals_student.discipline,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: SizeConfig.screenWidth * 0.04),
        ],
      ),
      Expanded(
          child: ListView.builder(
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                return Container(
                  child: Row(
                    children: [
                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                      Expanded(
                        child: Text(
                          _achievements[index].lab.toString(),
                          style: TextStyle(
                              fontSize: getProportionateScreenHeight(24)),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                      Checkbox(
                        value: _achievements[index].achieve,
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                    ],
                  ),
                );
              }))
    ]);
  }
}

class Lab {
  int id_student;
  int id_lab;
  String lab;
  bool achieve;
  Lab({
    @required this.id_student,
    @required this.id_lab,
    @required this.lab,
    @required this.achieve,
  });

  factory Lab.fromJson(Map<String, dynamic> json) => Lab(
        id_student: json["id_student"],
        id_lab: json["id_lab"],
        lab: json["lab"],
        achieve: json["achieve"],
      );

  Map<String, dynamic> toJson() => {
        "id_student": id_student,
        "id_lab": id_lab,
        "lab": lab,
        "achieve": achieve,
      };
}
