import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:journal/constants.dart';

import 'package:journal/globals.dart' as globals;

class StudentList extends StatefulWidget {
  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  final List<Student> _students = [];

  Future<List<Student>> fetchJson() async {
    dynamic params = jsonEncode({
      "group": globals.group
    });
    dynamic response = await http.post(
        Uri.parse("http://" + hostAndPort + "/students_get"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: params
    );

    List<Student> slist = [];
    if (response.statusCode == 200) {
      var urjson = jsonDecode(response.body);
      for (dynamic jsondata in urjson) {
        slist.add(Student.fromJson(jsondata));
      }
    }
    return slist;
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
    return ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                globals.selectedIndexInStudents = index;
                globals.id_student = _students[index].id_student;
                globals.surname = _students[index].surname;
                globals.name = _students[index].name;

                print(globals.id_student);
                print(globals.surname);
                print(globals.name);
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.symmetric(vertical: 8),
              color: index == globals.selectedIndexInStudents ? Colors.black12: Colors.white60,
              child: Text(
                  _students[index].surname + " " + _students[index].name,
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
            ),
          );
        }
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