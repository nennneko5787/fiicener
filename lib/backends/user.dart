
import "circle.dart";
import "manager.dart";
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
    final followersRes = await http.get(
      Uri.parse(
          'https://fiicen.jp/account/followers/?account_id=$userID'),
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
    Iterable<Match> matches = regExp.allMatches(followersRes.body);

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

  Future<int> getFollowersCount() async {
    final followersRes = await http.get(
      Uri.parse(
          'https://fiicen.jp/account/followers/?account_id=$userID'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Cookie':
            'sessionid=${await Manager.loadSessionToken()}; csrftoken=${await Manager.loadCsrfToken()};',
      },
    );

    // 抽出したい部分にマッチする正規表現
    RegExp regExp = RegExp(r'/field/([^/]+)/');
    // 正規表現で全てのマッチを見つける
    Iterable<Match> matches = regExp.allMatches(followersRes.body);
    return matches.length;
  }

  Future<List<User>> getFollowing() async {
    final followingRes = await http.get(
      Uri.parse(
          'https://fiicen.jp/account/following/?account_id=$userID'),
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
    Iterable<Match> matches = regExp.allMatches(followingRes.body);

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

  Future<int> getFollowingCount() async {
    final followingRes = await http.get(
      Uri.parse(
          'https://fiicen.jp/account/following/?account_id=$userID'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Cookie':
            'sessionid=${await Manager.loadSessionToken()}; csrftoken=${await Manager.loadCsrfToken()};',
      },
    );

    // 抽出したい部分にマッチする正規表現
    RegExp regExp = RegExp(r'/field/([^/]+)/');
    // 正規表現で全てのマッチを見つける
    Iterable<Match> matches = regExp.allMatches(followingRes.body);
    return matches.length;
  }
}
