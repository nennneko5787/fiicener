import 'package:flutter/material.dart';
import '../backends/user.dart';
import '../backends/circle.dart'; // Circle クラスを提供するファイルをインポート
import '../backends/textagent.dart';
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
        body: Scrollbar(
          child: Row(children: [
            Padding(
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
                  Text.rich(TextAgent.generate(circle.content)),
                  circle.imageUrl != null
                      ? FittedBox(
                          child: Image.network('${circle.imageUrl}'),
                          fit: BoxFit.contain,
                        )
                      : SizedBox(),
                  circle.videoPoster != null
                      ? FittedBox(
                          child: Image.network('${circle.videoPoster}'),
                          fit: BoxFit.contain,
                        )
                      : SizedBox(),
                  _buildActions(circle),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 2,
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Circle>>(
              future: circle.getReplys(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView(); // Empty ListView to show refresh indicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox();
                } else {
                  final circles = snapshot.data!;
                  return Scrollbar(
                    child: ListView.builder(
                      itemCount: circles.length,
                      itemBuilder: (context, index) {
                        final c = circles[index];
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildCircleAvatar(context, c),
                                  const SizedBox(width: 8),
                                  _buildUserInfo(c),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text.rich(TextAgent.generate(circle.content)),
                              _buildActions(c),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1,
                                height: 2,
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CircleDetailPage(circle: c)),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ]),
        ));
  }
}
