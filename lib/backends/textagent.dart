import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TextAgent {
  static RegExp get _urlRegExp => RegExp(
        r"(http(s)?:\/\/[a-zA-Z0-9-.!'()*;/?:@&=+$,%_#]+)",
        caseSensitive: false,
      );

  static TextSpan generateLinkTextSpan(String url) {
    final _encadedUrl = Uri.encodeFull(url);
    final _recognizer = TapGestureRecognizer()
      ..onTap = () async {
        await launchUrlString(_encadedUrl,
            mode: LaunchMode.externalApplication);
      };
    final _textSpan = TextSpan(
      text: url,
      recognizer: _recognizer,
      //style: リンク部分のテキストスタイル
    );
    return _textSpan;
  }

  static TextSpan generate(String _rawText) {
    final List<TextSpan> _textSpans = [];
    _rawText.splitMapJoin(
      _urlRegExp,
      onMatch: (Match match) {
        final _urlSpan = generateLinkTextSpan(match.group(0) ?? '');
        _textSpans.add(_urlSpan);
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
