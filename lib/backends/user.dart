import "circle.dart";

class User {
  final String userName;
  final String userHandle;
  final String avatarUrl;
  final String bio;
  final List<Circle> circles;
  final List<User> followers;
  final List<User> following;

  const User({
    required this.userName,
    required this.userHandle,
    required this.avatarUrl,
    required this.bio,
    required this.circles,
    required this.followers,
    required this.following,
  });
}
