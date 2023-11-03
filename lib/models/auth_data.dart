class AuthData {
  String? accessToken;
  String? refreshToken;
  String? atExpires;
  String? rtExpires;

  AuthData({
    this.accessToken = '',
    this.refreshToken = '',
    this.atExpires = '',
    this.rtExpires = '',
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['AccessToken'] ?? '',
      refreshToken: json['RefreshToken'] ?? '',
      atExpires: json['AtExpires'] != null ? json['AtExpires'].toString() : '',
      rtExpires: json['RtExpires'] != null ? json['RtExpires'].toString() : '',
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'atExpires': atExpires,
        'rtExpires': rtExpires,
      };
}
