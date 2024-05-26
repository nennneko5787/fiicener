import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'user.dart';

class Manager {
  static final storage = FlutterSecureStorage();
  static User me = User(
      userName: '',
      userHandle: '',
      avatarUrl: '',
      bio: "",
      circles: const [],
      followers: const [],
      following: const []);

  static Future<void> saveSessionToken(String token) async {
    await storage.write(key: 'session', value: token);
  }

  static Future<String?> loadSessionToken() async {
    return await storage.read(key: 'session');
  }

  static Future<void> saveCsrfToken(String token) async {
    await storage.write(key: 'csrf', value: token);
  }

  static Future<String?> loadCsrfToken() async {
    return await storage.read(key: 'csrf');
  }

  static Future<bool> isLoggedIn() async {
    final sessionToken = await Manager.loadSessionToken();
    return sessionToken != null;
  }

  static Future getMeDetailed() async {
    final response = await http.get(
      Uri.parse('https://fiicen.jp/login/'),
      headers: {
        'Content-Type': 'text/html',
        'Cookie':
            'csrftoken=${loadCsrfToken()};sessionid=${loadSessionToken()}',
      },
    );

    // HTMLを解析
    var document = htmlParser.parse(response.body);
    // <img class="account-icon-80" src="/media/account_icon/3747.jpg" onclick="detailImage('/media/account_icon/3747.jpg/', 'account_icon')">
    var iconElement = document.querySelector('img[class="account-icon-80"]');
    String iconurl = "";
    // input要素が見つかった場合は、その値を返す
    if (iconElement != null) {
      iconurl = iconElement.attributes['src'] ?? '';
    }

    var dElement = document.querySelector('div[class="display-name"]');
    String display_name = "";
    // input要素が見つかった場合は、その値を返す
    if (dElement != null) {
      display_name = dElement.text ?? '';
    }

    var aElement = document.querySelector('div[class="account-name"]');
    String account_name = "";
    // input要素が見つかった場合は、その値を返す
    if (aElement != null) {
      account_name = aElement.text ?? '';
    }

    var iElement = document.querySelector('div[class="introduce"]');
    String introduce = "";
    // input要素が見つかった場合は、その値を返す
    if (iElement != null) {
      introduce = iElement.text ?? '';
    }

    me = User(
        userName: display_name,
        userHandle: account_name,
        avatarUrl: iconurl,
        bio: introduce,
        circles: const [],
        followers: const [],
        following: const []);
  }

  static Future<bool> initialize() async {
    bool isloggedin = await isLoggedIn();
    if (isloggedin == true) {
      await getMeDetailed();
    }
    return isloggedin;
  }
}
