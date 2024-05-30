import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../backends/circle.dart'; // Circle クラスを提供するファイルをインポート
import '../backends/user.dart';
import '../backends/manager.dart';
import 'profile.dart';

class CircleMenu extends StatefulWidget {
  const CircleMenu();

  @override
  _CircleMenuState createState() => _CircleMenuState();
}

class _CircleMenuState extends State<CircleMenu> {
  late Future<List<Circle>> _circlesFuture;
  List<Circle> circles = []; // circles リストを定義
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCircles();
  }

  Future<void> _loadCircles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _circlesFuture = Manager.getHomeCircles();
      circles = await _circlesFuture;
    } catch (e) {
      // Handle errors if needed
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    await _loadCircles();
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
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePage(user: circle.user)),
        )
      },
      child: CircleAvatar(
        backgroundImage: NetworkImage(circle.user.avatarUrl),
      ),
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

  Widget _buildActions(int index, Circle circle) {
    // Circle クラスを引数として追加
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.comment),
          onPressed: () => _onCommentButtonPressed(index),
        ),
        Text(circle.replys.length
            .toString()), // circle パラメータを使用して対応するサークルの replys リストにアクセス
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.repeat),
          onPressed: () => _onRetweetButtonPressed(index),
        ),
        Text(circle.reflyusers.length
            .toString()), // circle パラメータを使用して対応するサークルの reflyusers リストにアクセス
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: () => _onLikeButtonPressed(index),
        ),
        Text(circle.likedusers.length
            .toString()), // circle パラメータを使用して対応するサークルの likedusers リストにアクセス
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Menu'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Circle>>(
                future: _circlesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView(); // Empty ListView to show refresh indicator
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    return Scrollbar(
                      child: ListView.builder(
                        itemCount: circles.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildCircleAvatar(circles[index]),
                                    const SizedBox(width: 8),
                                    _buildUserInfo(circles[index]),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(circles[index].content),
                                _buildActions(
                                    index, circles[index]), // circle パラメータを追加
                                Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  height: 2,
                                ),
                              ],
                            ),
                            onTap: () {},
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }
}
