import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journal/components/error_message.dart';
import 'package:journal/constants.dart';

import 'package:http/http.dart' as http;
import 'package:journal/screens/edit_schedule/edit_schedule.dart';

import 'globals_admin.dart' as globals_admin;
import 'package:journal/size_config.dart';

class ScheduleList extends StatefulWidget {
  @override
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  final List<Schedule> _schedules = [];

  Future<List<Schedule>> fetchJson() async {
    dynamic response = await http
        .get(Uri.parse("http://" + hostAndPort + "/schedules"), headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    });
    List<Schedule> scheduleList = [];
    if (response.statusCode == 200) {
      var urlJson = jsonDecode(response.body);
      for (dynamic jsonData in urlJson) {
        print(jsonData);
        scheduleList.add(Schedule.fromJson(jsonData));
      }
    }
    return scheduleList;
  }

  @override
  void initState() {
    fetchJson().then((value) {
      setState(() {
        _schedules.addAll(value);
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
            SizedBox(width: SizeConfig.screenWidth * 0.02),
            Expanded(
              child: Text(
                "Schedules",
                style: TextStyle(fontSize: 22),
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                "assets/icons/Plus Icon.svg",
                color: kTextColor,
                height: getProportionateScreenHeight(22),
              ),
              onPressed: () {
                Navigator.pushNamed(context, EditScheduleScreen.routeName);
              },
            ),
            SizedBox(width: SizeConfig.screenWidth * 0.02),
          ],
        ),
        Row(
            children: [
              SizedBox(width: SizeConfig.screenWidth * 0.02),
              Expanded(
                child: Text(
                  "Teacher",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.02),
              Expanded(
                child: Text(
                  "Group",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.02),
              Expanded(
                child: Text(
                  "Discipline",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.25),
            ]
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _schedules.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // globals_admin.selectedIndexInDisciplines = index;
                    // globals_admin.id_discipline = _disciplines[index].id_discipline;
                    // globals_admin.discipline = _disciplines[index].discipline;
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
                      SizedBox(width: SizeConfig.screenWidth * 0.02),
                      Expanded(
                          child: Text(
                            _schedules[index].surname + " " +
                            _schedules[index].name,
                        style: TextStyle(fontSize: 20),
                      )),
                      SizedBox(width: SizeConfig.screenWidth * 0.02),
                      Expanded(
                          child: Text(
                            _schedules[index].group,
                            style: TextStyle(fontSize: 20),
                          )),
                      SizedBox(width: SizeConfig.screenWidth * 0.02),
                      Expanded(
                          child: Text(
                              _schedules[index].discipline,
                            style: TextStyle(fontSize: 20),
                          )),

                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, EditScheduleScreen.routeName);
                        },
                        icon: SvgPicture.asset(
                          "assets/icons/Edit.svg",
                          color: kTextColor,
                          height: getProportionateScreenHeight(20),
                        ),
                      ),
                      IconButton(
                        onPressed: () {

                        },
                        icon: SvgPicture.asset(
                          "assets/icons/Trash.svg",
                          color: kTextColor,
                          height: getProportionateScreenHeight(20),
                        ),
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.02),
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

class Schedule {
  int id_schedule;
  String surname;
  String name;
  String group;
  String discipline;
  Schedule({
    @required this.id_schedule,
    @required this.surname,
    @required this.name,
    @required this.group,
    @required this.discipline,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    id_schedule: json["id_schedule"],
    surname: json["surname"],
    name: json["name"],
    group: json["group"],
    discipline: json["discipline"],
      );

  Map<String, dynamic> toJson() => {
        "id_schedule": id_schedule,
        "surname": surname,
        "name": name,
        "group": group,
        "discipline": discipline,
      };
}
