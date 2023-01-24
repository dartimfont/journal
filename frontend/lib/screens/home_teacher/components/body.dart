import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journal/constants.dart';
import 'package:journal/size_config.dart';

import 'group_list.dart';
import 'discipline_list.dart';
import 'lab_list.dart';
import 'achivement_table.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int _selectedIndex = 0;
  dynamic onSelect = GroupList();


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        onSelect = GroupList();
      } else if (_selectedIndex == 1) {
        onSelect = DisciplineList();
      } else if (_selectedIndex == 2) {
        onSelect = LabList();
      } else if (_selectedIndex == 3) {
        onSelect = AchievementTable();
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
              "assets/icons/Lab.svg",
              color: kTextColor,
              height: getProportionateScreenHeight(25),
            ),
            label: "Labs",
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
        currentIndex: _selectedIndex,
        selectedItemColor: kTextColor,
        onTap: _onItemTapped,
      ),

    );
  }
}