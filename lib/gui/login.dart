import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as html;
import '../backends/manager.dart';
import 'appbar.dart';
import 'timeline.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Manager.init();
  }

  Future<void> login() async {
    final response = await Manager.dio.get(
      '/login/',
      options: Options(headers: {'Content-Type': 'text/html'}),
    );

    // レスポンスヘッダーからset-cookieヘッダーを取得
    String? setCookieHeader = response.headers.map['set-cookie']?.join(';');
    if (setCookieHeader != null) {
      // set-cookieヘッダーを';'で分割して、csrftokenを含む行を検索
      List<String> cookies = setCookieHeader.split(';');
      String csrfToken = "";
      for (String cookie in cookies) {
        if (cookie.startsWith('csrftoken=')) {
          // csrftokenの値を取得
          csrfToken = cookie.split('=')[1];
          await Manager.saveCsrfToken(csrfToken);
          break;
        }
      }

      String username = _usernameController.text;
      String password = _passwordController.text;

      // HTMLを解析
      var document = htmlParser.parse(response.data);

      // input要素を検索
      var inputElement =
          document.querySelector('input[name="csrfmiddlewaretoken"]');

      String middleToken = "";
      // input要素が見つかった場合は、その値を返す
      if (inputElement != null) {
        middleToken = inputElement.attributes['value'] ?? '';
      }

      var loginRes = await Manager.dio.post(
        '/login/',
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'Fiicener/1.00',
          },
          followRedirects: false,
        ),
        data: {
          "csrfmiddlewaretoken": middleToken,
          "account_name": username,
          "password": password,
        },
      );

      if (loginRes.statusCode == 302) {
        // レスポンスヘッダーからset-cookieヘッダーを取得
        String? setCookieHeader = loginRes.headers.map['set-cookie']?.join(';');
        if (setCookieHeader != null) {
          // set-cookieヘッダーを';'で分割して、sessionidを含む行を検索
          List<String> cookies = setCookieHeader.split(';');
          String sessionid = "";
          for (String cookie in cookies) {
            if (cookie.startsWith('sessionid=')) {
              // sessionidの値を取得
              sessionid = cookie.split('=')[1];
              break;
            }
          }

          await Manager.saveSessionToken(sessionid);
          await Manager.initialize();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('エラー！'),
                content: Text('セッションIDの取得に失敗しました。'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('エラー！'),
              content: Text('ログインに失敗しました。'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('エラー'),
            content: Text('トークンの取得に失敗しました。'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMenu(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: AutofillGroup(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'アカウント名',
                ),
                autofillHints: const [AutofillHints.username],
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'パスワード',
                ),
                autofillHints: const [AutofillHints.password],
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: login, // Pass the function without calling it
                child: Text('ログイン'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
