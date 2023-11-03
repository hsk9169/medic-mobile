import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:medic_app/services/api/basic/basic_api.dart';
import 'package:medic_app/models/models.dart';

class PatientService extends BasicApi {
  Future<Map<String, dynamic>> createPatient(PatientDataReq patientData) async {
    try {
      final res = await authClient
          .post(baseUri.replace(path: '$basicApiPath$patientBasePath/create'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(<String, String>{
                'phone': patientData.phone!,
                'hospitalCode': patientData.hospitalCode!,
                'username': patientData.name!,
                'doctorName': patientData.doctorName!,
                'nurseName': patientData.nurseName!,
                'roomCode': patientData.roomCode!,
                'patientCode': patientData.code!,
                'birthDate': patientData.birthDate!,
                'gender': patientData.gender!,
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

  Future<dynamic> getPatientListByHospitalAndFilters(
      PatientReqFilter filters) async {
    Map<String, dynamic> queryParams = {};
    filters.toJson().forEach((key, val) {
      if (val != null) {
        queryParams[key] = val;
      }
    });
    String queryString = Uri(queryParameters: queryParams).query;
    try {
      final res = await authClient
          .get(
            baseUri.replace(
                path: '$basicApiPath$patientBasePath/hospital',
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
        return {
          'data': body['patients'] != null
              ? body['patients']
                  .map((patient) => PatientDataRes.fromJson(patient))
                  .toList()
              : []
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

  Future<dynamic> getPatientByCode(String hospitalCode, String codeNum) async {
    Map<String, String> queryParams = {
      "hospitalCode": hospitalCode,
      "patientCode": codeNum
    };
    String queryString = Uri(queryParameters: queryParams).query;
    try {
      final res = await authClient
          .get(
            baseUri.replace(
                path: '$basicApiPath$patientBasePath/patientCode',
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
        return {'data': PatientDataRes.fromJson(body)};
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
