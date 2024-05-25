import 'package:flutter/material.dart';

class Footer extends StatefulWidget {
  const Footer();

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type:
          BottomNavigationBarType.fixed, // or BottomNavigationBarType.shifting
      items: const [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'ホーム', // 'title' is deprecated, use 'label'
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: '探す',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.notifications),
          label: '通知',
        ),
      ],
    );
  }
}
