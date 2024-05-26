import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'appbar.dart';
import '../backends/manager.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as html;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    final response = await http.get(
      Uri.parse('https://fiicen.jp/login/'),
      headers: {
        'Content-Type': 'text/html',
      },
    );

    // レスポンスヘッダーからset-cookieヘッダーを取得
    String? setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader != null) {
      // set-cookieヘッダーを';'で分割して、csrftokenを含む行を検索
      List<String> cookies = setCookieHeader.split(';');
      for (String cookie in cookies) {
        if (cookie.trim().startsWith('csrftoken=')) {
          // csrftokenの値を取得
          String csrfToken = cookie.split('=')[1].trim();
          print('csrftoken: $csrfToken');
          break;
        }
      }

      String username = _usernameController.text;
      String password = _passwordController.text;

      // HTMLを解析
      var document = htmlParser.parse(response.body);

      // input要素を検索
      var inputElement =
          document.querySelector('input[name="csrfmiddlewaretoken"]');

      var middletoken = "";
      // input要素が見つかった場合は、その値を返す
      if (inputElement != null) {
        middletoken = inputElement.attributes['value'] ?? '';
      }

      var loginres =
          await http.post(Uri.parse('https://fiicen.jp/login/'), headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      }, body: {
        "csrfmiddlewaretoken": middletoken,
        "account_name": username,
        "password": password,
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('HTTP Res: ${loginres.statusCode}'),
            content: Text('${loginres.body}'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'アカウント名',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'パスワード',
              ),
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
    );
  }
}
