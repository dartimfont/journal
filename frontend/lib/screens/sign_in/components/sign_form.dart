import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import 'package:journal/components/custom_suffix_icon.dart';
import 'package:journal/components/default_button.dart';
import 'package:journal/components/form_error.dart';
import 'package:journal/constants.dart';
import 'package:journal/screens/forgot_password/forgot_password_screen.dart';
import 'package:journal/screens/home_admin/home_admin.dart';
import 'package:journal/screens/home_teacher/home_teacher.dart';
import 'package:journal/size_config.dart';

import 'package:http/http.dart' as http;

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  String login;
  String password;
  bool remember = false;
  final List<String> errors = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildLoginFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    remember = value;
                  });
                },
              ),
              Text("Remember me"),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, ForgotPasswordScreen.routeName),
                child: Text(
                  "Forgot Password",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(30)),
          DefaultButton(
            text: "Continue",
            press: () async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                var data = jsonEncode({
                  "login": login,
                  "password": md5.convert(utf8.encode(password)).toString(),
                });
                final response = await http.post(
                    Uri.parse('http://' + hostAndPort + '/login'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: data
                );
                int status = response.statusCode;
                dynamic responseBody = jsonDecode(response.body);
                print(response.statusCode);
                print(jsonDecode(response.body));
                if (status == 200) {
                  if (responseBody["role"] == "admin") {
                    Navigator.pushNamed(context, HomeAdminScreen.routeName);
                  } else if (responseBody["role"] == "teacher") {
                    Navigator.pushNamed(context, HomeTeacherScreen.routeName);
                  }
                } else if (status == 403) {
                  print(responseBody["error"]);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text(
                          "Error!",
                          textAlign: TextAlign.center,
                        ),
                        content: Text(
                          responseBody["error"],
                          textAlign: TextAlign.center,
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(kPasswordNullError)) {
          setState(() {
            errors.remove(kPasswordNullError);
          });
        }
        else if (value.isEmpty && errors.contains(kShortPasswordError)) {
          setState(() {
            errors.remove(kShortPasswordError);
          });
        }
        else if (value.length >= 8 && errors.contains(kShortPasswordError)) {
          setState(() {
            errors.remove(kShortPasswordError);
          });
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !errors.contains(kPasswordNullError)) {
          setState(() {
            errors.add(kPasswordNullError);
          });
          return "";
        }
        else if (value.isNotEmpty && value.length < 8 && !errors.contains(kShortPasswordError)) {
          setState(() {
            errors.add(kShortPasswordError);
          });
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your Password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildLoginFormField() {
    return TextFormField(
      onSaved: (newValue) => login = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(kLoginNullError)) {
          setState(() {
            errors.remove(kLoginNullError);
          });
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !errors.contains(kLoginNullError)) {
          setState(() {
            errors.add(kLoginNullError);
          });
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Login",
        hintText: "Enter your login",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Login.svg"),
      ),
    );
  }
}