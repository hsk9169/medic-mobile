import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:medic_app/models/api/medic_data.dart';
import 'package:medic_app/services/api/basic/basic_api.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/utils/hash.dart';

class FcmTokenService extends BasicApi {
  Future<Map<String, dynamic>> createFcmToken(
      String phone, String token) async {
    final String userId = HashFunc().getHash(phone);
    try {
      final res = await authClient
          .post(baseUri.replace(path: '$basicApiPath$fcmTokenBasePath/$userId'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(<String, String>{
                'token': token,
                'version': '1.0.0',
              }))
          .timeout(Duration(seconds: timeOut));
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

  Future<dynamic> getFcmToken(String phone) async {
    final String userId = HashFunc().getHash(phone);
    try {
      final res = await authClient
          .get(baseUri.replace(path: '$basicApiPath$fcmTokenBasePath/$userId'))
          .timeout(Duration(seconds: timeOut));
      late dynamic body;
      try {
        body = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 200) {
        return {'data': MedicData.fromJson(body)};
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
