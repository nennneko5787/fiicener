import "circle.dart";
import "manager.dart";
import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;

class User {
  final String userName;
  final String userHandle;
  final String userID;
  final String avatarUrl;
  final String bio;
  final List<Circle> circles;

  const User({
    required this.userName,
    required this.userHandle,
    required this.userID,
    required this.avatarUrl,
    required this.bio,
    required this.circles,
  });

  Future<List<User>> getFollowers() async {
    final followers_res = await http.get(
      Uri.parse(
          'https://fiicen.jp/account/followers/?account_id=${this.userID}'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Cookie':
            'sessionid=${await Manager.loadSessionToken()}; csrftoken=${await Manager.loadCsrfToken()};',
      },
    );

    // 抽出したい部分にマッチする正規表現
    RegExp regExp = RegExp(r'/field/([^/]+)/');

    // 結果を格納するリスト
    List<String> accountNames = [];

    // 正規表現で全てのマッチを見つける
    Iterable<Match> matches = regExp.allMatches(followers_res.body);

    Manager.res = followers_res.body;

    // 各マッチについて、キャプチャしたグループをリストに追加
    for (var match in matches) {
      accountNames.add(match.group(1)!); // マッチした部分をリストに追加
    }

    List<User> followers = [];

    for (String username in accountNames) {
      User follower = await Manager.getUserDetails(username);
      followers.add(follower);
    }

    return followers;
  }

  Future<List<User>> getFollowing() async {
    final following_res = await http.get(
      Uri.parse(
          'https://fiicen.jp/account/following/?account_id=${this.userID}'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Cookie':
            'sessionid=${await Manager.loadSessionToken()}; csrftoken=${await Manager.loadCsrfToken()};',
      },
    );

    // 抽出したい部分にマッチする正規表現
    RegExp regExp = RegExp(r'/field/([^/]+)/');

    // 結果を格納するリスト
    List<String> accountNames = [];

    // 正規表現で全てのマッチを見つける
    Iterable<Match> matches = regExp.allMatches(following_res.body);

    // 各マッチについて、キャプチャしたグループをリストに追加
    for (var match in matches) {
      accountNames.add(match.group(1)!); // マッチした部分をリストに追加
    }

    List<User> following = [];

    for (String username in accountNames) {
      User follower = await Manager.getUserDetails(username);
      following.add(follower);
    }

    return following;
  }
}
