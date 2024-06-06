import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../gui/profile.dart';

class TextAgent {
  static RegExp get _urlRegExp => RegExp(
        r"(http(s)?:\/\/[a-zA-Z0-9-.!'()*;/?:@&=+$,%_#]+)",
        caseSensitive: false,
      );

  static RegExp get _mentionRegExp => RegExp(
        r"(@[a-zA-Z0-9_]+)",
        caseSensitive: false,
      );

  static TextSpan generateLinkTextSpan(String url) {
    final _encodedUrl = Uri.encodeFull(url);
    final _recognizer = TapGestureRecognizer()
      ..onTap = () async {
        await launchUrlString(_encodedUrl, mode: LaunchMode.externalApplication);
      };
    final _textSpan = TextSpan(
      text: url,
      recognizer: _recognizer,
      style: TextStyle(color: Colors.lightBlue),
    );
    return _textSpan;
  }

  static TextSpan generateMentionTextSpan(String mention, BuildContext context) {
    final _recognizer = TapGestureRecognizer()
      ..onTap = () {
        // Extract the username from the mention (e.g., @username -> username)
        final username = mention.substring(1);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(user: username),
          ),
        );
      };
    final _textSpan = TextSpan(
      text: mention,
      recognizer: _recognizer,
      style: TextStyle(color: Colors.green), // You can choose a different color
    );
    return _textSpan;
  }

  static TextSpan generate(String _rawText, BuildContext context) {
    final List<TextSpan> _textSpans = [];
    final _splitRegExp = RegExp('(${_urlRegExp.pattern})|(${_mentionRegExp.pattern})');

    _rawText.splitMapJoin(
      _splitRegExp,
      onMatch: (Match match) {
        final matchedText = match.group(0) ?? '';
        if (_urlRegExp.hasMatch(matchedText)) {
          final _urlSpan = generateLinkTextSpan(matchedText);
          _textSpans.add(_urlSpan);
        } else if (_mentionRegExp.hasMatch(matchedText)) {
          final _mentionSpan = generateMentionTextSpan(matchedText, context);
          _textSpans.add(_mentionSpan);
        }
        return '';
      },
      onNonMatch: (String text) {
        final _commonSpan = TextSpan(text: text);
        _textSpans.add(_commonSpan);
        return '';
      },
    );

    return TextSpan(children: _textSpans);
  }
}