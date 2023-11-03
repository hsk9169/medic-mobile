class MedicData {
  String? username;
  String? phone;
  String? authURL;
  String? hospitalCode;
  String? wardCode;
  String? position;
  bool? authFlag;

  MedicData({
    this.username = '',
    this.phone = '',
    this.authURL = '',
    this.hospitalCode = '',
    this.wardCode = '',
    this.position = '',
    this.authFlag = false,
  });

  factory MedicData.fromJson(Map<String, dynamic> json) {
    return MedicData(
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      authURL: json['authURL'] ?? '',
      hospitalCode: json['hospitalCode'] ?? '',
      wardCode: json['wardCode'] ?? '',
      position: json['position'] ?? '',
      authFlag: json['authFlag'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'phone': phone,
        'authURL': authURL,
        'hospitalCode': hospitalCode,
        'wardCode': wardCode,
        'position': position,
        'authFlag': authFlag,
      };
}
