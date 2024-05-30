import 'package:flutter/material.dart';
import '../backends/user.dart';
import '../backends/manager.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<List<User>> _followersFuture;
  late Future<List<User>> _followingFuture;

  @override
  void initState() {
    super.initState();
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
        Text(user.bio),
      ],
    );
  }

  Widget _buildFollowList(List<User> users) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(users[index].avatarUrl),
          ),
          title: Text(users[index].userName),
          subtitle: Text(users[index].userHandle),
        );
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
              _buildUserInfo(user),
              const SizedBox(height: 20),
              FutureBuilder<List<User>>(
                future: _followersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No followers found'));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Followers',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      _buildFollowList(snapshot.data!),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<User>>(
                future: _followingFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No following found'));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Following',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      _buildFollowList(snapshot.data!),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
