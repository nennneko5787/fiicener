import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TextAgent {
  static RegExp get _urlRegExp => RegExp(
        r"(http(s)?:\/\/[a-zA-Z0-9-.!'()*;/?:@&=+$,%_#]+)",
        caseSensitive: false,
      );

  static TextSpan generateLinkTextSpan(String url) {
    final encadedUrl = Uri.encodeFull(url);
    final recognizer = TapGestureRecognizer()
      ..onTap = () async {
        await launchUrlString(encadedUrl,
            mode: LaunchMode.externalApplication);
      };
    final textSpan = TextSpan(
      text: url,
      recognizer: recognizer,
      style: const TextStyle(color: Colors.lightBlue),
    );
    return textSpan;
  }

  static TextSpan generate(String rawText) {
    final List<TextSpan> textSpans = [];
    rawText.splitMapJoin(
      _urlRegExp,
      onMatch: (Match match) {
        final urlSpan = generateLinkTextSpan(match.group(0) ?? '');
        textSpans.add(urlSpan);
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
