import '../api.dart';

class AuthApi extends AuthorizedApi {
  final String _basePath = '/auth';
  //final String _basePath = '';
  final String _verifyPath = '/valid';
  final String _signinPath = '/signin';
  final String _signoutPath = '/signout';

  String get authBasePath => "$basePath$_basePath";
  String get verifyPath => _verifyPath;
  String get signinPath => _signinPath;
  String get signoutPath => _signoutPath;
}
