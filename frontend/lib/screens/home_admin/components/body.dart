import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journal/constants.dart';
import 'package:journal/size_config.dart';

import 'group_list.dart';
import 'discipline_list.dart';
import 'student_list.dart';
import 'teacher_list.dart';
import 'schedule_list.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int _selectedIndex = 0;
  List<Widget> pageList = [
    GroupList(),
    DisciplineList(),
    StudentList(),
    TeacherList(),
    ScheduleList(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home for admin"),
      ),
      body: pageList.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/group.svg",
              color: kTextColor,
              height: getProportionateScreenHeight(25),
            ),
            label: "Groups",
            backgroundColor: kPrimaryColor,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/discipline.svg",
              color: kTextColor,
              height: getProportionateScreenHeight(25),
            ),
            label: "Disciplines",
            backgroundColor: kPrimaryColor,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/student.svg",
              color: kTextColor,
              height: getProportionateScreenHeight(25),
            ),
            label: "Students",
            backgroundColor: kPrimaryColor,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/Teacher.svg",
              color: kTextColor,
              height: getProportionateScreenHeight(25),
            ),
            label: "Teachers",
            backgroundColor: kPrimaryColor,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/Schedule.svg",
              color: kTextColor,
              height: getProportionateScreenHeight(25),
            ),
            label: "Schedules",
            backgroundColor: kPrimaryColor,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kTextColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
