import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../backends/circle.dart'; // Circle クラスを提供するファイルをインポート
import '../backends/user.dart';
import '../backends/manager.dart';

class CircleMenu extends StatefulWidget {
  const CircleMenu();

  @override
  _CircleMenuState createState() => _CircleMenuState();
}

class _CircleMenuState extends State<CircleMenu> {
  late Future<List<Circle>> _circlesFuture;
  List<Circle> circles = []; // circles リストを定義

  @override
  void initState() {
    super.initState();
    _circlesFuture = Manager.getHomeCircles();
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _circlesFuture = Manager.getHomeCircles();
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
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Circle>>(
        future: _circlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Scrollbar(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildCircleAvatar(snapshot.data![index]),
                            const SizedBox(width: 8),
                            _buildUserInfo(snapshot.data![index]),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(snapshot.data![index].content),
                        _buildActions(
                            index, snapshot.data![index]), // circle パラメータを追加
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
    );
  }
}
