import 'package:flutter/material.dart';
import 'gui/drawer.dart';
import 'gui/circles.dart';
import 'gui/footer.dart'; // Footer ウィジェットを提供するファイルをインポート

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiicener',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Fiicener'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/images/fiicen.png",
          height: 40,
        ),
        centerTitle: true,
      ),
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
