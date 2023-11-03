import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:medic_app/services/api/api.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/kakao_options.dart';

class KakaoService extends Api {
  final kakaoOptions = DefaultKakaoOptions.kakaoOptions;
  Future<dynamic> getAddressList(String query, int nextPage) async {
    try {
      final res = await http.get(
        Uri(
            scheme: 'https',
            host: kakaoOptions["addressApiHost"],
            path: kakaoOptions["addressApiPath"],
            query: Uri(queryParameters: {
              "query": query,
              "page": nextPage.toString(),
            }).query),
        headers: {
          "Authorization": kakaoOptions["restApiKey"]!,
          "Content-type": "application/x-www-form-urlencoded;"
        },
      ).timeout(Duration(seconds: timeOut));
      late dynamic body;
      try {
        body = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 200) {
        return {'data': KakaoAddress.fromJson(body)};
      } else if (res.statusCode == 400) {
        return {'err': '검색어를 입력해주세요'};
      } else {
        return {'err': 'UNKNOWN_ERROR'};
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
