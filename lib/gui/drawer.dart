import 'package:flutter/material.dart';
import '../backends/manager.dart';
import 'login.dart';
import 'profile.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  int followingCount = 0;
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final following = await Manager.me.getFollowingCount();
    final followers = await Manager.me.getFollowersCount();
    setState(() {
      followingCount = following;
      followersCount = followers;
    });
  }

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
            otherAccountsPictures: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'フォロー中: $followingCount',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'フォロワー: $followersCount',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          ListTile(
            title: const Text('プロフィール'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(user: Manager.me)),
              );
            },
          ),
          const Divider(
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
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
