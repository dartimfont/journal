import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:journal/constants.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:http/http.dart' as http;
import 'globals_teacher.dart' as globals_teacher;

import 'model.dart';
import 'table_cell.dart';

class TableBody extends StatefulWidget {
  final ScrollController scrollController;


  TableBody({
    @required this.scrollController,
  });

  @override
  _TableBodyState createState() => _TableBodyState();
}

class _TableBodyState extends State<TableBody> {
  LinkedScrollControllerGroup _controllers;
  ScrollController _firstColumnController;
  ScrollController _restColumnsController;

  final List<Student> _students = [];
  final List<Lab> _labs = [];
  final List<Achieve> _achieves = [];

  Future<List<Student>> fetchStudents() async {
    dynamic params = jsonEncode({"group": globals_teacher.group});
    dynamic response =
    await http.post(Uri.parse("http://" + hostAndPort + "/students_get"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: params);
    int status = response.statusCode;
    dynamic responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    List<Student> studentList = [];
    if (status == 200) {
      var urlJson = responseBody;
      for (dynamic jsonData in urlJson) {
        studentList.add(Student.fromJson(jsonData));
      }
    }
    return studentList;
  }

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

  Future<List<Achieve>> fetchAchieves() async {
    var data = jsonEncode({
      "login": globals_teacher.login,
      "id_group": globals_teacher.id_group,
      "id_discipline": globals_teacher.id_discipline,
    });
    dynamic response = await http.post(
      Uri.parse("http://" + hostAndPort + "/selected_labs"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: data,
    );
    List<Achieve> labList = [];
    if (response.statusCode == 200) {
      var urlJson = jsonDecode(utf8.decode(response.bodyBytes));
      for (dynamic jsonData in urlJson) {
        print(jsonData);
        labList.add(Achieve.fromJson(jsonData));
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
    fetchStudents().then((value) {
      setState(() {
        _students.addAll(value);
      });
    });
    fetchAchieves().then((value) {
      setState(() {
        _achieves.addAll(value);
      });
    });

    _controllers = LinkedScrollControllerGroup();
    _firstColumnController = _controllers.addAndGet();
    _restColumnsController = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _firstColumnController.dispose();
    _restColumnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      notificationPredicate: (ScrollNotification notification) {
        return notification.depth == 0 || notification.depth == 1;
      },
      onRefresh: () async {
        _students.clear();
        _labs.clear();
        fetchLabs().then((value) {
          setState(() {
            _labs.addAll(value);
          });
        });
        fetchStudents().then((value) {
          setState(() {
            _students.addAll(value);
          });
        });
        fetchAchieves().then((value) {
          setState(() {
            _achieves.addAll(value);
          });
        });
      },
      child: Row(
        children: [
          SizedBox(
            width: cellWidth,
            child: ListView.builder(
              controller: _firstColumnController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                return Container(
                  width: cellWidth,
                  height: cellHeight,
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.3),
                    border: Border.all(
                      color: Colors.black12,
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _students[index].surname + " " +
                    _students[index].name,
                    style: TextStyle(fontSize: 16.0),
                  ),
                );
              }
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: (_labs.length) * cellWidth,
                child: ListView(
                  controller: _restColumnsController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  children: List.generate(_students.length, (y) {
                    return Row(
                      children: List.generate(_labs.length, (x) {
                        return Container(
                          width: cellWidth,
                          height: cellHeight,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black12,
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Checkbox(
                            activeColor: kPrimaryColor,
                            value: _achieves[
                              _achieves.indexWhere(
                                (el) => el.id_student == _students[y].id_student &&
                                el.id_lab == _labs[x].id_lab
                              )
                            ].achieve,
                            onChanged: (bool isMark) async {
                              _achieves[
                              _achieves.indexWhere(
                                      (el) => el.id_student == _students[y].id_student &&
                                      el.id_lab == _labs[x].id_lab
                              )
                              ].achieve = isMark;

                              var data = jsonEncode({
                                "id_student": _students[y].id_student,
                                "id_lab": _labs[x].id_lab,
                                "achieve": _achieves[
                                _achieves.indexWhere(
                                        (el) => el.id_student == _students[y].id_student &&
                                        el.id_lab == _labs[x].id_lab
                                )
                                ].achieve,
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
                                _achieves.clear();
                                fetchAchieves().then((value) {
                                  setState(() {
                                    _achieves.addAll(value);
                                  });
                                });
                              } else {}

                            }
                          )
                          // Text(
                          //   "x: " + x.toString() + ", y: " + y.toString() + "\n" +
                          //   _labs[x].id_lab.toString() + " " +
                          //   _students[y].id_student.toString(),
                          //   style: TextStyle(fontSize: 16.0),
                          // ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
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

class Achieve {
  int id_student;
  int id_lab;
  bool achieve;
  Achieve({
    @required this.id_student,
    @required this.id_lab,
    @required this.achieve,
  });

  factory Achieve.fromJson(Map<String, dynamic> json) => Achieve(
    id_student: json["id_student"],
    id_lab: json["id_lab"],
    achieve: json["achieve"],
  );

  Map<String, dynamic> toJson() => {
    "id_student": id_student,
    "id_lab": id_lab,
    "achieve": achieve,
  };
}