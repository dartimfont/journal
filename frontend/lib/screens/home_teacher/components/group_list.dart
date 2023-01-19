import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:journal/constants.dart';

import 'package:journal/globals.dart' as globals;

class GroupList extends StatefulWidget {
  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final List<Group> _groups = [];

  Future<List<Group>> fetchJson() async {
    dynamic response = await http.get(
        Uri.parse("http://" + hostAndPort + "/groups"),
        headers: {
          'accept': 'application/json; charset=UTF-8',
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
    return ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                globals.selectedIndexInGroups = index;
                globals.id_group = _groups[index].id_group;
                globals.group = _groups[index].group;

                print(globals.id_group);
                print(globals.group);
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.symmetric(vertical: 8),
              color: index == globals.selectedIndexInGroups ? Colors.black12: Colors.white60,
              child: Text(
                _groups[index].group.toString(),
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
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