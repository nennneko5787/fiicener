import 'package:flutter/material.dart';
import '../backends/user.dart';
import '../backends/textagent.dart';
import '../backends/circle.dart';
import '../backends/manager.dart';
import '../backends/circle_gui_helper.dart';
import 'followers.dart';
import 'following.dart';
import 'circle.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<int> _followersCountFuture;
  late Future<int> _followingCountFuture;
  late Future<List<User>> _followersFuture;
  late Future<List<User>> _followingFuture;
  late Future<List<Circle>> _circlesFuture;
  int _currentPage = 1; // 現在のページ番号

  @override
  void initState() {
    super.initState();
    _followersCountFuture = widget.user.getFollowersCount();
    _followingCountFuture = widget.user.getFollowingCount();
    _followersFuture = widget.user.getFollowers();
    _followingFuture = widget.user.getFollowing();
    _loadCircles(_currentPage);
  }

  Future<void> _loadCircles(int page) async {
    try {
      _circlesFuture = widget.user.getPostedCircles(page: page);
      await _circlesFuture;
      setState(() {});
    } catch (e) {
      // エラー処理
    }
  }

  Future<void> _loadMoreCircles() async {
    try {
      _currentPage++; // 次のページ番号を更新
      final circles = await widget.user.getPostedCircles(page: _currentPage);
      setState(() {
        _circlesFuture = _circlesFuture
            .then((existingCircles) => [...existingCircles, ...circles]);
      });
    } catch (e) {
      // エラー処理
    }
  }

  Widget _buildProfileUserInfo(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.avatarUrl),
          radius: 40,
        ),
        const SizedBox(height: 10),
        Text(
          user.userName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        Text(
          user.userHandle,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text.rich(TextAgent.generate(user.bio, context)),
      ],
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
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
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

  Widget _buildActions(Circle circle) {
    return FutureBuilder(
      future: Future.wait([
        circle.getReplysCount(),
        circle.getReflyUsersCount(),
        circle.getLikedUsersCount()
      ]),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
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
    User user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.userName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileUserInfo(user),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try{
                        bool followed = await user.follow();
                        if (followed) {
                          if (!user.isFollowing){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('フォロー解除しました。')),
                            );
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('フォローしました')),
                            );
                          }
                          setState((){});
                        }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('操作に失敗しました。')),
                            );
                        }
                      } catch (e) {
                        // エラーが発生した場合の処理
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('操作に失敗しました。')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isFollowing ? Colors.white : Colors.blue,
                    ),
                    child: Text(
                      user.isFollowing ? 'フォロー解除' : 'フォロー',
                      style: TextStyle(
                        color: user.isFollowing ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      try{
                        bool muted = await user.mute();
                        if (muted) {
                          if (!user.isMuted){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ミュートを解除しました。')),
                            );
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ミュートしました。')),
                            );
                          }
                          setState((){});
                        }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('操作に失敗しました。')),
                            );
                        }
                      } catch (e) {
                        // エラーが発生した場合の処理
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('操作に失敗しました。')),
                        );
                      }
                    },
                    icon: user.isMuted ? const Icon(Icons.volume_off) : const Icon(Icons.volume_up),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FutureBuilder<int>(
                    future: _followersCountFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else if (!snapshot.hasData) {
                        return const Text('0');
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FollowersPage(
                                  followersFuture: _followersFuture),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              snapshot.data.toString(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('フォロワー', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    },
                  ),
                  FutureBuilder<int>(
                    future: _followingCountFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else if (!snapshot.hasData) {
                        return const Text('0');
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FollowingPage(
                                  followingFuture: _followingFuture),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              snapshot.data.toString(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('フォロー中', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                    _loadMoreCircles();
                  }
                  return false;
                },
                child: FutureBuilder<List<Circle>>(
                  future: _circlesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
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
                                  circle.reflew_name != null
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Row(children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        User user = await Manager
                                                            .getUserDetails(
                                                                '${circle.reflew_name}');
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ProfilePage(
                                                                      user: user)),
                                                        );
                                                      },
                                                      child: Text(
                                                          '@${circle.reflew_name}',
                                                          style: const TextStyle(
                                                              color: Colors.lightBlue)),
                                                    ),
                                                    const Text(
                                                      ' がリポストしました',
                                                    ),
                                                  ]),
                                                  const Icon(Icons.repeat),
                                                ],
                                              ),
                                            ),
                                            const Divider(
                                              color: Colors.black,
                                              thickness: 1,
                                              height: 2,
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  Row(
                                    children: [
                                      _buildCircleAvatar(circle),
                                      const SizedBox(width: 8),
                                      _buildUserInfo(circle),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  circle.replyed_to != null
                                      ? Row(children: [
                                          const Text('返信先: '),
                                          GestureDetector(
                                            onTap: () async {
                                              User user = await Manager.getUserDetails(
                                                  '${circle.replyed_to}');
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfilePage(user: user)),
                                              );
                                            },
                                            child: Text('@${circle.replyed_to}',
                                                style:
                                                    const TextStyle(color: Colors.lightBlue)),
                                          ),
                                        ])
                                      : const SizedBox(),
                                  Text.rich(TextAgent.generate(circle.content, context)),
                                  circle.imageUrl != null
                                      ? GestureDetector(
                                          onTap: () {
                                            CircleGuiHelper.showPreviewImage(context, image: circle.imageUrl);
                                          },
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Image.network('${circle.imageUrl}'),
                                          )
                                      )
                                      : const SizedBox(),
                                  circle.videoPoster != null
                                      ? FittedBox(
                                          fit: BoxFit.contain,
                                          child: Image.network('${circle.videoPoster}'),
                                        )
                                      : const SizedBox(),
                                  _buildActions(circle),
                                  const Divider(
                                    color: Colors.black,
                                    thickness: 1,
                                    height: 2,
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CircleDetailPage(circle: circle)),
                              ),
                            );
                          },
                        )
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
