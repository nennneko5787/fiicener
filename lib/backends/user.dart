import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
import "circle.dart";
import "manager.dart";
import 'network.dart';
import 'dart:convert';

class User {
  final String userName;
  final String userHandle;
  final String userID;
  final String avatarUrl;
  final String bio;
  bool isFollowing = false;
  bool isMuted = false;

  User({
    required this.userName,
    required this.userHandle,
    required this.userID,
    required this.avatarUrl,
    required this.bio,
    required this.isFollowing,
    required this.isMuted,
  });

  Future<List<User>> getFollowers() async {
    final followersRes = await HttpWrapper.get(
      Uri.parse(
          'https://fiicen.jp/account/followers/?account_id=$userID'),
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
    final followersRes = await HttpWrapper.get(
      Uri.parse(
          'https://fiicen.jp/account/followers/?account_id=$userID'),
    );

    // 抽出したい部分にマッチする正規表現
    RegExp regExp = RegExp(r'/field/([^/]+)/');
    // 正規表現で全てのマッチを見つける
    Iterable<Match> matches = regExp.allMatches(followersRes.body);
    return matches.length;
  }

  Future<List<User>> getFollowing() async {
    final followingRes = await HttpWrapper.get(
      Uri.parse(
          'https://fiicen.jp/account/following/?account_id=$userID'),
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
    final followingRes = await HttpWrapper.get(
      Uri.parse(
          'https://fiicen.jp/account/following/?account_id=$userID'),
    );

    // 抽出したい部分にマッチする正規表現
    RegExp regExp = RegExp(r'/field/([^/]+)/');
    // 正規表現で全てのマッチを見つける
    Iterable<Match> matches = regExp.allMatches(followingRes.body);
    return matches.length;
  }

  Future<List<Circle>> getPostedCircles({int page = 1}) async {
    String? session = await Manager.loadSessionToken();
    String? csrf = await Manager.loadCsrfToken();

    final _user = userID;

    final response = await HttpWrapper.get(
      Uri.parse('https://fiicen.jp/circle/block/field/$_user/$page/'),
    );

    List<Circle> circleslist = [];

    // HTMLをパースする
    var document = htmlParser.parse(response.body);

    // サークル要素をすべて取得する
    List<dom.Element> circles = document.querySelectorAll('.circle');

    // 各サークルの情報を抽出する
    for (var circle in circles) {
      Circle? parsedCircle = await Manager.parseCircle(circle);
      if (parsedCircle != null) {
        circleslist.add(parsedCircle);
      }
    }
    return circleslist;
  }

  Future<bool> follow() async {
    final response = await HttpWrapper.post(
      Uri.parse('https://fiicen.jp/account/follow/'),
      body: {"followed_id": userID},
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["result"] == "followed") {
        isFollowing = true;
      }else{
        isFollowing = false;
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> mute() async {
    final response = await HttpWrapper.post(
      Uri.parse('https://fiicen.jp/account/mute/'),
      body: {"muted_id": userID},
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    );
    if (response.statusCode == 200) {
      isMuted = !isMuted;
      return true;
    } else {
      return false;
    }
  }
}
