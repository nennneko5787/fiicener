import 'package:flutter/material.dart';
import '../backends/user.dart';
import '../backends/textagent.dart';
import 'followers.dart';
import 'following.dart';

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

  @override
  void initState() {
    super.initState();
    _followersCountFuture = widget.user.getFollowersCount();
    _followingCountFuture = widget.user.getFollowingCount();
    _followersFuture = widget.user.getFollowers();
    _followingFuture = widget.user.getFollowing();
  }

  Widget _buildUserInfo(User user) {
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
        Text.rich(TextAgent.generate(user.bio)),
      ],
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
              _buildUserInfo(user),
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
            ],
          ),
        ),
      ),
    );
  }
}
