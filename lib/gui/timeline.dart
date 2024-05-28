import 'package:flutter/material.dart';
import 'drawer.dart';
import 'circles.dart';
import 'footer.dart'; // Footer ウィジェットを提供するファイルをインポート
import 'appbar.dart';
import 'post.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StatefulWidget body = CircleMenu();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMenu(),
      drawer: DrawerMenu(),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostMenu()),
          );
        },
        tooltip: 'サークルを飛ばす',
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
