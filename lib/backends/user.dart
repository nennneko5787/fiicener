import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
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
  bool isFollowing = false;
  bool isMuted = false;

  User({
    required this.userName,
    required this.userHandle,
    required this.userID,
    required this.avatarUrl,
    required this.bio,
    required this.circles,
    required this.isFollowing,
    required this.isMuted,
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

  Future<List<Circle>> getPostedCircles({int page = 1}) async {
    String? session = await Manager.loadSessionToken();
    String? csrf = await Manager.loadCsrfToken();

    final _user = userHandle;

    final response = await http.get(
      Uri.parse('https://fiicen.jp/circle/block/field/$_user/$page/'),
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
          user: await Manager.getUserDetails("$accountName"),
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

  Future<bool> follow() async {
    final response = await http.post(
      Uri.parse('https://fiicen.jp/account/follow/'),
      body: {"followed_id": userHandle},
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
      isFollowing = !isFollowing;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> mute() async {
    final response = await http.post(
      Uri.parse('https://fiicen.jp/account/mute/'),
      body: {"muted_id": userHandle},
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
      isMuted = !isMuted;
      return true;
    } else {
      return false;
    }
  }
}
