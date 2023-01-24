import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:journal/components/default_button.dart';
import 'package:journal/constants.dart';
import 'package:journal/size_config.dart';
import 'package:journal/components/message.dart';

import 'package:http/http.dart' as http;
import 'package:journal/screens/home_admin/components/globals_admin.dart'
    as globals_admin;

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final List<Teacher> _teachers = [];
  final List<Group> _groups = [];
  final List<Discipline> _disciplines = [];

  Teacher selectedTeacher;
  Group selectedGroup;
  Discipline selectedDiscipline;

  Future<List<Teacher>> fetchTeachers() async {
    dynamic response = await http.get(
      Uri.parse("http://" + hostAndPort + "/teachers"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    int status = response.statusCode;
    dynamic responseBody = jsonDecode(utf8.decode(response.bodyBytes));
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

  Future<List<Group>> fetchGroups() async {
    dynamic response = await http
        .get(Uri.parse("http://" + hostAndPort + "/groups"), headers: {
      "accept": "application/json; charset=UTF-8",
    });

    List<Group> groupList = [];
    if (response.statusCode == 200) {
      var urlJson = jsonDecode(utf8.decode(response.bodyBytes));
      for (dynamic jsonData in urlJson) {
        groupList.add(Group.fromJson(jsonData));
      }
    }
    return groupList;
  }

  Future<List<Discipline>> fetchDiscipline() async {
    dynamic response = await http
        .get(Uri.parse("http://" + hostAndPort + "/disciplines"), headers: {
      'accept': 'application/json; charset=UTF-8',
    });

    print(utf8.decode(response.bodyBytes));

    List<Discipline> disciplineList = [];
    if (response.statusCode == 200) {
      var urlJson = jsonDecode(utf8.decode(response.bodyBytes));
      for (dynamic jsonData in urlJson) {
        print(jsonData);
        disciplineList.add(Discipline.fromJson(jsonData));
      }
    }
    return disciplineList;
  }

  @override
  void initState() {
    _teachers.clear();
    _groups.clear();
    _disciplines.clear();
    fetchTeachers().then((value) {
      setState(() {
        _teachers.addAll(value);
      });
    });
    fetchGroups().then((value) {
      setState(() {
        _groups.addAll(value);
      });
    });
    fetchDiscipline().then((value) {
      setState(() {
        _disciplines.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: globals_admin.add_schedule
            ? Text("Add schedule")
            : Text("Edit schedule " + globals_admin.id_schedule.toString()),
      ),
      body: Column(
        children: [
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: SizeConfig.screenWidth * 0.04),
              Text(
                "Choose teacher",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.04),
            ],
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          DropdownButton<Teacher>(
            hint: Text("Choose"),
            value: selectedTeacher,
            icon: Icon(Icons.check_circle_outline),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: kPrimaryColor),
            underline: Container(
              height: 2,
              color: kPrimaryColor,
            ),
            onChanged: (Teacher value) {
              setState(() {
                selectedTeacher = value;
              });
            },
            items: _teachers.map<DropdownMenuItem<Teacher>>((Teacher value) {
              return DropdownMenuItem<Teacher>(
                value: value,
                child: Text(value.surname + " " + value.name),
              );
            }).toList(),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: SizeConfig.screenWidth * 0.04),
              Text(
                "Choose group",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.04),
            ],
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          DropdownButton<Group>(
            hint: Text("Choose"),
            value: selectedGroup,
            icon: Icon(Icons.check_circle_outline),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: kPrimaryColor),
            underline: Container(
              height: 2,
              color: kPrimaryColor,
            ),
            onChanged: (Group value) {
              setState(() {
                selectedGroup = value;
              });
            },
            items: _groups.map<DropdownMenuItem<Group>>((Group value) {
              return DropdownMenuItem<Group>(
                value: value,
                child: Text(value.group),
              );
            }).toList(),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: SizeConfig.screenWidth * 0.04),
              Text(
                "Choose discipline",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.04),
            ],
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          DropdownButton<Discipline>(
            hint: Text("Choose"),
            value: selectedDiscipline,
            icon: Icon(Icons.check_circle_outline),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: kPrimaryColor),
            underline: Container(
              height: 2,
              color: kPrimaryColor,
            ),
            onChanged: (Discipline value) {
              setState(() {
                selectedDiscipline = value;
              });
            },
            items: _disciplines
                .map<DropdownMenuItem<Discipline>>((Discipline value) {
              return DropdownMenuItem<Discipline>(
                value: value,
                child: Text(value.discipline),
              );
            }).toList(),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: SizeConfig.screenWidth * 0.04),
              ElevatedButton(
                child: Text("Back"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.2),
              ElevatedButton(
                child: Text("Send"),
                onPressed: () async {
                  if (globals_admin.add_schedule) {
                    print("Add");
                    var data = jsonEncode({
                      "id_schedule": -1,
                      "id_teacher": selectedTeacher.id_teacher,
                      "id_group": selectedGroup.id_group,
                      "id_discipline": selectedDiscipline.id_discipline,
                    });
                    dynamic response = await http.post(
                      Uri.parse("http://" + hostAndPort + "/schedules"),
                      headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                      },
                      body: data,
                    );
                    int status = response.statusCode;
                    dynamic responseBody = jsonDecode(utf8.decode(response.bodyBytes));
                    print(status);
                    print(responseBody["message"]);
                    if (status == 200) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: Text(
                              "Success!",
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              responseBody["message"].toString(),
                              textAlign: TextAlign.center,
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: Text(
                              "Error!",
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              responseBody["error"],
                              textAlign: TextAlign.center,
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    print("Edit");
                    var data = jsonEncode({
                      "id_schedule": globals_admin.id_schedule,
                      "id_teacher": selectedTeacher.id_teacher,
                      "id_group": selectedGroup.id_group,
                      "id_discipline": selectedDiscipline.id_discipline,
                    });
                    dynamic response = await http.put(
                      Uri.parse("http://" + hostAndPort + "/schedules"),
                      headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                      },
                      body: data,
                    );
                    int status = response.statusCode;
                    dynamic responseBody = jsonDecode(utf8.decode(response.bodyBytes));
                    print(status);
                    print(responseBody["message"]);
                    if (status == 200) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: Text(
                              "Success!",
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              responseBody["message"],
                              textAlign: TextAlign.center,
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: Text(
                              "Error!",
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              responseBody["error"],
                              textAlign: TextAlign.center,
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.04),
            ],
          ),
        ],
      ),
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

class Group {
  int id_group;
  String group;
  Group({
    @required this.id_group,
    @required this.group,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id_group: json["id_group"],
        group: json["group"],
      );

  Map<String, dynamic> toJson() => {
        "id_group": id_group,
        "group": group,
      };
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
