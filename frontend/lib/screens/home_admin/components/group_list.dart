import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import 'package:journal/components/message.dart';
import 'package:journal/constants.dart';

import 'globals_admin.dart' as globals_admin;
import 'package:journal/size_config.dart';

class GroupList extends StatefulWidget {
  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final List<Group> _groups = [];
  TextEditingController controller;

  Future<List<Group>> fetchJson() async {
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
            Expanded(
              child: Text(
                "Groups",
                style: TextStyle(fontSize: 24),
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                "assets/icons/Plus Icon.svg",
                color: kTextColor,
                height: getProportionateScreenHeight(25),
              ),
              onPressed: () async {
                var data = jsonEncode({"group": "group"});
                dynamic response = await http.post(
                  Uri.parse("http://" + hostAndPort + "/groups"),
                  headers: {
                    "Content-Type": "application/json; charset=UTF-8",
                  },
                  body: data,
                );
                int status = response.statusCode;
                dynamic responseBody = jsonDecode(response.body);
                if (response.statusCode == 200) {
                  _groups.clear();
                  fetchJson().then((value) {
                    setState(() {
                      _groups.addAll(value);
                    });
                  });
                } else {
                  buildShowDialog(context, responseBody);
                }
              },
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
                      globals_admin.selectedIndexInGroups = index;
                      globals_admin.id_group = _groups[index].id_group;
                      globals_admin.group = _groups[index].group;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    color: index == globals_admin.selectedIndexInGroups
                        ? Colors.black12
                        : Colors.white60,
                    child: Row(children: [
                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                      Expanded(
                        child: Text(
                          _groups[index].group.toString(),
                          style: TextStyle(
                              fontSize: getProportionateScreenHeight(24)),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          controller =
                              TextEditingController(text: _groups[index].group);
                          showDialog(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Rename group"),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                content: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    child: const Text('Approve'),
                                    onPressed: () async {
                                      var data = jsonEncode({
                                        "id_group": _groups[index].id_group,
                                        "group": controller.text,
                                      });

                                      final response = await http.put(
                                          Uri.parse('http://' +
                                              hostAndPort +
                                              '/groups'),
                                          headers: <String, String>{
                                            "Content-Type":
                                                "application/json; charset=UTF-8",
                                          },
                                          body: data);

                                      int status = response.statusCode;
                                      dynamic responseBody =
                                          jsonDecode(response.body);
                                      print(response.statusCode);
                                      print(jsonDecode(response.body));

                                      if (status == 200) {
                                        _groups.clear();
                                        fetchJson().then((value) {
                                          setState(() {
                                            _groups.addAll(value);
                                          });
                                        });
                                      } else {

                                      }
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
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
                            "group": _groups[index].group,
                          });
                          dynamic response = await http.delete(
                            Uri.parse("http://" + hostAndPort + "/groups"),
                            headers: {
                              "Content-Type": "application/json; charset=UTF-8",
                            },
                            body: data,
                          );
                          int status = response.statusCode;
                          dynamic responseBody = jsonDecode(response.body);
                          if (response.statusCode == 200) {
                            _groups.clear();
                            fetchJson().then((value) {
                              setState(() {
                                _groups.addAll(value);
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
                    ]),
                  ));
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
