import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import 'package:journal/components/message.dart';
import 'package:journal/constants.dart';

import 'globals_admin.dart' as globals_admin;
import 'package:journal/size_config.dart';

class TeacherList extends StatefulWidget {
  @override
  _TeacherListState createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList> {
  final List<Teacher> _teachers = [];
  TextEditingController controller;

  Future<List<Teacher>> fetchJson() async {
    dynamic response =
        await http.get(Uri.parse("http://" + hostAndPort + "/teachers"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
        );
    int status = response.statusCode;
    dynamic responseBody = jsonDecode(response.body);
    print(status);
    print(responseBody);
    List<Teacher> studentList = [];
    if (status == 200) {
      var urlJson = responseBody;
      for (dynamic jsonData in urlJson) {
        studentList.add(Teacher.fromJson(jsonData));
      }
    }
    return studentList;
  }

  @override
  void initState() {
    fetchJson().then((value) {
      setState(() {
        _teachers.addAll(value);
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
                "Teachers",
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
                  "login": "new_login",
                  "password": md5.convert(utf8.encode("12345678")).toString(),
                  "surname": "surname",
                  "name": "name"
                });
                dynamic response = await http.post(
                  Uri.parse("http://" + hostAndPort + "/teachers"),
                  headers: {
                    "Content-Type": "application/json; charset=UTF-8",
                  },
                  body: data,
                );
                int status = response.statusCode;
                dynamic responseBody = jsonDecode(response.body);
                if (status == 200) {
                  _teachers.clear();
                  fetchJson().then((value) {
                    setState(() {
                      _teachers.addAll(value);
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
                "Surname, Name, Login, Reset password",
                style: TextStyle(fontSize: 22),
              ),
            ),
            SizedBox(width: SizeConfig.screenWidth * 0.04),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _teachers.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    globals_admin.selectedIndexInTeachers = index;
                    globals_admin.id_teacher = _teachers[index].id_teacher;
                    globals_admin.login = _teachers[index].login;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: index == globals_admin.selectedIndexInTeachers
                      ? Colors.black12
                      : Colors.white60,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(width: SizeConfig.screenWidth * 0.04),
                          Expanded(
                              child: Text(
                                _teachers[index].surname,
                            style: TextStyle(fontSize: 22),
                          )),
                          IconButton(
                            onPressed: () {
                              controller = TextEditingController(
                                  text: _teachers[index].surname);
                              showDialog(
                                context: context,
                                barrierDismissible:
                                    false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Rename surname"),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
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
                                            "id_teacher": _teachers[index].id_teacher,
                                            "login": _teachers[index].login,
                                            "surname": controller.text,
                                            "name": _teachers[index].name,
                                          });
                                          final response = await http.put(
                                              Uri.parse('http://' +
                                                  hostAndPort +
                                                  '/teachers'),
                                              headers: {
                                                "Content-Type":
                                                "application/json; charset=UTF-8",
                                              },
                                              body: data);
                                          int status = response.statusCode;
                                          dynamic responseBody =
                                          jsonDecode(response.body);
                                          if (status == 200) {
                                            _teachers.clear();
                                            fetchJson().then((value) {
                                              setState(() {
                                                _teachers.addAll(value);
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
                                _teachers[index].name,
                            style: TextStyle(fontSize: 20),
                          )),
                          IconButton(
                            onPressed: () {
                              controller = TextEditingController(
                                  text: _teachers[index].name);
                              showDialog(
                                context: context,
                                barrierDismissible:
                                false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Rename name"),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20)),
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
                                            "id_teacher": _teachers[index].id_teacher,
                                            "login": _teachers[index].login,
                                            "surname": _teachers[index].surname,
                                            "name": controller.text,
                                          });
                                          final response = await http.put(
                                              Uri.parse('http://' +
                                                  hostAndPort +
                                                  '/teachers'),
                                              headers: {
                                                "Content-Type":
                                                "application/json; charset=UTF-8",
                                              },
                                              body: data);
                                          int status = response.statusCode;
                                          dynamic responseBody =
                                          jsonDecode(response.body);
                                          if (status == 200) {
                                            _teachers.clear();
                                            fetchJson().then((value) {
                                              setState(() {
                                                _teachers.addAll(value);
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
                          SizedBox(width: SizeConfig.screenWidth * 0.04),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: SizeConfig.screenWidth * 0.04),
                          Expanded(
                            child: Text(
                              _teachers[index].login,
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              controller = TextEditingController(
                                  text: _teachers[index].login);
                              showDialog(
                                context: context,
                                barrierDismissible:
                                false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Rename login"),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20)),
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
                                            "oldLogin": _teachers[index].login,
                                            "newLogin": controller.text,
                                          });
                                          final response = await http.put(
                                              Uri.parse('http://' +
                                                  hostAndPort +
                                                  '/teachers_login'),
                                              headers: {
                                                "Content-Type":
                                                "application/json; charset=UTF-8",
                                              },
                                              body: data);
                                          int status = response.statusCode;
                                          dynamic responseBody =
                                          jsonDecode(response.body);
                                          if (status == 200) {
                                            _teachers.clear();
                                            fetchJson().then((value) {
                                              setState(() {
                                                _teachers.addAll(value);
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
                              controller = TextEditingController(
                                  text: "12345678");
                              showDialog(
                                context: context,
                                barrierDismissible:
                                false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Reset Password"),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20)),
                                    content: TextField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        child: const Text("Reset"),
                                        onPressed: () async {
                                          var data = jsonEncode({
                                            "login": _teachers[index].login,
                                            "password": md5.convert(utf8.encode(controller.text)).toString(),
                                          });
                                          final response = await http.put(
                                              Uri.parse('http://' +
                                                  hostAndPort +
                                                  '/logins'),
                                              headers: {
                                                "Content-Type":
                                                "application/json; charset=UTF-8",
                                              },
                                              body: data);
                                          int status = response.statusCode;
                                          dynamic responseBody =
                                          jsonDecode(response.body);
                                          if (status == 200) {
                                            _teachers.clear();
                                            fetchJson().then((value) {
                                              setState(() {
                                                _teachers.addAll(value);
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
                              "assets/icons/Reset.svg",
                              color: kTextColor,
                              height: getProportionateScreenHeight(25),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              var data = jsonEncode({
                                "login": _teachers[index].login,
                                "password": "",
                              });
                              dynamic response = await http.delete(
                                Uri.parse("http://" + hostAndPort + "/logins"),
                                headers: {
                                  "Content-Type": "application/json; charset=UTF-8",
                                },
                                body: data,
                              );
                              int status = response.statusCode;
                              dynamic responseBody = jsonDecode(response.body);
                              if (status == 200) {
                                _teachers.clear();
                                fetchJson().then((value) {
                                  setState(() {
                                    _teachers.addAll(value);
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
                      )
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

class Teacher {
  int id_teacher;
  String login;
  String surname;
  String name;

  Teacher({
    @required this.id_teacher,
    @required this.login,
    @required this.surname,
    @required this.name,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
    id_teacher: json["id_teacher"],
    login: json["login"],
    surname: json["surname"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id_teacher": id_teacher,
    "login": login,
    "surname": surname,
    "name": name,
  };
}
