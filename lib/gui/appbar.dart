import 'package:flutter/material.dart';

class AppBarMenu extends StatefulWidget implements PreferredSizeWidget {
  const AppBarMenu({super.key});

  @override
  _AppBarMenu createState() => _AppBarMenu();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarMenu extends State<AppBarMenu> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset(
        "assets/images/fiicen.png",
        height: 40,
      ),
      centerTitle: true,
    );
  }
}
