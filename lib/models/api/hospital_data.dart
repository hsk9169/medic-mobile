class HospitalDataList {
  final List<HospitalData>? hospitals;
  final int? numOfRows;

  const HospitalDataList({
    this.hospitals,
    this.numOfRows,
  });

  factory HospitalDataList.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>;
    final hospitals = data
        .map<HospitalData>((element) => HospitalData.fromJson(element))
        .toList();
    final numOfRows = json['numOfRows'] as int?;

    return HospitalDataList(
      hospitals: hospitals,
      numOfRows: numOfRows,
    );
  }
}

class HospitalData {
  final String? basicAddress;
  final String? hospitalName;

  const HospitalData({this.hospitalName, this.basicAddress});

  factory HospitalData.fromJson(List<dynamic> data) {
    final hospitalName = data[0] as String;
    final basicAddress = data[1] as String;

    return HospitalData(
      hospitalName: hospitalName,
      basicAddress: basicAddress,
    );
  }
}
