import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:journal/components/error_message.dart';
import 'package:journal/constants.dart';
import 'package:journal/size_config.dart';

import 'globals_teacher.dart' as globals_teacher;

class StudentList extends StatefulWidget {
  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  final List<Student> _students = [];

  Future<List<Student>> fetchJson() async {
    dynamic params = jsonEncode({"group": globals_teacher.group});
    dynamic response =
        await http.post(Uri.parse("http://" + hostAndPort + "/students_get"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: params);
    int status = response.statusCode;
    dynamic responseBody = jsonDecode(response.body);
    List<Student> studentList = [];
    if (status == 200) {
      var urlJson = responseBody;
      for (dynamic jsonData in urlJson) {
        studentList.add(Student.fromJson(jsonData));
      }
    } else {
      buildShowDialog(context, responseBody);
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
            Text(
              "Students",
              style: TextStyle(fontSize: 24),
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
                    globals_teacher.selectedIndexInStudents = index;
                    globals_teacher.id_student = _students[index].id_student;
                    globals_teacher.surname = _students[index].surname;
                    globals_teacher.name = _students[index].name;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: index == globals_teacher.selectedIndexInStudents
                      ? Colors.black12
                      : Colors.white60,
                  child: Row(
                    children: [
                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                      Expanded(
                        child: Text(
                          _students[index].surname +
                              " " +
                              _students[index].name,
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
