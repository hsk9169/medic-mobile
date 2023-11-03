import '../api.dart';

class S3Api extends AuthorizedApi {
  final String _basePath = '/s3-api';
  final String _feedBasePath = '/feed';
  final String _authImgBasePath = '/auth';

  String get s3ApiPath => "$basePath$_basePath";
  String get feedBasePath => _feedBasePath;
  String get authImgBasePath => _authImgBasePath;
}
