import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../gui/profile.dart';
import 'manager.dart';

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
    final encodedUrl = Uri.encodeFull(url);
    final recognizer = TapGestureRecognizer()
      ..onTap = () async {
        await launchUrlString(encodedUrl, mode: LaunchMode.externalApplication);
      };
    final textSpan = TextSpan(
      text: url,
      recognizer: recognizer,
      style: const TextStyle(color: Colors.lightBlue),
    );
    return textSpan;
  }

  static TextSpan generateMentionTextSpan(String mention, BuildContext context) {
    final recognizer = TapGestureRecognizer()
      ..onTap = () {
        final username = mention.substring(1);
        Manager.getUserDetails(username).then((user) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(user: user),
            ),
          );
        });
      };

    final textSpan = TextSpan(
      text: mention,
      recognizer: recognizer,
      style: const TextStyle(color: Colors.green),
    );
    return textSpan;
  }

  static TextSpan generate(String rawText, BuildContext context) {
    final List<TextSpan> textSpans = [];
    final splitRegExp = RegExp('(${_urlRegExp.pattern})|(${_mentionRegExp.pattern})');

    rawText.splitMapJoin(
      splitRegExp,
      onMatch: (Match match) {
        final matchedText = match.group(0) ?? '';
        if (_urlRegExp.hasMatch(matchedText)) {
          final urlSpan = generateLinkTextSpan(matchedText);
          textSpans.add(urlSpan);
        } else if (_mentionRegExp.hasMatch(matchedText)) {
          final mentionSpan = generateMentionTextSpan(matchedText, context);
          textSpans.add(mentionSpan);
        }
        return '';
      },
      onNonMatch: (String text) {
        final commonSpan = TextSpan(text: text);
        textSpans.add(commonSpan);
        return '';
      },
    );

    return TextSpan(children: textSpans);
  }
}
