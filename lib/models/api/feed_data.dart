import 'dart:io';

class FeedPostReq {
  List<File>? files;
  List<File>? originFiles;
  String? patientId;
  FeedMeta? feedMeta;

  FeedPostReq({
    this.files,
    this.originFiles,
    this.patientId = '',
    this.feedMeta,
  });
}

class FeedMeta {
  String? authorId;
  String? postContent;
  List<String>? tagIDs;

  FeedMeta({
    this.authorId = '',
    this.postContent = '',
    this.tagIDs,
  });

  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'postContent': postContent,
        'tagIDs': tagIDs != null
            ? tagIDs!.map((element) => element.toString()).toList()
            : [],
      };
}

class FeedListRes {
  String nextCursor;
  List<FeedData> feedDataList;

  FeedListRes({
    required this.nextCursor,
    required this.feedDataList,
  });

  factory FeedListRes.fromJson(Map<String, dynamic> json) {
    return FeedListRes(
        nextCursor: json['NextCursor'] ?? '',
        feedDataList: json['FeedDataList'] != null
            ? json['FeedDataList']
                .map<FeedData>((element) => FeedData.fromJson(element))
                .toList()
            : []);
  }

  Map<String, dynamic> toJson() => {
        'nextCursor': nextCursor,
        'feedDataList': feedDataList.map((element) => element.toJson()).toList()
      };
}

class FeedData {
  String? authorName;
  String? postContent;
  String? createdDate;
  List<String>? imageUrls;
  String? thumbnailImage;

  FeedData({
    this.authorName = '',
    this.postContent = '',
    this.createdDate = '',
    this.imageUrls,
    this.thumbnailImage = '',
  });

  factory FeedData.fromJson(Map<String, dynamic> json) {
    return FeedData(
      authorName: json['AuthorName'] ?? '',
      postContent: json['PostContent'] ?? '',
      createdDate: json['CreateDate'] ?? '',
      imageUrls: json['ImageUrls'] != null
          ? json['ImageUrls']
              .map<String>((element) => element.toString())
              .toList()
          : [],
      thumbnailImage: json['ImageBase64'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'authorName': authorName,
        'postContent': postContent,
        'createdDate': createdDate,
      };
}
