import "manager.dart";
import "user.dart";
import 'reporttype.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;

class Circle {
  final String id;
  final User user;
  final String content;
  final String? imageUrl;
  final String? videoPoster;
  final String? videoUrl;
  final String? replyed_to;
  final String? reflew_name;
  bool liked = false;
  bool reflown = false;

  Circle({
    required this.id,
    required this.user,
    required this.content,
    required this.imageUrl,
    required this.videoPoster,
    required this.videoUrl,
    required this.replyed_to,
    required this.reflew_name,
    required this.liked,
    required this.reflown,
  });

  Future<List<Circle>> getReplys() async {
    String? session = await Manager.loadSessionToken();
    String? csrf = await Manager.loadCsrfToken();

    final response = await http.get(
      Uri.parse('https://fiicen.jp/circle/$id/'),
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
    var replys = document.querySelector('.replys');
    List circles = [];
    if (replys != null) {
      circles = replys.querySelectorAll('.circle');
    }

    // 各サークルの情報を抽出する
    for (var circle in circles) {
      Circle? parsedCircle = await Manager.parseCircle(circle);
      if (parsedCircle != null) {
        circleslist.add(parsedCircle);
      }
    }
    return circleslist;
  }

  Future<int> getReplysCount() async {
    String? session = await Manager.loadSessionToken();
    String? csrf = await Manager.loadCsrfToken();

    final response = await http.get(
      Uri.parse('https://fiicen.jp/circle/$id/'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Cookie': 'sessionid=$session; csrftoken=$csrf;',
      },
    );
    // HTMLをパースする
    var document = htmlParser.parse(response.body);

    // サークル要素をすべて取得する
    List circles = document.querySelectorAll('.circle');
    return circles.length;
  }

  Future<List<User>> getReflyUsers() async {
    final reflysRes = await http.get(
      Uri.parse('https://fiicen.jp/circle/reflys/?circle_id=$id'),
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
    Iterable<Match> matches = regExp.allMatches(reflysRes.body);

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

  Future<int> getReflyUsersCount() async {
    final reflysRes = await http.get(
      Uri.parse('https://fiicen.jp/circle/reflys/?circle_id=$id'),
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
    Iterable<Match> matches = regExp.allMatches(reflysRes.body);
    return matches.length;
  }

  Future<List<User>> getLikedUsers() async {
    final likesRes = await http.get(
      Uri.parse('https://fiicen.jp/circle/likes/?circle_id=$id'),
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
    Iterable<Match> matches = regExp.allMatches(likesRes.body);

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

  Future<int> getLikedUsersCount() async {
    final likesRes = await http.get(
      Uri.parse('https://fiicen.jp/circle/likes/?circle_id=$id'),
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
    Iterable<Match> matches = regExp.allMatches(likesRes.body);
    return matches.length;
  }

  Future<bool> refly() async {
    final response = await http.post(
      Uri.parse('https://fiicen.jp/circle/refly/'),
      body: {"circle_id": id},
      headers: {
        'Content-Type': 'multipart/form-data',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'X-Csrftoken': '${await Manager.loadCsrfToken()}',
        'Cookie':
            'sessionid=${await Manager.loadSessionToken()}; csrftoken=${await Manager.loadCsrfToken()};',
      },
    );
    if (response.statusCode == 200) {
      reflown = !reflown;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> like() async {
    final response = await http.post(
      Uri.parse('https://fiicen.jp/circle/like/'),
      body: {"circle_id": id},
      headers: {
        'Content-Type': 'multipart/form-data',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'X-Csrftoken': '${await Manager.loadCsrfToken()}',
        'Cookie':
            'sessionid=${await Manager.loadSessionToken()}; csrftoken=${await Manager.loadCsrfToken()};',
      },
    );
    if (response.statusCode == 200) {
      liked = !liked;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> reply(String content) async {
    String? session = await Manager.loadSessionToken();
    String? csrf = await Manager.loadCsrfToken();

    var request = http.MultipartRequest(
        'POST', Uri.parse('https://fiicen.jp/circle/create/'));
    request.headers['User-Agent'] =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36';
    request.headers['Cookie'] = 'sessionid=$session; csrftoken=$csrf;';
    request.headers['X-Csrftoken'] = '$csrf';

    request.fields['circle_id'] = id;
    request.fields['contents'] = content;

    var response = await request.send();

    if (response.statusCode == 200) {
      return true;
    }else{
      return false;
    }
  }

  Future<bool> report(ReportTypes type) async {
    final response = await http.post(
      Uri.parse('https://fiicen.jp/report/circle/${id}/'),
      body: {"type": type.name},
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'X-Csrftoken': '${await Manager.loadCsrfToken()}',
        'Cookie':
            'sessionid=${await Manager.loadSessionToken()}; csrftoken=${await Manager.loadCsrfToken()};',
      },
    );

    if (response.statusCode == 200) {
      return true;
    }else{
      return false;
    }
  }
}
