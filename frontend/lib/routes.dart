import 'package:flutter/material.dart';
import 'package:journal/screens/forgot_password/forgot_password_screen.dart';
import 'package:journal/screens/home_admin/home_admin.dart';
import 'package:journal/screens/home_guest/home_guest.dart';
import 'package:journal/screens/sign_in/sign_in_screen.dart';

import 'screens/edit_schedule/edit_schedule.dart';
import 'screens/home_teacher/home_teacher.dart';

final Map<String, WidgetBuilder> routes = {
  SignInScreen.routeName: (context) => SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
  HomeAdminScreen.routeName: (context) => HomeAdminScreen(),
  EditScheduleScreen.routeName: (context) => EditScheduleScreen(),
  HomeTeacherScreen.routeName: (context) => HomeTeacherScreen(),
  HomeGuestScreen.routeName: (context) => HomeGuestScreen(),
};