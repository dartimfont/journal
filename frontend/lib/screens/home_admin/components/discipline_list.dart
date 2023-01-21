import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journal/components/error_message.dart';
import 'package:journal/constants.dart';

import 'package:http/http.dart' as http;

import 'globals_admin.dart' as globals_admin;
import 'package:journal/size_config.dart';

class DisciplineList extends StatefulWidget {
  @override
  _DisciplineListState createState() => _DisciplineListState();
}

class _DisciplineListState extends State<DisciplineList> {
  final List<Discipline> _disciplines = [];
  TextEditingController controller;

  Future<List<Discipline>> fetchJson() async {
    dynamic response = await http
        .get(Uri.parse("http://" + hostAndPort + "/disciplines"), headers: {
      'accept': 'application/json; charset=UTF-8',
    });

    print(response.body);

    List<Discipline> disciplineList = [];
    if (response.statusCode == 200) {
      var urlJson = jsonDecode(response.body);
      for (dynamic jsonData in urlJson) {
        print(jsonData);
        disciplineList.add(Discipline.fromJson(jsonData));
      }
    }
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
            Expanded(
              child: Text(
                "Disciplines",
                style: TextStyle(fontSize: 24),
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                "assets/icons/Plus Icon.svg",
                color: kTextColor,
                height: getProportionateScreenHeight(25),
              ),
              onPressed: () async {
                var data = jsonEncode({"discipline": "discipline"});
                dynamic response = await http.post(
                  Uri.parse("http://" + hostAndPort + "/disciplines"),
                  headers: {
                    "Content-Type": "application/json; charset=UTF-8",
                  },
                  body: data,
                );
                int status = response.statusCode;
                dynamic responseBody = jsonDecode(response.body);
                if (response.statusCode == 200) {
                  _disciplines.clear();
                  fetchJson().then((value) {
                    setState(() {
                      _disciplines.addAll(value);
                    });
                  });
                } else {
                  buildShowDialog(context, responseBody);
                }
              },
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
                    globals_admin.selectedIndexInDisciplines = index;
                    globals_admin.id_discipline = _disciplines[index].id_discipline;
                    globals_admin.discipline = _disciplines[index].discipline;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: index == globals_admin.selectedIndexInDisciplines
                      ? Colors.black12
                      : Colors.white60,
                  child: Row(
                    children: [
                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                      Expanded(
                          child: Text(
                        _disciplines[index].discipline.toString(),
                        style: TextStyle(fontSize: 24),
                      )),
                      IconButton(
                        onPressed: () {
                          controller =
                              TextEditingController(text: _disciplines[index].discipline);
                          showDialog(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Rename discipline"),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                content: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    child: const Text('Approve'),
                                    onPressed: () async {
                                      var data = jsonEncode({
                                        "id_discipline": _disciplines[index].id_discipline,
                                        "discipline": controller.text,
                                      });

                                      final response = await http.put(
                                          Uri.parse('http://' +
                                              hostAndPort +
                                              '/disciplines'),
                                          headers: <String, String>{
                                            "Content-Type":
                                            "application/json; charset=UTF-8",
                                          },
                                          body: data);

                                      int status = response.statusCode;
                                      dynamic responseBody =
                                      jsonDecode(response.body);
                                      print(response.statusCode);
                                      print(jsonDecode(response.body));

                                      if (status == 200) {
                                        _disciplines.clear();
                                        fetchJson().then((value) {
                                          setState(() {
                                            _disciplines.addAll(value);
                                          });
                                        });
                                      } else {

                                      }
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: SvgPicture.asset(
                          "assets/icons/Edit.svg",
                          color: kTextColor,
                          height: getProportionateScreenHeight(25),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          var data = jsonEncode({
                            "discipline": _disciplines[index].discipline,
                          });
                          dynamic response = await http.delete(
                            Uri.parse("http://" + hostAndPort + "/disciplines"),
                            headers: {
                              "Content-Type": "application/json; charset=UTF-8",
                            },
                            body: data,
                          );
                          int status = response.statusCode;
                          dynamic responseBody = jsonDecode(response.body);
                          if (response.statusCode == 200) {
                            _disciplines.clear();
                            fetchJson().then((value) {
                              setState(() {
                                _disciplines.addAll(value);
                              });
                            });
                          } else {
                            buildShowDialog(context, responseBody);
                          }
                        },
                        icon: SvgPicture.asset(
                          "assets/icons/Trash.svg",
                          color: kTextColor,
                          height: getProportionateScreenHeight(25),
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
