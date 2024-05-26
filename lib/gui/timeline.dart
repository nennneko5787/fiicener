import 'package:flutter/material.dart';
import 'drawer.dart';
import 'circles.dart';
import 'footer.dart'; // Footer ウィジェットを提供するファイルをインポート
import 'appbar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMenu(),
      drawer: DrawerMenu(),
      body: CircleMenu(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ボタンが押された時の処理
        },
        tooltip: 'サークルを飛ばす',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
