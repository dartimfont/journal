import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:journal/constants.dart';
import 'package:journal/globals.dart' as globals;
import 'package:journal/size_config.dart';

class AchievementList extends StatefulWidget {
  @override
  _AchievementListState createState() => _AchievementListState();
}

class _AchievementListState extends State<AchievementList> {
  final List<Group> _achievements = [];

  Future<List<Group>> fetchJson() async {
    dynamic params = jsonEncode({
      "id_group": globals.id_group,
      "id_discipline": globals.id_discipline,
      "id_student": globals.id_student
    });
    dynamic response = await http.post(
      Uri.parse("http://" + hostAndPort + "/selected_labs"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: params
    );

    List<Group> alist = [];
    if (response.statusCode == 200) {
      var urjson = jsonDecode(response.body);
      print(urjson);
      for (dynamic jsondata in urjson) {
        alist.add(Group.fromJson(jsondata));
      }
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
    return ListView.builder(
        itemCount: _achievements.length,
        itemBuilder: (context, index) {
          return Container(
              child: Row(
                children: [
                  SizedBox(width: SizeConfig.screenWidth * 0.04),
                  Expanded(
                    child: Text(
                      _achievements[index].lab.toString(),
                      style: TextStyle(fontSize: getProportionateScreenHeight(24)),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(width: SizeConfig.screenWidth * 0.04),
                  Checkbox(
                    onChanged: (bool isMark) {
                      setState(() {
                        _achievements[index].achieve = isMark;
                        // Update achieve on data base

                      });
                    },
                    value: _achievements[index].achieve,
                  ),
                  SizedBox(width: SizeConfig.screenWidth * 0.04),
                ],
              ),
          );
        }
    );
  }
}

class Group {
  int id_student;
  int id_lab;
  String lab;
  bool achieve;
  Group({
    @required this.id_student,
    @required this.id_lab,
    @required this.lab,
    @required this.achieve,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
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