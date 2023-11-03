import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:medic_app/services/api/auth/auth_api.dart';
import 'package:medic_app/models/models.dart';

class SessionService extends AuthApi {
  Future<Map<String, dynamic>> signIn(String phone, String role) async {
    try {
      final res = await authClient
          .post(baseUri.replace(path: "$authBasePath$signinPath"),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(<String, String>{
                'phone': phone,
                'role': role,
              }))
          .timeout(Duration(seconds: timeOut));
      late dynamic body;
      try {
        body = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 200) {
        return {'data': body};
      } else {
        return {'err': body['error']};
      }
    } catch (err) {
      if (err is SocketException) {
        return {'err': '네트워크 연결을 확인해주세요'};
      } else if (err is TimeoutException) {
        return {'err': '서버 응답이 지연되고 있습니다.'};
      } else {
        return {'err': 'UNKNOWN_ERROR'};
      }
    }
  }

  Future<Map<String, dynamic>> checkValid() async {
    try {
      final res = await authClient.get(
        baseUri.replace(path: "$authBasePath$verifyPath"),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: timeOut));
      late dynamic body;
      try {
        body = json.decode(res.body);
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 200) {
        return {'data': body};
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        return {'err': unauthorizedFlag};
      } else {
        return {'err': body['error']};
      }
    } catch (err) {
      if (err is SocketException) {
        return {'err': '네트워크 연결을 확인해주세요'};
      } else if (err is TimeoutException) {
        return {'err': '서버 응답이 지연되고 있습니다.'};
      } else {
        return {'err': 'UNKNOWN_ERROR'};
      }
    }
  }

  Future<Map<String, dynamic>> signOut() async {
    try {
      final res = await authClient
          .get(baseUri.replace(path: '$authBasePath$signoutPath'), headers: {
        'Content-Type': 'application/json',
      }).timeout(Duration(seconds: timeOut));
      late dynamic body;
      try {
        body = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 200) {
        return {'data': AuthData.fromJson(body)};
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        return {'err': unauthorizedFlag};
      } else {
        return {'err': body['error']};
      }
    } catch (err) {
      if (err is SocketException) {
        return {'err': '네트워크 연결을 확인해주세요'};
      } else if (err is TimeoutException) {
        return {'err': '서버 응답이 지연되고 있습니다.'};
      } else {
        return {'err': 'UNKNOWN_ERROR'};
      }
    }
  }
}
