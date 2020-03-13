import 'package:flutter/material.dart';
import 'package:odysee/models/user.dart';
import 'package:odysee/screens/classification/classification.dart';
import 'package:odysee/screens/home/home.dart';
import 'package:odysee/services/auth.dart';
import 'package:odysee/wrapper.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
          value: AuthService().user,
          child: MaterialApp(
        home: Wrapper()
        ),
    );
  }

  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //       home: Home()
  //       );
  // }

}
