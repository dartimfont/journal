import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journal/constants.dart';
import 'package:journal/size_config.dart';

import 'group_list.dart';
import 'discipline_list.dart';
import 'student_list.dart';
import 'achievement_list.dart';

import 'globals_student.dart' as globals_student;

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  dynamic onSelect = GroupList();


  void _onItemTapped(int index) {
    setState(() {
      globals_student.page_index = index;
      if (globals_student.page_index == 0) {
        onSelect = GroupList();
      } else if (globals_student.page_index == 1) {
        onSelect = DisciplineList();
      } else if (globals_student.page_index == 2) {
        onSelect = StudentList();
      } else if (globals_student.page_index == 3) {
        onSelect = AchievementList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: onSelect,
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
              "assets/icons/achievement.svg",
              color: kTextColor,
              height: getProportionateScreenHeight(25),
            ),
            label: "Achieves",
            backgroundColor: kPrimaryColor,
          ),
        ],
        currentIndex: globals_student.page_index,
        selectedItemColor: kTextColor,
        onTap: _onItemTapped,
      ),

    );
  }
}