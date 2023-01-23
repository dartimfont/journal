import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import 'package:journal/components/message.dart';
import 'package:journal/constants.dart';

import 'globals_admin.dart' as globals_admin;
import 'package:journal/size_config.dart';

class StudentList extends StatefulWidget {
  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  final List<Student> _students = [];
  TextEditingController controller;

  Future<List<Student>> fetchJson() async {
    dynamic data = jsonEncode({"group": globals_admin.group});
    dynamic response =
        await http.post(Uri.parse("http://" + hostAndPort + "/students_get"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: data);
    int status = response.statusCode;
    dynamic responseBody = jsonDecode(response.body);
    print(status);
    print(responseBody);
    List<Student> studentList = [];
    if (status == 200) {
      var urlJson = responseBody;
      for (dynamic jsonData in urlJson) {
        studentList.add(Student.fromJson(jsonData));
      }
    }
    return studentList;
  }

  @override
  void initState() {
    fetchJson().then((value) {
      setState(() {
        _students.addAll(value);
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
                "Students",
                style: TextStyle(fontSize: 22),
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                "assets/icons/Plus Icon.svg",
                color: kTextColor,
                height: getProportionateScreenHeight(20),
              ),
              onPressed: () async {
                var data = jsonEncode({
                  "id_student": -1,
                  "id_group": globals_admin.id_group,
                  "name": "name",
                  "surname": "surname"
                });
                dynamic response = await http.post(
                  Uri.parse("http://" + hostAndPort + "/students"),
                  headers: {
                    "Content-Type": "application/json; charset=UTF-8",
                  },
                  body: data,
                );
                int status = response.statusCode;
                dynamic responseBody = jsonDecode(response.body);
                if (status == 200) {
                  _students.clear();
                  fetchJson().then((value) {
                    setState(() {
                      _students.addAll(value);
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
        Row(
          children: [
            SizedBox(width: SizeConfig.screenWidth * 0.04),
            Expanded(
              child: Text(
                "Surname, Name",
                style: TextStyle(fontSize: 22),
              ),
            ),
            SizedBox(width: SizeConfig.screenWidth * 0.04),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _students.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    globals_admin.selectedIndexInStudents = index;
                    globals_admin.id_student = _students[index].id_student;
                    globals_admin.surname = _students[index].surname;
                    globals_admin.name = _students[index].name;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: index == globals_admin.selectedIndexInStudents
                      ? Colors.black12
                      : Colors.white60,
                  child: Row(
                    children: [
                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                      Expanded(
                          child: Text(
                        _students[index].surname,
                        style: TextStyle(fontSize: 22),
                      )),
                      IconButton(
                        onPressed: () {
                          controller =
                              TextEditingController(text: _students[index].surname);
                          showDialog(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Rename surname"),
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
                                    child: const Text('Rename'),
                                    onPressed: () async {
                                      var data = jsonEncode({
                                        "id_student": _students[index].id_student,
                                        "id_group": globals_admin.id_group,
                                        "surname": controller.text,
                                        "name": _students[index].name,
                                      });

                                      final response = await http.put(
                                          Uri.parse('http://' +
                                              hostAndPort +
                                              '/students'),
                                          headers: {
                                            "Content-Type":
                                            "application/json; charset=UTF-8",
                                          },
                                          body: data);
                                      int status = response.statusCode;
                                      dynamic responseBody =
                                      jsonDecode(response.body);
                                      if (status == 200) {
                                        _students.clear();
                                        fetchJson().then((value) {
                                          setState(() {
                                            _students.addAll(value);
                                          });
                                        });
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
                      Expanded(
                          child: Text(
                        _students[index].name,
                        style: TextStyle(fontSize: 20),
                      )),
                      IconButton(
                        onPressed: () {
                          controller =
                              TextEditingController(text: _students[index].name);
                          showDialog(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Rename name"),
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
                                    child: const Text('Rename'),
                                    onPressed: () async {
                                      var data = jsonEncode({
                                        "id_student": _students[index].id_student,
                                        "id_group": globals_admin.id_group,
                                        "surname": _students[index].surname,
                                        "name": controller.text,
                                      });

                                      final response = await http.put(
                                          Uri.parse('http://' +
                                              hostAndPort +
                                              '/students'),
                                          headers: {
                                            "Content-Type":
                                            "application/json; charset=UTF-8",
                                          },
                                          body: data);
                                      int status = response.statusCode;
                                      dynamic responseBody =
                                      jsonDecode(response.body);
                                      if (status == 200) {
                                        _students.clear();
                                        fetchJson().then((value) {
                                          setState(() {
                                            _students.addAll(value);
                                          });
                                        });
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
                            "id_student": _students[index].id_student,
                            "id_group": -1,
                            "name": "",
                            "surname": ""
                          });
                          dynamic response = await http.delete(
                            Uri.parse("http://" + hostAndPort + "/students"),
                            headers: {
                              "Content-Type": "application/json; charset=UTF-8",
                            },
                            body: data,
                          );
                          int status = response.statusCode;
                          dynamic responseBody = jsonDecode(response.body);
                          if (status == 200) {
                            _students.clear();
                            fetchJson().then((value) {
                              setState(() {
                                _students.addAll(value);
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
        ),
      ],
    );
  }
}

class Student {
  int id_student;
  String surname;
  String name;

  Student({
    @required this.id_student,
    @required this.surname,
    @required this.name,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id_student: json["id_student"],
        surname: json["surname"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id_student": id_student,
        "surname": surname,
        "name": name,
      };
}
