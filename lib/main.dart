import 'package:flutter/material.dart';
import 'gui/login.dart';
import 'gui/timeline.dart';
import 'backends/manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Manager.initialize(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        // データの読み込み中はローディングなどの表示を行う
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // エラーが発生した場合の処理
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('エラーが発生しました'),
              ),
            ),
          );
        } else {
          // データの読み込みが完了した場合の処理
          bool isLoggedIn = snapshot.data ?? false;
          Widget home;
          if (!isLoggedIn) {
            home = LoginPage();
          } else {
            home = MyHomePage();
          }
          return MaterialApp(
            title: 'Fiicener',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: home,
          );
        }
      },
    );
  }
}
