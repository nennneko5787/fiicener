import 'dart:math';
import "manager.dart";
import "package:http/http.dart" as http;

class HttpWrapper {
  static Future<http.Response> get({
    required Uri uri,
    Map<String, String> headers
  }) async {
    String? session = await Manager.loadSessionToken();
    String? csrf = await Manager.loadCsrfToken();

    Map allheaders = {
      'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
    };
    allheaders.addAll(headers ?? {});

    if (allheaders.containsKey('Cookie')) {
      allheaders['Cookie'] = allheaders['Cookie'] + 'sessionid=$session; csrftoken=$csrf';
    } else {
      allheaders['Cookie'] = 'sessionid=$session; csrftoken=$csrf';
    }

    final response = await http.get(
      uri,
      allheaders
    );
    return response;
  }

  static Future<http.Response> put({
    required Uri uri,
    Map<String, String> headers
    Object body,
    Encoding encoding = utf8
  }) async {
    String? session = await Manager.loadSessionToken();
    String? csrf = await Manager.loadCsrfToken();

    Map allheaders = {
      'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
    };
    allheaders.addAll(headers ?? {});

    if (allheaders.containsKey('Cookie')) {
      allheaders['Cookie'] += 'sessionid=$session; csrftoken=$csrf';
    } else {
      allheaders['Cookie'] = 'sessionid=$session; csrftoken=$csrf';
    }

    if (!allheaders.containsKey('X-CSRFToken')) {
      allheaders['X-CSRFToken'] = csrf;
    }

    dynamic data = body;

    if (allheaders['Content-Type'] == 'multipart/form-data' && body is Map) {
      const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz';
      final random = Random.secure();
      final randomStr =  List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();

      final boundary = '--UNOFFICIAL-FIICENER-$randomStr';
      allheaders['Content-Type'] += '; boundary=$boundary';
      data = '';
      for (String key in body.keys) {
        data += '$boundary\r\nContent-Disposition: form-data; name="$key"\r\n\r\n${body[key]}\r\n$boundary--\r\n';
      }
    }

    final response = await http.get(
      uri,
      allheaders,
      data,
      encoding
    );
    return response;
  }
}