import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:journal/components/error_message.dart';
import 'package:journal/constants.dart';
import 'package:journal/size_config.dart';

import 'globals_teacher.dart' as globals_teacher;
import 'package:http/http.dart' as http;

class AchievementList extends StatefulWidget {
  @override
  _AchievementListState createState() => _AchievementListState();
}

class _AchievementListState extends State<AchievementList> {
  final List<Achiev> _achievements = [];

  Future<List<Achiev>> fetchJson() async {
    dynamic params = jsonEncode({
      "id_group": globals_teacher.id_group,
      "id_discipline": globals_teacher.id_discipline,
      "id_student": globals_teacher.id_student
    });
    dynamic response =
        await http.post(Uri.parse("http://" + hostAndPort + "/selected_labs"),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: params);
    int status = response.statusCode;
    dynamic responseBody = jsonDecode(response.body);
    List<Achiev> alist = [];
    if (status == 200) {
      var urjson = jsonDecode(response.body);
      print(urjson);
      for (dynamic jsonData in urjson) {
        alist.add(Achiev.fromJson(jsonData));
      }
    } else {
      buildShowDialog(context, responseBody);
    }
    return alist;
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
            "Labs" +
                " " +
                globals_teacher.group +
                " " +
                globals_teacher.discipline,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: SizeConfig.screenWidth * 0.04),
        ],
      ),
      Row(
        children: [
          SizedBox(width: SizeConfig.screenWidth * 0.04),
          Text(
            "Student" +
                " " +
                globals_teacher.surname +
                " " +
                globals_teacher.name,
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
                        activeColor: kPrimaryColor,
                        onChanged: (bool isMark) async {
                            _achievements[index].achieve = isMark;
                            // Update achieve on data base
                            var data = jsonEncode({
                              "id_student": _achievements[index].id_student,
                              "id_lab": _achievements[index].id_lab,
                              "achieve": _achievements[index].achieve,
                            });
                            dynamic response = await http.put(
                              Uri.parse(
                                  "http://" + hostAndPort + "/labs_achieve"),
                              headers: {
                                "Content-Type":
                                    "application/json; charset=UTF-8",
                              },
                              body: data,
                            );
                            if (response.statusCode == 200) {
                              _achievements.clear();
                              fetchJson().then((value) {
                                setState(() {
                                  _achievements.addAll(value);
                                });
                              });
                            } else {}


                        },
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

class Achiev {
  int id_student;
  int id_lab;
  String lab;
  bool achieve;
  Achiev({
    @required this.id_student,
    @required this.id_lab,
    @required this.lab,
    @required this.achieve,
  });

  factory Achiev.fromJson(Map<String, dynamic> json) => Achiev(
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
