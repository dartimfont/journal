import 'package:flutter/material.dart';

import 'components/body.dart';

class HomeTeacherScreen extends StatelessWidget {
  static String routeName = "/home_teacher";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home for Teacher"),
      ),
      body: Body(),
    );
  }
}