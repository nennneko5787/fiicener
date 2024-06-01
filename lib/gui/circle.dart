import 'package:flutter/material.dart';
import '../backends/circle.dart'; // Circle クラスを提供するファイルをインポート
import 'profile.dart';

class CircleDetailPage extends StatelessWidget {
  final Circle circle;

  const CircleDetailPage({Key? key, required this.circle}) : super(key: key);

  void _onCommentButtonPressed() {
    print("comment pressed");
  }

  void _onLikeButtonPressed() {
    print("like pressed");
  }

  void _onRetweetButtonPressed() {
    print("refly pressed");
  }

  Widget _buildCircleAvatar(BuildContext context, Circle circle) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(user: circle.user)),
      ),
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

  Widget _buildActions(Circle circle) {
    return FutureBuilder(
      future: Future.wait([
        circle.getReplysCount(),
        circle.getReflyUsersCount(),
        circle.getLikedUsersCount()
      ]),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: const [
              CircularProgressIndicator(),
            ],
          );
        } else if (snapshot.hasError) {
          return Row(
            children: [
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: () {},
              ),
              const Text("Error"),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.repeat),
                onPressed: () {},
              ),
              const Text("Error"),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () {},
              ),
              const Text("Error"),
            ],
          );
        } else {
          return Row(
            children: [
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: () => _onCommentButtonPressed(),
              ),
              Text(snapshot.data![0].toString()),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.repeat),
                onPressed: () => _onRetweetButtonPressed(),
              ),
              Text(snapshot.data![1].toString()),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () => _onLikeButtonPressed(),
              ),
              Text(snapshot.data![2].toString()),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('サークル'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCircleAvatar(context, circle),
                const SizedBox(width: 8),
                _buildUserInfo(circle),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              circle.content,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            const SizedBox(height: 8),
            Text(circle.content),
            _buildActions(circle),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              height: 2,
            ),
          ],
        ),
      ),
    );
  }
}
