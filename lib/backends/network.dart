import "manager.dart";
import "package:http/http.dart" as http;

class HttpWrapper {
  static Future<http.Response> get({
    required Uri uri,
    Map<String, String> headers
  }) async {
    String? session = await Manager.loadSessionToken();
    String? csrf = await Manager.loadCsrfToken();

    Map allheaders = {};
    allheaders.addAll(headers)

    if (allheaders.containsKey('Cookie')) {
      allheaders['Cookie'] = allheaders['Cookie'] + 'sessionid=$session; csrftoken=$csrf;';
    } else {
      allheaders['Cookie'] = 'sessionid=$session; csrftoken=$csrf;';
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

    Map allheaders = {};
    allheaders.addAll(headers)

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
      final boundary = '--UNOFFICIAL-FIICENER';
      allheaders['Content-Type'] += '; boundary=$boundary';
      data = '';
      for (String key in body.keys) {
        data += '$boundary\r\nContent-Disposition: form-data; name="$key"\r\n\r\n${body[key]}\r\n';
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