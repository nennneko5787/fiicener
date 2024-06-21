import 'package:flutter/material.dart';
import 'gui/login.dart';
import 'gui/timeline.dart';
import 'backends/manager.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Manager.initialize(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // データの読み込み中はローディングなどの表示を行う
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasError) {
            // エラーが発生した場合の処理
            return const Center(child: Text('エラーが発生しました'));
          } else {
            // データの読み込みが完了した場合の処理
            bool isloggedin = snapshot.data!;
            Widget home;
            if (!isloggedin) {
              home = const LoginPage();
            } else {
              home = const MyHomePage();
            }
            return MaterialApp(
              title: 'Fiicener',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: const ColorScheme.dark(
                  primary: Colors.deepPurple,
                ),
              ),
              home: home,
            );
          }
        }
      },
    );
  }
}
