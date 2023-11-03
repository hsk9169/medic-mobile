class KakaoAddress {
  final List<AddressData>? documents;
  final bool? isEnd;
  const KakaoAddress({
    this.documents,
    this.isEnd,
  });

  factory KakaoAddress.fromJson(Map<String, dynamic> json) {
    return KakaoAddress(
        documents: json['documents'] != null
            ? json['documents']
                .map<AddressData>((element) => AddressData.fromJson(element))
                .toList()
            : [],
        isEnd: json['meta']['is_end'] ?? false);
  }
}

class AddressData {
  final String? basicAddress;
  final String? roadAddress;
  final String? buildingName;
  const AddressData({this.basicAddress, this.roadAddress, this.buildingName});
  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      basicAddress: json['address_name'] ?? '',
      roadAddress: json['road_address_name'] ?? '',
      buildingName: json['place_name'] ?? '',
    );
  }
}
