import 'package:flutter/material.dart';
import 'package:journal/size_config.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(
            "Forgot Password",
            style: TextStyle(
              fontSize: getProportionateScreenWidth(46),
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Please enter your login",
            style: TextStyle(
              fontSize: getProportionateScreenWidth(24)
            )
          )
        ],
      ),
    );
  }
}