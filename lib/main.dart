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
          return MaterialApp(
            // MaterialAppでローディング時の背景色を設定する
            theme: ThemeData(
              // 通常のテーマ
              primarySwatch: Colors.blue,
              // ローディング時の背景色
              scaffoldBackgroundColor: Colors.blue.shade50, // 例えば薄い青色
            ),
            darkTheme: ThemeData(
              // ダークモードのテーマ
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(
                primary: Colors.deepPurple,
              ),
              // ローディング時のダークモードの背景色
              scaffoldBackgroundColor: Colors.deepPurple.shade800, // 例えば濃い紫色
            ),
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      "assets/images/fiicen.png",
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // データの読み込みが完了した場合の処理
          if (snapshot.hasError) {
            // エラーが発生した場合の処理
            return const Center(child: Text('エラーが発生しました'));
          } else {
            // ログイン状態に応じて表示するページを決定する
            bool isLoggedIn = snapshot.data!;
            Widget home;
            if (!isLoggedIn) {
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
