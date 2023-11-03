class UserDataRes {
  String? username;
  String? phone;
  String? address;
  String? createdAt;

  UserDataRes({
    this.username = '',
    this.phone = '',
    this.address = '',
    this.createdAt = '',
  });

  factory UserDataRes.fromJson(Map<String, dynamic> json) {
    return UserDataRes(
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'phone': phone,
        'address': address,
        'createdAt': createdAt,
      };
}

class UserDataReq {
  String? username;
  String? phone;
  String? address;
  String? birthDate;
  String? gender;

  UserDataReq({
    this.username = '',
    this.phone = '',
    this.address = '',
    this.birthDate = '',
    this.gender = '',
  });

  factory UserDataReq.fromJson(Map<String, dynamic> json) {
    return UserDataReq(
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      birthDate: json['birthDate'] ?? '',
      gender: json['gender'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'phone': phone,
        'address': address,
        'birthDate': birthDate,
        'gender': gender,
      };
}
