import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../backends/circle.dart'; // Circle クラスを提供するファイルをインポート
import '../backends/manager.dart';
import '../backends/user.dart';
import 'profile.dart';

class CircleMenu extends StatefulWidget {
  const CircleMenu();

  @override
  _CircleMenuState createState() => _CircleMenuState();
}

class _CircleMenuState extends State<CircleMenu> {
  late Future<List<Circle>> _circlesFuture;
  List<Circle> circles = []; // circles リストを定義
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCircles();
  }

  Future<void> _loadCircles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _circlesFuture = Manager.getHomeCircles();
      circles = await _circlesFuture;
    } catch (e) {
      // Handle errors if needed
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    await _loadCircles();
  }

  void _onCommentButtonPressed(int index) {
    print("comment pressed");
  }

  void _onLikeButtonPressed(int index) {
    print("like pressed");
  }

  void _onRetweetButtonPressed(int index) {
    print("refly pressed");
  }

  Widget _buildCircleAvatar(Circle circle) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(user: circle.user)),
      ),
      child: CircleAvatar(
        backgroundImage: NetworkImage(circle.user.avatarUrl),
      ),
    );
  }

  Widget _buildUserInfo(Circle circle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          circle.user.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          circle.user.userHandle,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActions(int index, Circle circle) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.comment),
          onPressed: () => _onCommentButtonPressed(index),
        ),
        Text(circle.replys.length.toString()),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.repeat),
          onPressed: () => _onRetweetButtonPressed(index),
        ),
        Text(circle.reflyusers.length.toString()),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: () => _onLikeButtonPressed(index),
        ),
        Text(circle.likedusers.length.toString()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<Circle>>(
              future: _circlesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView(); // Empty ListView to show refresh indicator
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Scrollbar(
                    child: ListView.builder(
                      itemCount: circles.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildCircleAvatar(circles[index]),
                                  const SizedBox(width: 8),
                                  _buildUserInfo(circles[index]),
                                ],
                              ),
                              const SizedBox(height: 8),
                              CircleRichText(text: circles[index].content),
                              _buildActions(index, circles[index]),
                              Divider(
                                color: Colors.grey,
                                thickness: 1,
                                height: 2,
                              ),
                            ],
                          ),
                          onTap: () {},
                        );
                      },
                    ),
                  );
                }
              },
            ),
          );
  }
}

class CircleRichText extends StatelessWidget {
  final String text;
  static const String mentionPattern = r'@(\w+)';
  static const String urlPattern =
      r'https?:\/\/[\w\-]+(\.[\w\-]+)+[/#?]?.*'; // URLの正規表現パターン

  CircleRichText({required this.text});

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> children = [];

    children.add(
      TextSpan(
        text: text,
      ),
    );

    final matches =
        RegExp(RegExp.escape(mentionPattern) + '|' + RegExp.escape(urlPattern))
            .allMatches(text);

    if (matches.isNotEmpty) {
      children = [];
      String remainingText = text;
      matches.forEach((match) {
        final String matchText = match.group(0)!;
        final int start = match.start;
        final int end = match.end;

        // メンションやURLの前にあるテキストを追加
        if (start > 0) {
          children.add(
            TextSpan(
              text: remainingText.substring(0, start),
            ),
          );
        }

        // メンションやURLを追加
        if (RegExp(mentionPattern).hasMatch(matchText)) {
          // メンションの場合
          children.add(
            TextSpan(
              text: matchText,
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  User _user = await Manager.getUserDetails(
                      matchText.replaceAll("@", ""));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(user: _user)),
                  );
                },
            ),
          );
        } else if (RegExp(urlPattern).hasMatch(matchText)) {
          // URLの場合
          children.add(
            TextSpan(
              text: matchText,
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _launchURL(matchText);
                },
            ),
          );
        }

        // 残りのテキストを更新
        remainingText = remainingText.substring(end);
      });

      // 残りのテキストを追加
      if (remainingText.isNotEmpty) {
        children.add(
          TextSpan(
            text: remainingText,
          ),
        );
      }
    }
  }

  // URLを開く関数
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
