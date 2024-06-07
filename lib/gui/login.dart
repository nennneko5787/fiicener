import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'appbar.dart';
import '../backends/manager.dart';
import 'package:html/parser.dart' as htmlParser;
import 'timeline.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
      String csrfToken = "";
      for (String cookie in cookies) {
        if (cookie.trim().startsWith('csrftoken=')) {
          // csrftokenの値を取得
          csrfToken = cookie.trim().split('=')[1];
          await Manager.saveCsrfToken(csrfToken);
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

      String middletoken = "";
      // input要素が見つかった場合は、その値を返す
      if (inputElement != null) {
        middletoken = inputElement.attributes['value'] ?? '';
      }

      var loginres =
          await http.post(Uri.parse('https://fiicen.jp/login/'), headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Cookie': 'csrftoken=$csrfToken;',
      }, body: {
        "csrfmiddlewaretoken": middletoken,
        "account_name": username,
        "password": password,
      });

      if (loginres.statusCode == 302) {
        // レスポンスヘッダーからset-cookieヘッダーを取得
        String? setCookieHeader = loginres.headers['set-cookie'];
        if (setCookieHeader != null) {
          // set-cookieヘッダーを';'で分割して、sessionidを含む行を検索
          List<String> cookies = setCookieHeader.split(';');
          String sessionid = "";
          for (String cookie in cookies) {
            if (cookie.trim().startsWith('sessionid=')) {
              // sessionidの値を取得
              sessionid = cookie.trim().split('=')[1];
              break;
            }
          }

          await Manager.saveSessionToken(sessionid);
          await Manager.initialize();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('エラー！'),
              content: const Text('ログインに失敗しました。'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
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
            title: const Text('エラー'),
            content: const Text('トークンの取得に失敗しました。'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
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
      appBar: const AppBarMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AutofillGroup(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'アカウント名',
                ),
                autofillHints: const [AutofillHints.username],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'パスワード',
                ),
                autofillHints: const [AutofillHints.password],
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: login, // Pass the function without calling it
                child: const Text('ログイン'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
