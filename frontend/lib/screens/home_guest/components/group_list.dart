import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:journal/components/message.dart';
import 'package:journal/constants.dart';

import 'globals_student.dart' as globals_student;
import 'package:journal/size_config.dart';

class GroupList extends StatefulWidget {
  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final List<Group> _groups = [];

  Future<List<Group>> fetchJson() async {
    dynamic response = await http
        .get(Uri.parse("http://" + hostAndPort + "/groups"), headers: {
      "accept": "application/json; charset=UTF-8",
    });
    int status = response.statusCode;
    dynamic responseBody = jsonDecode(response.body);

    List<Group> groupList = [];
    if (status == 200) {
      var urlJson = responseBody;
      for (dynamic jsonData in urlJson) {
        groupList.add(Group.fromJson(jsonData));
      }
    } else {
      print(responseBody["error"]);
      buildShowDialog(context, responseBody);
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
                        globals_student.selectedIndexInGroups = index;
                        globals_student.id_group = _groups[index].id_group;
                        globals_student.group = _groups[index].group;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      color: index == globals_student.selectedIndexInGroups
                          ? Colors.black12
                          : Colors.white60,
                      child: Row(children: [
                        SizedBox(width: SizeConfig.screenWidth * 0.04),
                        Expanded(
                            child: Text(
                          _groups[index].group.toString(),
                          style: TextStyle(fontSize: 24),
                        )),
                        SizedBox(width: SizeConfig.screenWidth * 0.04),
                      ]),
                    ),
                  );
                })),
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
