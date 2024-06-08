import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'user.dart';
import 'circle.dart';
import 'dart:convert';

class Manager {
  static const storage = FlutterSecureStorage();
  static User me = User(
    userName: '',
    userHandle: '',
    userID: '',
    avatarUrl: '',
    bio: "",
    circles: [],
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
    String? session = await loadSessionToken();
    String? csrf = await loadCsrfToken();

    final homeres = await http.get(
      Uri.parse('https://fiicen.jp/home/'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Cookie': 'sessionid=$session; csrftoken=$csrf;',
      },
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
        circles: [],
        isFollowing: false,
        isMuted: false,
      );
    }
    final response = await http.get(
      Uri.parse('https://fiicen.jp/field/$userId/'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Cookie':
            'sessionid=${await loadSessionToken()}; csrftoken=${await loadCsrfToken()};',
      },
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
    if (response.body.contains("フォロー中")) {
      isFollowing = true;
    }

    bool isMuted = false;
    if (response.body.contains('<span class="link" onclick="mute(\'$userId\')">解除</span>')){
      isMuted = true;
    }

    return User(
      userName: displayName,
      userHandle: accountName,
      userID: accountNum,
      avatarUrl: iconurl,
      bio: introduce,
      circles: const [],
      isFollowing: isFollowing,
      isMuted: isMuted,
    );
  }

  static Future<List<Circle>> getHomeCircles({int page = 1}) async {
    String? session = await loadSessionToken();
    String? csrf = await loadCsrfToken();

    final response = await http.get(
      Uri.parse('https://fiicen.jp/circle/block/home/$page/'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Cookie': 'sessionid=$session; csrftoken=$csrf;',
      },
    );

    List<Circle> circleslist = [];

    // HTMLをパースする
    var document = htmlParser.parse(response.body);

    // サークル要素をすべて取得する
    List<dom.Element> circles = document.querySelectorAll('.circle');

    // 各サークルの情報を抽出する
    for (dom.Element circle in circles) {
      // クラスリストを取得
      List<String> classList = circle.classes.toList();

      String circleId = "";

      // 各クラス名をチェック
      for (var className in classList) {
        // 正規表現でマッチ
        RegExp regExp = RegExp(r'^circle_(.*)$');
        var match = regExp.firstMatch(className);

        // マッチした場合、(.*) の部分をリストに追加
        if (match != null) {
          circleId = match.group(1)!;
        }
      }

      // アカウント名
      String? accountName = circle.querySelector('.account-name')?.text.trim();
      if (accountName != null) {
        accountName = accountName.replaceAll('@', ''); // @を取り除く
      }

      // テキスト内容
      String? textContent = circle
          .querySelector('.circle-content > div:not(.reply-to)')
          ?.text
          .trim();
      if (textContent == null) {
        continue;
      }

      // 添付画像URL (存在する場合)
      String? imageUrlRaw =
          circle.querySelector('.attached-image')?.attributes['src'];

      String imageUrl = 'https://fiicen.jp$imageUrlRaw';

      String? videoPoster =
          circle.querySelector('.attached-video')?.attributes['poster'];
      String? videoUrl;
      if (videoPoster != null) {
        videoUrl = 'https://fiicen.jp/media/attached_video/$circleId.mp4';
      }

      String? replyedTo;
      String? replyHTML = circle.querySelector('.reply-to')?.innerHtml;
      if (replyHTML != null) {
        // 正規表現でマッチ
        RegExp regExp = RegExp(r'\/field\/(.*?)\/');
        var match = regExp.firstMatch(replyHTML);

        // マッチした場合、(.*) の部分をリストに追加
        if (match != null) {
          replyedTo = match.group(1)!;
        }
      }

      String? reflewName;
      String? reflewNameHTML =
          circle.querySelector('.reflew-display-name')?.innerHtml;
      if (reflewNameHTML != null) {
        // 正規表現でマッチ
        RegExp regExp = RegExp(r'\/field\/(.*?)\/');
        var match = regExp.firstMatch(reflewNameHTML);

        // マッチした場合、(.*) の部分をリストに追加
        if (match != null) {
          reflewName = match.group(1)!;
        }
      }

      bool liked = false;
      if (circle.innerHtml.contains("/static/icon/liked.svg")) {
        liked = true;
      }
      bool reflown = false;
      if (circle.innerHtml.contains("reflown")) {
        reflown = true;
      }

      /* サークル情報を出力
      print('ユーザー名: $username');
      print('アカウント名: $accountName');
      print('テキスト: $textContent');
      if (imageUrl != null) {
        print('画像URL: $imageUrl');
      }
      print('---');
      */
      circleslist.add(Circle(
          id: circleId,
          user: await getUserDetails("$accountName"),
          content: textContent,
          imageUrl: imageUrl,
          videoPoster: videoPoster,
          videoUrl: videoUrl,
          replyed_to: replyedTo,
          reflew_name: reflewName,
          liked: liked,
          reflown: reflown
        ));
    }
    return circleslist;
  }

  static Future<int> getNotificationCount() async {
    String? session = await loadSessionToken();
    String? csrf = await loadCsrfToken();

    final res = await http.get(
      Uri.parse('https://fiicen.jp/notification/count/'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Cookie': 'sessionid=$session; csrftoken=$csrf;',
      },
    );

    Map<String, dynamic> jsonMap = jsonDecode(res.body);
    return jsonMap["count"];
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
