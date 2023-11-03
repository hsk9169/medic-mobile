import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:medic_app/services/encrypted_storage_service.dart';
import 'package:medic_app/models/models.dart';

class Api {
  // API Server Info
  final Uri _baseUri = Uri(
    scheme: 'https',
    host: 'xfbzf96zsa.execute-api.ap-northeast-2.amazonaws.com',
  );
  //final Uri _baseUri = Uri(
  //  scheme: 'http',
  //  host: 'localhost',
  //  port: 8080,
  //);

  final String _basePath = '/test';
  //final String _basePath = '';
  final String _hospListPath = '/hosp-info';
  final String _refreshTokenPath = '/auth/refresh';
  //final String _refreshTokenPath = '/refresh';

  final int _timeOut = 30;
  // getter
  Uri get baseUri => _baseUri;
  String get basePath => _basePath;
  String get hospListPath => _hospListPath;
  int get timeOut => _timeOut;
  String get refreshTokenPath => _refreshTokenPath;
}

class AuthorizedApi extends Api {
  final authClient = InterceptedClient.build(
      interceptors: [AuthInterceptor()],
      retryPolicy: ExpiredTokenRetryPolicy());
  final String _unauthorizedFlag = 'UNAUTHORIZED';
  String get unauthorizedFlag => _unauthorizedFlag;
}

class AuthInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    await EncryptedStorageService().initStorage();
    return await EncryptedStorageService().readData("access_token").then((at) {
      data.headers["Authorization"] = "Bearer $at";
      return data;
    });
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async =>
      data;
}

class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  int maxRetryAttempts = 1;

  @override
  Future<bool> shouldAttemptRetryOnResponse(ResponseData response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      await EncryptedStorageService().initStorage();
      final rt = await EncryptedStorageService().readData("refresh_token");
      return await refreshToken(rt).then((res) async {
        if (res.containsKey('err')) {
          return false;
        } else {
          final AuthData authData = res['data'];
          await EncryptedStorageService()
              .saveData("access_token", authData.accessToken ?? "");
          await EncryptedStorageService()
              .saveData("refresh_token", authData.refreshToken ?? "");
          return true;
        }
      });
    }

    return false;
  }

  Future<Map<String, dynamic>> refreshToken(String rt) async {
    try {
      final res = await http.get(
          Api()
              .baseUri
              .replace(path: "${Api().basePath}${Api().refreshTokenPath}"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': "Bearer $rt"
          }).timeout(Duration(seconds: Api().timeOut));
      late dynamic body;
      try {
        body = json.decode(res.body);
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 200) {
        return {'data': AuthData.fromJson(body['authData'])};
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
