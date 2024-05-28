import 'package:html/parser.dart' as htmlParser;
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
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
  static final Dio dio = Dio(BaseOptions(baseUrl: 'https://fiicen.jp'));
  static final cookieJar = CookieJar();

  static Future<void> init() async {
    dio.interceptors.add(CookieManager(cookieJar));
    await _loadCookiesIntoJar();
  }

  static Future<void> _loadCookiesIntoJar() async {
    final sessionToken = await Manager.loadSessionToken();
    final csrfToken = await Manager.loadCsrfToken();
    List<Cookie> cookies = [];

    if (sessionToken != null) {
      cookies.add(Cookie('sessionid', sessionToken));
    }
    if (csrfToken != null) {
      cookies.add(Cookie('csrftoken', csrfToken));
    }

    if (cookies.isNotEmpty) {
      await Manager.cookieJar
          .saveFromResponse(Uri.parse('https://fiicen.jp'), cookies);
    }
  }

  static Future<void> saveSessionToken(String? token) async {
    await storage.write(key: 'session', value: token);
    await _loadCookiesIntoJar(); // Reload cookies into the jar
  }

  static Future<String?> loadSessionToken() async {
    return await storage.read(key: 'session');
  }

  static Future<void> saveCsrfToken(String? token) async {
    await storage.write(key: 'csrf', value: token);
    await _loadCookiesIntoJar(); // Reload cookies into the jar
  }

  static Future<String?> loadCsrfToken() async {
    return await storage.read(key: 'csrf');
  }

  static Future<bool> isLoggedIn() async {
    final sessionToken = await Manager.loadSessionToken();
    return sessionToken != null;
  }

  static Future<String?> getUserId() async {
    final response = await dio.get('/home/');
    RegExp regExp = RegExp(r"loadPage\('\/field\/(.*?)\/'\)");
    Match? match = regExp.firstMatch(response.data);

    String userId = "";
    if (match != null) {
      userId = match.group(1) ?? '';
    }
    return userId;
  }

  static Future<User> getUserDetails(String userId) async {
    final response = await dio.get('/field/$userId/');
    RegExp regExp =
        RegExp(r"openModal\('/account/followers/\?account_id=(\d+)'");
    Match? match = regExp.firstMatch(response.data);

    String accountNum = "";
    if (match != null) {
      accountNum = match.group(1) ?? '';
    }

    var document = htmlParser.parse(response.data);

    var iconElement = document.querySelector('img[class="account-icon-80"]');
    String iconUrl = "";
    if (iconElement != null) {
      iconUrl = 'https://fiicen.jp' + (iconElement.attributes['src'] ?? '');
    }

    var dElement = document.querySelector('div[class="display-name"]');
    String displayName = dElement?.text ?? '';

    var aElement = document.querySelector('div[class="account-name"]');
    String accountName = aElement?.text ?? '';

    var iElement = document.querySelector('div[class="introduce"]');
    String introduce = iElement?.text ?? '';

    final followersRes =
        await dio.get('/account/followers/?account_id=$accountNum');
    document = htmlParser.parse(followersRes.data);
    var accountNameElements = document.querySelectorAll('.account-name');
    var accountNames = accountNameElements
        .map((element) => element.text.substring(1))
        .toList();
    List<User> followers = [];

    for (String username in accountNames) {
      User follower = await getUserDetails(username);
      followers.add(follower);
    }

    final followingRes =
        await dio.get('/account/followers/?account_id=$accountNum');
    document = htmlParser.parse(followingRes.data);
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
      userName: displayName,
      userHandle: accountName,
      avatarUrl: iconUrl,
      bio: introduce,
      circles: const [],
      followers: followers,
      following: following,
    );
  }

  static Future<bool> initialize() async {
    await init(); // Add this line to ensure init() is called
    bool isLoggedIn = await Manager.isLoggedIn();
    if (isLoggedIn) {
      String? userId = await getUserId();
      if (userId != null && userId.isNotEmpty) {
        me = await getUserDetails(userId);
      }
    }
    return isLoggedIn;
  }
}
