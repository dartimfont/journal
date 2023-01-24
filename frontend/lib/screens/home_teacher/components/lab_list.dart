import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journal/components/message.dart';
import 'package:journal/constants.dart';

import 'package:http/http.dart' as http;
import 'package:journal/size_config.dart';

import 'globals_teacher.dart' as globals_teacher;

class LabList extends StatefulWidget {
  @override
  _LabListState createState() => _LabListState();
}

class _LabListState extends State<LabList> {
  final List<Lab> _labs = [];
  TextEditingController controller;

  Future<List<Lab>> fetchJson() async {
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
    fetchJson().then((value) {
      setState(() {
        _labs.addAll(value);
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
              "Labs",
              style: TextStyle(fontSize: 24),
            )),
            IconButton(
              icon: SvgPicture.asset(
                "assets/icons/Plus Icon.svg",
                color: kTextColor,
                height: getProportionateScreenHeight(25),
              ),
              onPressed: () async {
                var data = jsonEncode({
                  "login": globals_teacher.login,
                  "id_group": globals_teacher.id_group,
                  "id_discipline": globals_teacher.id_discipline,
                  "lab": "lab",
                });
                dynamic response = await http.post(
                  Uri.parse("http://" + hostAndPort + "/labs_for_schedule"),
                  headers: {
                    "Content-Type": "application/json; charset=UTF-8",
                  },
                  body: data,
                );
                int status = response.statusCode;
                dynamic responseBody = jsonDecode(utf8.decode(response.bodyBytes));
                if (response.statusCode == 200) {
                  _labs.clear();
                  fetchJson().then((value) {
                    setState(() {
                      _labs.addAll(value);
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
            itemCount: _labs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    globals_teacher.selectedIndexInLabs = index;
                    globals_teacher.id_lab = _labs[index].id_lab;
                    globals_teacher.lab = _labs[index].lab;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: index == globals_teacher.selectedIndexInLabs
                      ? Colors.black12
                      : Colors.white60,
                  child: Row(
                    children: [
                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                      Expanded(
                        child: Text(
                          _labs[index].lab.toString(),
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          controller =
                              TextEditingController(text: _labs[index].lab);
                          showDialog(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Rename lab"),
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
                                        "id_lab": _labs[index].id_lab,
                                        "lab": controller.text,
                                      });

                                      final response = await http.put(
                                          Uri.parse('http://' +
                                              hostAndPort +
                                              '/labs'),
                                          headers: <String, String>{
                                            "Content-Type":
                                                "application/json; charset=UTF-8",
                                          },
                                          body: data);

                                      int status = response.statusCode;
                                      dynamic responseBody =
                                          jsonDecode(utf8.decode(response.bodyBytes));
                                      print(response.statusCode);
                                      print(jsonDecode(utf8.decode(response.bodyBytes)));

                                      if (status == 200) {
                                        _labs.clear();
                                        fetchJson().then((value) {
                                          setState(() {
                                            _labs.addAll(value);
                                          });
                                        });
                                      } else {
                                        buildShowDialog(context, responseBody);
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
                          var data = jsonEncode(
                              {"id_lab": _labs[index].id_lab, "lab": ""});
                          dynamic response = await http.delete(
                            Uri.parse("http://" + hostAndPort + "/labs"),
                            headers: {
                              "Content-Type": "application/json; charset=UTF-8",
                            },
                            body: data,
                          );
                          int status = response.statusCode;
                          dynamic responseBody = jsonDecode(utf8.decode(response.bodyBytes));
                          if (response.statusCode == 200) {
                            _labs.clear();
                            fetchJson().then((value) {
                              setState(() {
                                _labs.addAll(value);
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

class Lab {
  int id_lab;
  String lab;
  Lab({
    @required this.id_lab,
    @required this.lab,
  });

  factory Lab.fromJson(Map<String, dynamic> json) => Lab(
        id_lab: json["id_lab"],
        lab: json["lab"],
      );

  Map<String, dynamic> toJson() => {
        "id_lab": id_lab,
        "lab": lab,
      };
}
