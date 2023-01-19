import 'package:flutter/material.dart';

import 'components/body.dart';

class HomeAdminScreen extends StatelessWidget {
  static String routeName = "/home_admin";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}