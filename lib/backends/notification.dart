import "circle.dart";
import "user.dart";

enum NotificationTypes{
  none,
  follow,
  like,
  reply,
  refly,
  mention
  ;
  
  const NotificationTypes();
}

class Notification {
  final NotificationTypes type;
  final User actionUser;
  final Circle? targetCircle;
  final String time;
  bool isRead = false;

  Notification({
    required this.type,
    required this.actionUser,
    required this.targetCircle,
    required this.time,
    required this.isRead,
  });
}