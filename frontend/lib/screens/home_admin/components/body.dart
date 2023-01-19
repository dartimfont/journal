import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journal/constants.dart';
import 'package:journal/globals.dart';
import 'package:journal/screens/home_admin/components/discipline_list.dart';
import 'package:journal/screens/home_admin/components/student_list.dart';
import 'package:journal/size_config.dart';

import 'package:journal/components/error_message.dart';
import 'group_list.dart';
import 'package:http/http.dart' as http;

import 'globals_admin.dart' as globals_admin;

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
    DisciplineList(),
    DisciplineList(),
    //StudentList(),
  ];



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<List<Group>> fetchJsonGroups() async {
    dynamic response = await http.get(
        Uri.parse("http://" + hostAndPort + "/groups"),
        headers: {
          "accept": "application/json; charset=UTF-8",
        }
    );

    List<Group> groupList = [];
    if (response.statusCode == 200) {
      var urlJson = jsonDecode(response.body);
      for (dynamic jsonData in urlJson) {
        groupList.add(Group.fromJson(jsonData));
      }
    }
    return groupList;
  }

  void addGroup() async {
    var data = jsonEncode({
      "group": "group",
    });

    final response = await http.post(
      Uri.parse('http://' + hostAndPort + '/groups'),
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: data
    );

    int status = response.statusCode;
    dynamic responseBody = jsonDecode(response.body);
    print(response.statusCode);
    print(jsonDecode(response.body));

    if (status == 200) {
      globals_admin.groups.clear();
      fetchJsonGroups().then((value) {
        setState(() {
          globals_admin.groups.addAll(value);
        });
      });

    } else {
      buildShowDialog(context, responseBody);
    }
  }



  void addSomthing(){
    setState(() {
      if (_selectedIndex == 0) {
        print(_selectedIndex);
        addGroup();
      } else if (_selectedIndex == 1) {
        print(_selectedIndex);
      } else if (_selectedIndex == 2) {
        print(_selectedIndex);
      } else if (_selectedIndex == 3) {
        print(_selectedIndex);
      } else if (_selectedIndex == 4) {
        print(_selectedIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home for admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addSomthing,
          ),
        ],
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
              "assets/icons/achievement.svg",
              color: kTextColor,
              height: getProportionateScreenHeight(25),
            ),
            label: "Teachers",
            backgroundColor: kPrimaryColor,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/achievement.svg",
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


    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () async {
    //       if (_selectedIndex == 0) {
    //         // add new group
    //         var data = jsonEncode({
    //           "group": "group",
    //         });
    //         final response =
    //             await http.post(Uri.parse('http://' + hostAndPort + '/groups'),
    //                 headers: <String, String>{
    //                   "Content-Type": "application/json; charset=UTF-8",
    //                 },
    //                 body: data);
    //
    //         print(response.statusCode);
    //         print(response.body);
    //
    //         if (response.statusCode == 200) {
    //           setState(() {
    //
    //           });
    //         } else {
    //
    //         }
    //       } else if (_selectedIndex == 1) {
    //         // add new discipline
    //       } else if (_selectedIndex == 2) {
    //         // add new student
    //       } else if (_selectedIndex == 3) {
    //         // add new teacher
    //       } else if (_selectedIndex == 4) {
    //         // add new schedule
    //       }
    //     },
    //     backgroundColor: kPrimaryColor,
    //     child: SvgPicture.asset(
    //       "assets/icons/Plus Icon.svg",
    //       color: kTextColor,
    //       height: getProportionateScreenHeight(25),
    //     ),
    //   ),
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
