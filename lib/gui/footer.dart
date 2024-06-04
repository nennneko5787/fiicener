import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import '../backends/manager.dart';

class Footer extends StatefulWidget {
  static GlobalKey<_FooterState> footerKey = GlobalKey<_FooterState>();

  const Footer();

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    // initStateメソッド内で非同期処理を実行することが推奨されます
    // バージョンをチェックし、カウントを取得する処理を行います
    fetchNotificationCount();
  }

  // カウントを取得する非同期関数
  Future<void> fetchNotificationCount() async {
    int cnt = await Manager.getNotificationCount();
    setState(() {
      notificationCount = cnt;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type:
          BottomNavigationBarType.fixed, // or BottomNavigationBarType.shifting
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'ホーム', // 'title' is deprecated, use 'label'
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: '探す',
        ),
        BottomNavigationBarItem(
          icon: notificationCount > 0
              ? badges.Badge(
                  // notificationCountが0より大きい場合のみバッジを表示
                  badgeContent: Text('$notificationCount'),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Colors.blue,
                  ),
                  child: const Icon(Icons.notifications),
                )
              : Icon(Icons.notifications),
          label: '通知',
        ),
      ],
    );
  }
}
