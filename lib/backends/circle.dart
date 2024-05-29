import "user.dart";

class Circle {
  final User user;
  final String content;
	final String? attachment;
  final List<Circle> replys;
  final List<User> reflyusers;
  final List<User> likedusers;

  const Circle({
    required this.user,
    required this.content,
    required this.replys,
    required this.reflyusers,
    required this.likedusers,
		this.attachment,
  });
}
