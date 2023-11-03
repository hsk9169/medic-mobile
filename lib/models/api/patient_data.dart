class PatientDataReq {
  String? name;
  String? phone;
  String? gender;
  String? birthDate;
  String? code;
  String? nurseName;
  String? doctorName;
  String? roomCode;
  String? hospitalCode;

  PatientDataReq({
    this.name = '',
    this.phone = '',
    this.gender = '',
    this.birthDate = '',
    this.code = '',
    this.nurseName = '',
    this.doctorName = '',
    this.roomCode = '',
    this.hospitalCode = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'gender': gender,
        'birthDate': birthDate,
        'code': code,
        'nurseName': nurseName,
        'doctorName': doctorName,
        'roomCode': roomCode,
      };
}

class PatientDataRes {
  String? id;
  String? name;
  String? gender;
  String? age;
  String? code;
  String? nurseName;
  String? doctorName;
  String? roomCode;
  String? lastFeedDate;
  List<String>? lastFeedUrl;

  PatientDataRes({
    this.id = '',
    this.name = '',
    this.gender = '',
    this.age,
    this.code = '',
    this.nurseName = '',
    this.doctorName = '',
    this.roomCode = '',
    this.lastFeedDate = '',
    this.lastFeedUrl,
  });

  factory PatientDataRes.fromJson(Map<String, dynamic> json) {
    return PatientDataRes(
      id: json['patientID'] ?? '',
      name: json['username'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] != null ? json['age'].toString() : '',
      code: json['patientCode'] ?? '',
      nurseName: json['nurseName'] ?? '',
      doctorName: json['doctorName'] ?? '',
      roomCode: json['roomCode'] ?? '',
      lastFeedDate: json['lastFeedUpdatedAt'] ?? '',
      lastFeedUrl: json['imageUrls'] != null
          ? json['imageUrls']
              .map<String>((element) => element.toString())
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender,
        'age': age,
        'code': code,
        'nurseName': nurseName,
        'doctorName': doctorName,
        'roomCode': roomCode,
        'lastFeedDate': lastFeedDate,
        'lastFeedUrl': lastFeedUrl ?? '',
      };
}

class PatientReqFilter {
  String hospitalCode;
  String? nurseName;
  String? doctorName;
  String? datetime;
  String? lastFeedUpdateDate;
  List<String>? roomCode;

  PatientReqFilter(
      {required this.hospitalCode,
      this.nurseName,
      this.doctorName,
      this.datetime,
      this.lastFeedUpdateDate,
      this.roomCode});

  Map<String, dynamic> toJson() => {
        'hospitalCode': hospitalCode,
        'nurseName': nurseName,
        'doctorName': doctorName,
        'lastFeedUpdateDate': lastFeedUpdateDate,
        'roomCode': roomCode,
      };
}
