import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../backends/circle.dart'; // Circle クラスを提供するファイルをインポート
import '../backends/manager.dart';
import '../backends/user.dart';
import 'profile.dart';

class CircleMenu extends StatefulWidget {
  const CircleMenu();

  @override
  _CircleMenuState createState() => _CircleMenuState();
}

class _CircleMenuState extends State<CircleMenu> {
  late Future<List<Circle>> _circlesFuture;
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
      await _circlesFuture;
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
                onPressed: () => _onCommentButtonPressed(circle.id),
              ),
              Text(snapshot.data![0].toString()),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.repeat),
                onPressed: () => _onRetweetButtonPressed(circle.id),
              ),
              Text(snapshot.data![1].toString()),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () => _onLikeButtonPressed(circle.id),
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
    return _isLoading
        ? const Center(
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
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No circles available'),
                  );
                } else {
                  final circles = snapshot.data!;
                  return Scrollbar(
                    child: ListView.builder(
                      itemCount: circles.length,
                      itemBuilder: (context, index) {
                        final circle = circles[index];
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildCircleAvatar(circle),
                                  const SizedBox(width: 8),
                                  _buildUserInfo(circle),
                                ],
                              ),
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
