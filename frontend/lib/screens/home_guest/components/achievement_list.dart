import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:journal/constants.dart';

class AchievementList extends StatefulWidget {
  @override
  _AchievementListState createState() => _AchievementListState();
}

class _AchievementListState extends State<AchievementList> {
  final List<Group> _achievements = [];

  Future<List<Group>> fetchJson() async {
    dynamic response = await http.get(
        Uri.parse("http://" + hostAndPort + "/groups"),
        headers: {
          'accept': 'application/json; charset=UTF-8',
        }
    );

    List<Group> glist = [];
    if (response.statusCode == 200) {
      var urjson = jsonDecode(response.body);
      for (dynamic jsondata in urjson) {
        glist.add(Group.fromJson(jsondata));
      }
    }
    return glist;
  }

  @override
  void initState() {
    fetchJson().then((value) {
      setState(() {
        _achievements.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _achievements.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                Text(_achievements[index].group.toString()),
              ],
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