import 'package:flutter/material.dart';
import 'package:journal/constants.dart';
import 'package:journal/screens/home_guest/home_guest.dart';
import 'package:journal/size_config.dart';

import 'sign_form.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.04),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: getProportionateScreenWidth(46),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Sign in with your email and password \nor continue as guest",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.08),
                SignForm(),
                SizedBox(height: getProportionateScreenHeight(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Your student? ",
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(24),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, HomeGuestScreen.routeName),
                      child: Text(
                        "Login as guest",
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(24),
                          color: kPrimaryColor,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}