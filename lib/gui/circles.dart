import 'package:flutter/material.dart';
import '../backends/circle.dart'; // Circle クラスを提供するファイルをインポート
import '../backends/user.dart';
import '../backends/manager.dart';

class CircleMenu extends StatefulWidget {
  const CircleMenu();

  @override
  _CircleMenuState createState() => _CircleMenuState();
}

class _CircleMenuState extends State<CircleMenu> {
  final List<Circle> circles = [
    Circle(
      user: User(
          userName: 'ねんねこ',
          userHandle: '@nennneko5787',
          avatarUrl:
              'https://cdn.discordapp.com/avatars/1048448686914551879/a4093ba46ee42126de6df6d250891e9e.png?size=1024',
          bio: "test",
          circles: [],
          followers: [],
          following: []),
      content: '${Manager.res}',
      replys: [],
      reflyusers: [],
      likedusers: [],
    ),
    // Add more circles here
  ];

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    setState(() {
      // Refresh the data
    });
  }

  void _onCommentButtonPressed(int index) {
    print("comment pressed");
  }

  void _onLikeButtonPressed(int index) {
    print("like pressed");
  }

  void _onRetweetButtonPressed(int index) {
    print("refly pressed");
  }

  Widget _buildCircleAvatar(Circle circle) {
    return CircleAvatar(
      backgroundImage: NetworkImage(circle.user.avatarUrl),
    );
  }

  Widget _buildUserInfo(Circle circle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          circle.user.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          circle.user.userHandle,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActions(int index) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.comment),
          onPressed: () => _onCommentButtonPressed(index),
        ),
        Text(circles[index].replys.length.toString()),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.repeat),
          onPressed: () => _onRetweetButtonPressed(index),
        ),
        Text(circles[index].reflyusers.length.toString()),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: () => _onLikeButtonPressed(index),
        ),
        Text(circles[index].likedusers.length.toString()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scrollbar(
        // Scrollbarの外側にListViewを配置します
        child: ListView.builder(
          scrollDirection: Axis.vertical, // 縦スクロールを設定
          itemCount: circles.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCircleAvatar(circles[index]),
                      const SizedBox(
                          width: 8), // Spacing between avatar and text
                      _buildUserInfo(circles[index]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(circles[index].content),
                  _buildActions(index),
                  Divider(
                    color: Colors.grey, // 区切り線の色を設定します
                    thickness: 1, // 区切り線の太さを設定します
                    height: 2, // 区切り線の上下の余白を設定します
                  ),
                ],
              ),
              onTap: () {
                // Handle tweet tap
              },
            );
          },
        ),
      ),
    );
  }
}
