import 'package:flutter/material.dart';
import 'gui/login.dart';
import 'gui/timeline.dart';
import 'backends/manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sessionToken = Manager.loadSessionToken();

    Widget home;
    if (sessionToken != null) {
      home = MyHomePage();
    } else {
      home = LoginPage();
    }

    return MaterialApp(
      title: 'Fiicener',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: home,
    );
  }
}
