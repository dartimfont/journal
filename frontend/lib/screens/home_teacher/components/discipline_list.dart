import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:journal/constants.dart';

import 'package:http/http.dart' as http;
import 'package:journal/size_config.dart';

import 'globals_teacher.dart' as globals_teacher;

class DisciplineList extends StatefulWidget {
  @override
  _DisciplineListState createState() => _DisciplineListState();
}

class _DisciplineListState extends State<DisciplineList> {
  final List<Discipline> _disciplines = [];

  Future<List<Discipline>> fetchJson() async {
    var data = jsonEncode({
      "login": globals_teacher.login,
      "group": globals_teacher.group,
    });
    dynamic response = await http.post(
      Uri.parse("http://" + hostAndPort + "/disciplines_get_for_teacher"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: data,
    );
    List<Discipline> disciplineList = [];
    if (response.statusCode == 200) {
      var urlJson = jsonDecode(response.body);
      for (dynamic jsonData in urlJson) {
        print(jsonData);
        disciplineList.add(Discipline.fromJson(jsonData));
      }
    } else {}
    return disciplineList;
  }

  @override
  void initState() {
    fetchJson().then((value) {
      setState(() {
        _disciplines.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: SizeConfig.screenWidth * 0.04),
            Text(
              "Disciplines",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(width: SizeConfig.screenWidth * 0.04),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _disciplines.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    globals_teacher.selectedIndexInDisciplines = index;
                    globals_teacher.id_discipline =
                        _disciplines[index].id_discipline;
                    globals_teacher.discipline = _disciplines[index].discipline;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: index == globals_teacher.selectedIndexInDisciplines
                      ? Colors.black12
                      : Colors.white60,
                  child: Row(
                    children: [
                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                      Expanded(
                        child: Text(
                          _disciplines[index].discipline.toString(),
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class Discipline {
  int id_discipline;
  String discipline;
  Discipline({
    @required this.id_discipline,
    @required this.discipline,
  });

  factory Discipline.fromJson(Map<String, dynamic> json) => Discipline(
        id_discipline: json["id_discipline"],
        discipline: json["discipline"],
      );

  Map<String, dynamic> toJson() => {
        "id_discipline": id_discipline,
        "discipline": discipline,
      };
}
