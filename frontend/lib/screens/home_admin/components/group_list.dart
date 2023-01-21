import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import 'package:journal/components/error_message.dart';
import 'package:journal/screens/home_admin/components/text_dialog_group.dart';
import 'package:journal/constants.dart';

import 'package:journal/globals.dart' as globals;
import 'globals_admin.dart' as globals_admin;
import 'package:journal/size_config.dart';

class GroupList extends StatefulWidget {
  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {

  Future<List<Group>> fetchJson() async {
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


  @override
  void initState() {
    globals_admin.groups.clear();
    fetchJson().then((value) {
      setState(() {
        globals_admin.groups.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: globals_admin.groups.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                globals.selectedIndexInGroups = index;
                globals.id_group = globals_admin.groups[index].id_group;
                globals.group = globals_admin.groups[index].group;

                print(globals.id_group);
                print(globals.group);
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.symmetric(vertical: 8),
              color: index == globals.selectedIndexInGroups ? Colors.black12: Colors.white60,
              child: Row(
                children: [
                  SizedBox(width: SizeConfig.screenWidth * 0.04),
                  Expanded(
                    child: Text(
                      globals_admin.groups[index].group.toString(),
                      style: TextStyle(fontSize: getProportionateScreenHeight(24)),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      print(globals_admin.groups[index].group);
                      final group = await showTextDialog(
                        context,
                        title: "Change Group",
                        id_group: globals_admin.groups[index].id_group,
                        group: globals_admin.groups[index].group,
                      );

                     // print(globals_admin.groups[index].group);
                      globals_admin.groups.clear();
                      fetchJson().then((value) {
                        setState(() {
                          globals_admin.groups.addAll(value);
                        });
                      });
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/Edit.svg",
                      color: kTextColor,
                      height: getProportionateScreenHeight(25),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      var data = jsonEncode({
                        "group": globals_admin.groups[index].group,
                      });
                      final response = await http.delete(
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
                        // success
                        globals_admin.groups.clear();
                        fetchJson().then((value) {
                          setState(() {
                            globals_admin.groups.addAll(value);
                          });
                        });
                      } else {
                        buildShowDialog(context, responseBody);
                      }
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/Trash.svg",
                      color: kTextColor,
                      height: getProportionateScreenHeight(25),
                    ),
                  ),
                  SizedBox(width: SizeConfig.screenWidth * 0.04),
                ]
              ),
            )
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