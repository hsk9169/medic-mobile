import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:medic_app/models/api/medic_data.dart';
import 'package:medic_app/services/api/basic/basic_api.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/utils/hash.dart';

class MedicService extends BasicApi {
  Future<Map<String, dynamic>> createMedic(MedicData medicData) async {
    try {
      final res = await authClient
          .post(baseUri.replace(path: '$basicApiPath$medicBasePath/create'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(<String, String>{
                'phone': medicData.phone!,
                'username': medicData.username!,
                'hospitalCode': medicData.hospitalCode!,
                'wardCode': medicData.wardCode!,
                'position': medicData.position!,
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

  Future<dynamic> getMedic(String phone) async {
    final String userId = HashFunc().getHash(phone);
    try {
      final res = await authClient
          .get(baseUri.replace(path: '$basicApiPath$medicBasePath/$userId'))
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

  Future<Map<String, dynamic>> updateAuthUrl(
      String phone, String authUrl) async {
    final medicId = HashFunc().getHash(phone);
    try {
      final res = await authClient
          .put(baseUri.replace(path: '$basicApiPath$medicBasePath/$medicId'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(<String, String>{
                'authURL': authUrl,
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

  Future<dynamic> getMedicList(String hospitalCode, String position) async {
    Map<String, String> queryParams = {
      "hospitalCode": hospitalCode,
      "position": position
    };
    String queryString = Uri(queryParameters: queryParams).query;
    try {
      final res = await authClient
          .get(baseUri.replace(
              path: '$basicApiPath$medicBasePath/hospital/position',
              query: queryString))
          .timeout(Duration(seconds: timeOut));
      late dynamic body;
      try {
        body = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 200) {
        return {
          'data': body['medicList']
              .map<String>((medic) => medic["MedicName"].toString())
              .toList()
        };
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
