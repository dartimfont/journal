import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:journal/constants.dart';
import 'package:journal/size_config.dart';

import 'package:http/http.dart' as http;

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class _BodyState extends State<Body> {
  final List<Group> _groups = [];

  String dropdownValue = list.first;

  Future<List<Group>> fetchGroups() async {
    dynamic response = await http
        .get(Uri.parse("http://" + hostAndPort + "/groups"), headers: {
      "accept": "application/json; charset=UTF-8",
    });

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
    _groups.clear();
    fetchGroups().then((value) {
      setState(() {
        _groups.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit schedule"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: SizeConfig.screenWidth * 0.04),
              Text(
                "Choose teacher",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.04),
            ],
          ),
          DropdownButton(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String value) {
              setState(() {
                dropdownValue = value;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: SizeConfig.screenWidth * 0.04),
              Text(
                "Choose group",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.04),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: SizeConfig.screenWidth * 0.04),
              Text(
                "Choose discipline",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.04),
            ],
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: SizeConfig.screenWidth * 0.04),
              ElevatedButton(
                child: Text('Back'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.14),
              ElevatedButton(
                child: Text('Send'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.04),
            ],
          ),
        ],
      ),
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
