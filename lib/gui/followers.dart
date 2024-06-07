import 'package:flutter/material.dart';
import '../backends/user.dart';
import 'profile.dart';

class FollowersPage extends StatelessWidget {
  final Future<List<User>> followersFuture;

  const FollowersPage({super.key, required this.followersFuture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォロワー'),
      ),
      body: FutureBuilder<List<User>>(
        future: followersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No followers found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              User user = snapshot.data![index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(user: user)),
                  );
                },
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                title: Text(user.userName),
                subtitle: Text(user.userHandle),
              );
            },
          );
        },
      ),
    );
  }
}
