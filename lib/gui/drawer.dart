import 'package:flutter/material.dart';
import '../backends/manager.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu();

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(Manager.me.userName),
            accountEmail: Text(Manager.me.userHandle),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  NetworkImage(Manager.me.avatarUrl), // ユーザーのアバター画像のURL
            ),
          ),
          ListTile(
            title: const Text('プロフィール'),
            onTap: () {
              // サイドメニューアイテム1がタップされたときの処理
            },
          ),
          Divider(
            color: Colors.grey, // 区切り線の色を設定します
            thickness: 1, // 区切り線の太さを設定します
            height: 20, // 区切り線の上下の余白を設定します
          ),
          ListTile(
            title: const Text('設定', style: TextStyle(fontSize: 13)),
            onTap: () {
              // サイドメニューアイテム2がタップされたときの処理
            },
          ),
          ListTile(
            title: const Text('ログアウト', style: TextStyle(fontSize: 13)),
            onTap: () {
              Manager.saveSessionToken(null);
              Manager.saveCsrfToken(null);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
