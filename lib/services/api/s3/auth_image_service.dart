import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:medic_app/services/api/api.dart';
import 'package:medic_app/services/api/s3/s3_api.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/utils/hash.dart';

class AuthImgService extends S3Api {
  Future<Map<String, dynamic>> postAuthImage(String phone, File imgFile) async {
    final medicId = HashFunc().getHash(phone);
    try {
      final req = http.MultipartRequest(
          "POST", baseUri.replace(path: '$s3ApiPath$authImgBasePath/create'))
        ..fields["medicId"] = medicId
        ..files.add(await http.MultipartFile.fromPath('file', imgFile.path));
      final streamedRes = await req.send().timeout(Duration(seconds: timeOut));
      late dynamic body;
      var res = await http.Response.fromStream(streamedRes);
      try {
        body = json.decode(res.body);
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 201) {
        return {'data': body['data']};
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

  Future<dynamic> getAuthImage(String medicId) async {
    const Map<String, String> queryParams = {"": ""};
    String queryString = Uri(queryParameters: queryParams).query;
    try {
      final res = await authClient
          .get(
            baseUri.replace(
                path: '$s3ApiPath$authImgBasePath/$medicId',
                query: queryString),
          )
          .timeout(Duration(seconds: timeOut));

      late dynamic body;
      try {
        body = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 200) {
        return {'data': FeedListRes.fromJson(body["data"])};
      } else {
        return {'err': body['error']};
      }
    } catch (err) {
      if (err is SocketException) {
        return {'err': '네트워크 연결을 확인해주세요'};
      } else if (err is TimeoutException) {
        return {'err': '서버 응답이 지연되고 있습니다.'};
      } else {
        return {'err': err};
      }
    }
  }
}
