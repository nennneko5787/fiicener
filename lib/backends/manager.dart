import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'user.dart';
import 'circle.dart';
import 'notification.dart';
import 'network.dart';
import 'dart:convert';

class Manager {
  static const storage = FlutterSecureStorage();
  static User me = User(
    userName: '',
    userHandle: '',
    userID: '',
    avatarUrl: '',
    bio: "",
    isFollowing: false,
    isMuted: false,
  );

  static Future<void> saveSessionToken(String? token) async {
    await storage.write(key: 'session', value: token);
  }

  static Future<String?> loadSessionToken() async {
    return await storage.read(key: 'session');
  }

  static Future<void> saveCsrfToken(String? token) async {
    await storage.write(key: 'csrf', value: token);
  }

  static Future<String?> loadCsrfToken() async {
    return await storage.read(key: 'csrf');
  }

  static Future<bool> isLoggedIn() async {
    final sessionToken = await Manager.loadSessionToken();
    return sessionToken != null;
  }

  static Future<String?> getUserId() async {
    final homeres = await HttpWrapper.get(
      Uri.parse('https://fiicen.jp/home/'),
    );

    RegExp regExp = RegExp(r"loadPage\('\/field\/(.*?)\/'\)");
    Match? match = regExp.firstMatch(homeres.body);

    String userId = "";
    if (match != null) {
      userId = match.group(1) ?? '';
    }

    return userId;
  }

  static Future<User> getUserDetails(String userId) async {
    if (userId == "") {
      return User(
        userName: "ユーザーの取得に失敗しました。",
        userHandle: "",
        userID: "",
        avatarUrl: "",
        bio: "ユーザーの取得に失敗しました。",
        isFollowing: false,
        isMuted: false,
      );
    }
    final response = await HttpWrapper.get(
      Uri.parse('https://fiicen.jp/field/$userId/'),
    );

    RegExp regExp =
        RegExp(r"openModal\('/account/followers/\?account_id=(\d+)'");
    Match? match = regExp.firstMatch(response.body);

    String accountNum = "";
    if (match != null) {
      accountNum = match.group(1) ?? '';
    }

    var document = htmlParser.parse(response.body);

    var iconElement = document.querySelector('img[class="account-icon-80"]');
    String iconurl = "";
    if (iconElement != null) {
      iconurl = iconElement.attributes['src'] ?? '';
      iconurl = 'https://fiicen.jp$iconurl';
    }

    var dElement = document.querySelector('div[class="display-name"]');
    String displayName = dElement?.text ?? '';

    var aElement = document.querySelector('div[class="account-name"]');
    String accountName = aElement?.text ?? '';

    var iElement = document.querySelector('div[class="introduce"]');
    String introduce = iElement?.text ?? '';

    bool isFollowing = false;
    dom.Element? isfol = document.querySelector(".do-follow");
    if (isfol?.attributes["style"] == "display: none;") {
      isFollowing = true;
    }

    bool isMuted = false;
    if (response.body.contains('<div style="color: var(--sub-letter-color)">このアカウントをミュートしています。')){
      isMuted = true;
    }

    return User(
      userName: displayName,
      userHandle: accountName,
      userID: accountNum,
      avatarUrl: iconurl,
      bio: introduce,
      isFollowing: isFollowing,
      isMuted: isMuted,
    );
  }

  static Future<Circle?> parseCircle(dom.Element circle) async {
    List<String> classList = circle.classes.toList();
    String circleId = '';

    for (var className in classList) {
      RegExp regExp = RegExp(r'circle_(.*)');
      var match = regExp.firstMatch(className);
      if (match != null) {
        circleId = match.group(1)!;
        break;
      }
    }
    if (circleId == "") {
      RegExp regExp = RegExp(r"openSlidePanel('/circle/(.*)')");
      var match = regExp.firstMatch(circle.outerHtml);
      if (match != null) {
        circleId = match.group(1)!;
      }
    }

    String? accountName = circle.querySelector('.account-name')?.text.trim();
    if (accountName != null) {
      accountName = accountName.replaceAll('@', ''); // Remove '@'
    }else{
      return null;
    }
    User user = await getUserDetails(accountName);

    String? textContent = circle
        .querySelector('.circle-content > div:not(.reply-to)')
        ?.text
        .trim();
    textContent ??= circle
      .querySelector('.replyed-circle-contents')
      ?.text
      .trim();
    textContent ??= '';


    String? imageUrlRaw = circle.querySelector('.attached-image')?.attributes['src'];
    String imageUrl = imageUrlRaw != null ? 'https://fiicen.jp$imageUrlRaw' : '';

    String? videoPoster = circle.querySelector('.attached-video')?.attributes['poster'];
    if (videoPoster != null) {
      videoPoster = 'https://fiicen.jp$videoPoster';
    }
    String? videoUrl = videoPoster != null ? 'https://fiicen.jp/media/attached_video/$circleId.mp4' : '';

    String? replyedTo;
    String? replyHTML = circle.querySelector('.circle-content')?.querySelector('.reply-to')?.innerHtml;
    if (replyHTML != null) {
      RegExp regExp = RegExp(r'\/field\/(.*?)\/');
      var match = regExp.firstMatch(replyHTML);
      replyedTo = match != null ? match.group(1)! : '';
    }

    String? reflewName;
    String? reflewNameHTML = circle.querySelector('.reflew-display-name')?.innerHtml;
    if (reflewNameHTML != null) {
      RegExp regExp = RegExp(r'\/field\/(.*?)\/');
      var match = regExp.firstMatch(reflewNameHTML);
      reflewName = match != null ? match.group(1)! : '';
    }

    bool liked = circle.innerHtml.contains("/static/icon/liked.svg");
    bool reflown = circle.innerHtml.contains("reflown");

    return Circle(
      id: circleId,
      user: user,
      content: textContent,
      imageUrl: imageUrl,
      videoPoster: videoPoster,
      videoUrl: videoUrl,
      replyed_to: replyedTo,
      reflew_name: reflewName,
      liked: liked,
      reflown: reflown,
    );
  }

  static Future<List<Circle>> getHomeCircles({int page = 1}) async {
    final response = await HttpWrapper.get(
      Uri.parse('https://fiicen.jp/circle/block/home/$page/'),
    );

    var document = htmlParser.parse(response.body);
    List<dom.Element> circles = document.querySelectorAll('.circle');

    List<Circle> circleslist = [];

    // Asynchronously parse each circle
    for (var circle in circles) {
      Circle? parsedCircle = await parseCircle(circle);
      if (parsedCircle != null) {
        circleslist.add(parsedCircle);
      }
    }

    return circleslist;
  }


  static Future<int> getNotificationCount() async {
    final res = await HttpWrapper.get(
      Uri.parse('https://fiicen.jp/notification/count/'),
    );

    Map<String, dynamic> jsonMap = jsonDecode(res.body);
    return jsonMap["count"];
  }

  static Future<List<Notification>> getNotifinations() async {
    final response = await HttpWrapper.get(
      Uri.parse('https://fiicen.jp/notification/'),
    );

    List<Notification> notifyList = [];

    // HTMLをパースする
    var document = htmlParser.parse(response.body);

    // サークル要素をすべて取得する
    List<dom.Element> notifications = document.querySelectorAll('.notification-item');

    // 各サークルの情報を抽出する
    for (dom.Element notify in notifications) {
      // クラスリストを取得
      List<String> classList = notify.classes.toList();

      bool isRead = false;

      // 各クラス名をチェック
      for (var className in classList) {
        // 正規表現でマッチ
        if (className.contains("notification-is-read-False")) {
          isRead = true;
          break;
        }
      }

      // アカウント名
      String? accountHandleRaw = notify.querySelector('.account-name')?.attributes["onclick"];
      RegExp regExp = RegExp(r"loadPage\('\/field\/(.*?)\/'\)");
      Match? match = regExp.firstMatch('$accountHandleRaw');

      String userId = "";
      if (match != null) {
        userId = match.group(1) ?? '';
      }

      NotificationTypes type = NotificationTypes.none;
      Circle? targetCircle;

      dom.Element? itemImage = document.querySelector('.notification-item-image');
      String? notificationTypeIconHtml = itemImage?.innerHtml;
      String? notificationTypeIcon = itemImage?.attributes["src"];

      if (notificationTypeIcon != null) {
        switch(notificationTypeIcon) {
          case '/static/icon/liked.svg':
            type = NotificationTypes.like;
            break;
          case '/static/icon/reply.svg':
            type = NotificationTypes.reply;
            break;
          case '/static/icon/reflown.svg':
            type = NotificationTypes.refly;
            break;
          case '/static/icon/follow.svg':
            type = NotificationTypes.follow;
            break;
          default:
            type = NotificationTypes.none;
            break;
        }

        if (type == NotificationTypes.none) {
          if (notificationTypeIconHtml != null) {
            if (notificationTypeIconHtml.contains("@")) {
              type = NotificationTypes.mention;
            }
          }
        }
      }

      notifyList.add(Notification(
          type: NotificationTypes.like,
          actionUser: await Manager.getUserDetails(userId),
          targetCircle: targetCircle,
          time: "0分",
          isRead: isRead,
        ));
    }
    return notifyList;
  }

  static Future<bool> initialize() async {
    bool isLoggedIn = await Manager.isLoggedIn();
    if (isLoggedIn) {
      String? userId = await getUserId();
      if (userId != null) {
        me = await getUserDetails(userId);
      }
    }
    return isLoggedIn;
  }
}
