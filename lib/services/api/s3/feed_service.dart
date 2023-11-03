import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:medic_app/services/api/api.dart';
import 'package:medic_app/services/api/s3/s3_api.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/services/encrypted_storage_service.dart';

class FeedService extends S3Api {
  Future<Map<String, dynamic>> postFeed(FeedPostReq data) async {
    try {
      await EncryptedStorageService().initStorage();
      final at = await EncryptedStorageService().readData("access_token");
      final req = http.MultipartRequest(
          "POST", baseUri.replace(path: '$s3ApiPath$feedBasePath/create'))
        ..headers["Authorization"] = "Bearer $at"
        ..fields["patientId"] = data.patientId ?? ''
        ..fields["feedMeta"] =
            data.feedMeta != null ? jsonEncode(data.feedMeta!.toJson()) : '';
      for (var file in data.files!) {
        req.files.add(await http.MultipartFile.fromPath('files', file.path));
      }
      for (var file in data.originFiles!) {
        req.files
            .add(await http.MultipartFile.fromPath('originFiles', file.path));
      }
      final streamedRes = await req.send().timeout(Duration(seconds: timeOut));
      late dynamic body;
      var res = await http.Response.fromStream(streamedRes);
      try {
        body = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 201) {
        return {'data': body};
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        final rt = await EncryptedStorageService().readData("refresh_token");
        final refreshRes = await ExpiredTokenRetryPolicy().refreshToken(rt);
        if (refreshRes.containsKey('err')) {
          if (refreshRes['err'] == unauthorizedFlag) {
            return {'err': unauthorizedFlag};
          } else {
            return {'err': refreshRes['err']};
          }
        } else {
          final AuthData authData = refreshRes['data'];
          await EncryptedStorageService()
              .saveData("access_token", authData.accessToken ?? "");
          await EncryptedStorageService()
              .saveData("refresh_token", authData.refreshToken ?? "");
          req.headers["Authorization"] = "Bearer ${authData.refreshToken}";
          final retryStreamedRes =
              await req.send().timeout(Duration(seconds: timeOut));
          var retryRes = await http.Response.fromStream(retryStreamedRes);
          try {
            body = json.decode(retryRes.body);
          } catch (_) {
            body = null;
          }
          if (res.statusCode == 201) {
            return {'data': body};
          } else if (res.statusCode == 401 || res.statusCode == 403) {
            return {'err': unauthorizedFlag};
          } else {
            return {'err': body['error']};
          }
        }
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

  Future<dynamic> getFeedList(String patientId) async {
    const Map<String, String> queryParams = {};
    String queryString = Uri(queryParameters: queryParams).query;
    final patientID = patientId.split('#').last;
    try {
      final res = await authClient
          .get(
            baseUri.replace(
                path: '$s3ApiPath$feedBasePath/$patientID', query: queryString),
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
        return {'err': err};
      }
    }
  }

  Future<dynamic> getFeedImageList(
      String patientId, List<String> imgUrls) async {
    Map<String, dynamic> queryParams = {"imageUrls": imgUrls};
    final patientID = patientId.split('#').last;
    try {
      final res = await authClient
          .get(
            baseUri.replace(
                path: '$s3ApiPath$feedBasePath/image/$patientID',
                queryParameters: queryParams),
          )
          .timeout(Duration(seconds: timeOut));

      late dynamic body;
      try {
        body = json.decode(res.body);
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 200) {
        return {'data': body["data"]};
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
        return {'err': err};
      }
    }
  }
}
