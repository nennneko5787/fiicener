import 'package:flutter/material.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu();

  @override
  _DrawerMenu createState() => _DrawerMenu();
}

class _DrawerMenu extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("ねんねこ"),
            accountEmail: Text("@nennneko5787"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://cdn.discordapp.com/avatars/1048448686914551879/a4093ba46ee42126de6df6d250891e9e.png?size=1024'), // ユーザーのアバター画像のURL
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
              // サイドメニューアイテム2がタップされたときの処理
            },
          ),
        ],
      ),
    );
  }
}
