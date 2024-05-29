import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'user.dart';
import 'circle.dart';

class Manager {
  static final storage = FlutterSecureStorage();
  static User me = User(
    userName: '',
    userHandle: '',
    userID: '',
    avatarUrl: '',
    bio: "",
    circles: const [],
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
        'Cookie': 'sessionid=${session}; csrftoken=${csrf};',
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
        circles: const [],
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

    String account_num = "";
    if (match != null) {
      account_num = match.group(1) ?? '';
    }

    var document = htmlParser.parse(response.body);

    var iconElement = document.querySelector('img[class="account-icon-80"]');
    String iconurl = "";
    if (iconElement != null) {
      iconurl = iconElement.attributes['src'] ?? '';
      iconurl = 'https://fiicen.jp' + iconurl;
    }

    var dElement = document.querySelector('div[class="display-name"]');
    String display_name = dElement?.text ?? '';

    var aElement = document.querySelector('div[class="account-name"]');
    String account_name = aElement?.text ?? '';

    var iElement = document.querySelector('div[class="introduce"]');
    String introduce = iElement?.text ?? '';

    return User(
      userName: display_name,
      userHandle: account_name,
      userID: account_num,
      avatarUrl: iconurl,
      bio: introduce,
      circles: const [],
    );
  }

  static Future<List<Circle>> getHomeCircles() async {
    String? session = await loadSessionToken();
    String? csrf = await loadCsrfToken();

    final response = await http.get(
      Uri.parse('https://fiicen.jp/circle/block/home/1/'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Cookie': 'sessionid=${session}; csrftoken=${csrf};',
      },
    );

    List<Circle> circleslist = [];

    // HTMLをパースする
    var document = htmlParser.parse(response.body);

    // サークル要素をすべて取得する
    List circles = document.querySelectorAll('.circle');

    // 各サークルの情報を抽出する
    for (var circle in circles) {
      // ユーザー名
      String? username =
          circle.querySelector('.circle-created-display-name')?.text.trim();

      // アカウント名
      String? accountName = circle.querySelector('.account-name')?.text.trim();
      if (accountName != null) {
        accountName = accountName.replaceAll('@', ''); // @を取り除く
      }

      // テキスト内容
      String? textContent = circle
          .querySelector('.circle-content > div:nth-child(2)')
          ?.text
          .trim();

      // 添付画像URL (存在する場合)
      String? imageUrl =
          circle.querySelector('.attached-image')?.attributes['src'];

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
        user: await getUserDetails("${accountName}"),
        content: '${textContent}',
        replys: [],
        reflyusers: [],
        likedusers: [],
      ));
    }
    return circleslist;
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
