import 'package:flutter/material.dart';

import 'components/body.dart';

class HomeGuestScreen extends StatelessWidget {
  static String routeName = "/home_guest";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Body(),
    );
  }
}