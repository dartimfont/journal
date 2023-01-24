import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:journal/constants.dart';
import 'package:journal/size_config.dart';

import 'globals_teacher.dart' as globals_teacher;

class GroupList extends StatefulWidget {
  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final List<Group> _groups = [];

  Future<List<Group>> fetchJson() async {
    print(globals_teacher.login);
    var data = jsonEncode({
      "login": globals_teacher.login,
      "password": "",
    });
    dynamic response = await http.post(
      Uri.parse("http://" + hostAndPort + "/groups_get_for_teacher"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: data,
    );

    List<Group> groupList = [];
    if (response.statusCode == 200) {
      var urlJson = jsonDecode(utf8.decode(response.bodyBytes));
      for (dynamic jsonData in urlJson) {
        groupList.add(Group.fromJson(jsonData));
      }
    }
    return groupList;
  }

  @override
  void initState() {
    fetchJson().then((value) {
      setState(() {
        _groups.addAll(value);
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
              "Groups",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(width: SizeConfig.screenWidth * 0.04),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _groups.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    globals_teacher.selectedIndexInGroups = index;
                    globals_teacher.id_group = _groups[index].id_group;
                    globals_teacher.group = _groups[index].group;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: index == globals_teacher.selectedIndexInGroups
                      ? Colors.black12
                      : Colors.white60,
                  child: Row(
                    children: [
                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                      Expanded(
                        child: Text(
                          _groups[index].group.toString(),
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
