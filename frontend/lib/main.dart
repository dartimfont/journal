import 'package:flutter/material.dart';
import 'package:journal/routes.dart';
import 'package:journal/screens/sign_in/sign_in_screen.dart';
import 'package:journal/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Demo",
      theme: theme(),
      initialRoute: SignInScreen.routeName,
      routes: routes,
    );
  }
}