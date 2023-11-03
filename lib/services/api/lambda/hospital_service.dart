import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:medic_app/models/api/hospital_data.dart';
import 'package:medic_app/services/api/api.dart';

class HospitalService extends Api {
  Future<dynamic> getHospital(String keyword) async {
    final Map<String, String> queryParams = {"keyword": keyword};
    final String queryString = Uri(queryParameters: queryParams).query;
    try {
      final res = await http
          .get(
            baseUri.replace(path: "$basePath$hospListPath", query: queryString),
          )
          .timeout(Duration(seconds: timeOut));
      late dynamic body;
      try {
        body = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        body = null;
      }
      if (res.statusCode == 200) {
        return {'data': HospitalDataList.fromJson(body)};
      } else {
        return {'err': body?['error']};
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
