import '../api.dart';

class BasicApi extends AuthorizedApi {
  final String _basePath = '/basic-api';
  final String _userBasePath = '/user';
  final String _patientBasePath = '/patient';
  final String _fcmTokenBasePath = '/token';
  final String _medicBasePath = '/medic';

  String get basicApiPath => "$basePath$_basePath";
  String get userBasePath => _userBasePath;
  String get fcmTokenBasePath => _fcmTokenBasePath;
  String get medicBasePath => _medicBasePath;
  String get patientBasePath => _patientBasePath;
}
