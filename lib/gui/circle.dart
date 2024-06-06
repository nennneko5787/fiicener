import 'package:flutter/material.dart';
import '../backends/user.dart';
import '../backends/circle.dart'; // Circle クラスを提供するファイルをインポート
import '../backends/textagent.dart';
import '../backends/circle_gui_helper.dart';
import 'profile.dart';

class CircleDetailPage extends StatefulWidget {
  final Circle circle;

  const CircleDetailPage({Key? key, required this.circle}) : super(key: key);

  @override
  _CircleDetailPageState createState() => _CircleDetailPageState();
}

class _CircleDetailPageState extends State<CircleDetailPage> {
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
                icon: const Icon(Icons.comment_outlined),
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
                icon: const Icon(Icons.favorite_outline),
                onPressed: () {},
              ),
              const Text("Error"),
            ],
          );
        } else {
          return Row(
            children: [
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: () {},
              ),
              Text(snapshot.data![0].toString()),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.repeat),
                color: circle.reflown ? Colors.green : Colors.grey,
                onPressed: () async {
                  bool reflown = await circle.refly();
                  if (reflown) {
                    setState(() {});
                  }
                },
              ),
              Text(snapshot.data![1].toString()),
              const SizedBox(width: 16),
              IconButton(
                color: circle.liked ? Colors.pink : Colors.grey,
                icon: circle.liked ? const Icon(Icons.favorite) : const Icon(Icons.favorite_outline),
                onPressed: () async {
                  bool liked = await circle.like();
                  if (liked) {
                    setState(() {});
                  }
                },
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCircleAvatar(context, widget.circle),
                      const SizedBox(width: 8),
                      _buildUserInfo(widget.circle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text.rich(TextAgent.generate(widget.circle.content)),
                  widget.circle.imageUrl != null
                      ? GestureDetector(
                          onTap: () {
                            CircleGuiHelper.showPreviewImage(context, image: widget.circle.imageUrl);
                          },
                          child: FittedBox(
                            child: Image.network('${widget.circle.imageUrl}'),
                            fit: BoxFit.contain,
                          ),
                        )
                      : SizedBox(),
                  widget.circle.videoPoster != null
                      ? FittedBox(
                          child: Image.network('${widget.circle.videoPoster}'),
                          fit: BoxFit.contain,
                        )
                      : SizedBox(),
                  _buildActions(widget.circle),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 2,
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Circle>>(
              future: widget.circle.getReplys(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox();
                } else {
                  final circles = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: circles.length,
                    itemBuilder: (context, index) {
                      final c = circles[index];
                      return Transform.scale(
                        scale: 0.8,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          minVerticalPadding: 8.0 * 0.2,
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
                              Text.rich(TextAgent.generate(c.content), context),
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
                              builder: (context) => CircleDetailPage(circle: c),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}