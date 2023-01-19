import 'package:flutter/material.dart';

import 'components/group_list_admin.dart';
import 'package:go_router/go_router.dart';

class Demo {
  final String name;
  final String route;
  final WidgetBuilder builder;

  const Demo({
    @required this.name,
    @required this.route,
    @required this.builder,
  });
}

final basicDemos = [
  Demo(
      name: "Groups",
      route: GroupListAdmin.routeName,
      builder: (context) => GroupListAdmin()),
  Demo(
      name: "Disciplines",
      route: GroupListAdmin.routeName,
      builder: (context) => GroupListAdmin()),
  Demo(
      name: "Teachers",
      route: GroupListAdmin.routeName,
      builder: (context) => GroupListAdmin()),
];

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeAdminTestScreen(),
      routes: [
        for (final demo in basicDemos)
          GoRoute(
            path: demo.route,
            builder: (context, state) => demo.builder(context),
          )
      ],
    ),
  ],
);

class HomeAdminTestScreen extends StatelessWidget {
  static String routeName = "/home_admin_test";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home for admin (test)"),
      ),
      body: ListView(
        children: [
          ...basicDemos.map((d) => DemoTile(demo: d)),
        ],
      ),
    );
  }
}

class DemoTile extends StatelessWidget {
  final Demo demo;

  const DemoTile({@required this.demo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(demo.name),
      onTap: () {
        context.go('/${demo.route}');
      },
    );
  }
}
