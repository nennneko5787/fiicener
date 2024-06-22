import 'dart:math';
import 'dart:convert';
import "manager.dart";
import "package:http/http.dart" as http;

class HttpWrapper {
  static Future<http.Response> get(
    Uri url,{
    Map<String, String>? headers,
  }) async {
    String? session = await Manager.loadSessionToken();
    String? csrf = await Manager.loadCsrfToken();

    Map<String, String> allheaders = {
      'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
    };
    allheaders.addAll(headers ?? {});

    allheaders['Cookie'] = (allheaders['Cookie'] ?? '') + (allheaders['Cookie'] != null ? '; ' : '') + 'sessionid=$session; csrftoken=$csrf';

    final response = await http.get(
      url,
      headers:allheaders
    );
    return response;
  }

  static Future<http.Response> post(
    Uri url,{
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding = utf8,
  }) async {
    String? session = await Manager.loadSessionToken();
    String? csrf = await Manager.loadCsrfToken();

    Map<String, String> allheaders = {
      'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
    };
    allheaders.addAll(headers ?? {});

    allheaders['Cookie'] = (allheaders['Cookie'] ?? '') + (allheaders['Cookie'] != null ? '; ' : '') + 'sessionid=$session; csrftoken=$csrf';

    if (!allheaders.containsKey('X-CSRFToken')) {
      allheaders['X-CSRFToken'] = '$csrf';
    }

    dynamic data = body;

    if (allheaders['Content-Type'] == 'multipart/form-data' && body is Map) {
      const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz';
      final random = Random.secure();
      final randomStr =  List.generate(8, (_) => charset[random.nextInt(charset.length)]).join();

      final boundary = 'UNOFFICIALFIICENER$randomStr';
      allheaders['Content-Type'] = 'multipart/form-data; boundary=$boundary';
      data = '';
      for (String key in body.keys) {
        data += '--$boundary\r\nContent-Disposition: form-data; name="$key"\r\n\r\n${body[key]}\r\n';
      }
      data += '--$boundary--';
    }

    print(allheaders);
    print(data);

    final response = await http.post(
      url,
      headers:allheaders,
      body:data,
      encoding:encoding
    );
    return response;
  }
}