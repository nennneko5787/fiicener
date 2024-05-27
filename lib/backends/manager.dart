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
  static String res = "";

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
    final homeres = await http.get(
      Uri.parse('https://fiicen.jp/home/'),
      headers: {
        'User-Agent': 'Fiicener/1.00',
        'Cookie':
            'sessionid=${await loadSessionToken()},SameSite=Lax; csrftoken=${await loadCsrfToken()}',
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
    final response = await http.get(
      Uri.parse('https://fiicen.jp/field/$userId/'),
      headers: {
        'User-Agent': 'Fiicener/1.00',
        'Cookie':
            'sessionid=${await loadSessionToken()},SameSite=Lax; csrftoken=${await loadCsrfToken()}',
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

    final followers_res = await http.get(
      Uri.parse(
          'https://fiicen.jp/account/followers/?account_id=${account_num}'),
      headers: {
        'User-Agent': 'Fiicener/1.00',
        'Cookie':
            'sessionid=${await loadSessionToken()},SameSite=Lax; csrftoken=${await loadCsrfToken()}',
      },
    );

    document = htmlParser.parse(followers_res.body);
    var accountNameElements = document.querySelectorAll('.account-name');
    var accountNames = accountNameElements
        .map((element) => element.text.substring(1))
        .toList();
    List<User> followers = [];

    for (String username in accountNames) {
      User follower = await getUserDetails(username);
      followers.add(follower);
    }

    final following_res = await http.get(
      Uri.parse(
          'https://fiicen.jp/account/followers/?account_id=${account_num}'),
      headers: {
        'User-Agent': 'Fiicener/1.00',
        'Cookie':
            'sessionid=${await loadSessionToken()},SameSite=Lax; csrftoken=${await loadCsrfToken()}',
      },
    );

    document = htmlParser.parse(following_res.body);
    accountNameElements = document.querySelectorAll('.account-name');
    accountNames = accountNameElements
        .map((element) => element.text.substring(1))
        .toList();
    List<User> following = [];

    for (String username in accountNames) {
      User follower = await getUserDetails(username);
      following.add(follower);
    }

    return User(
      userName: display_name,
      userHandle: account_name,
      avatarUrl: iconurl,
      bio: introduce,
      circles: const [],
      followers: followers,
      following: following,
    );
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
