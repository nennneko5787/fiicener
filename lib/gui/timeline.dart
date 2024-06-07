import 'package:flutter/material.dart';
import 'drawer.dart';
import 'circles.dart';
import 'footer.dart'; // Footer ウィジェットを提供するファイルをインポート
import 'appbar.dart';
import 'post.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StatefulWidget body = const CircleMenu();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarMenu(),
      drawer: const DrawerMenu(),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostMenu()),
          );
        },
        tooltip: 'サークルを飛ばす',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
