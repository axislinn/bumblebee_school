class PostedByModel {
  final String userId;
  final String userName;
  final String profilePicture;

  PostedByModel({
    required this.userId,
    required this.userName,
    required this.profilePicture,
  });

  factory PostedByModel.fromJson(Map<String, dynamic> json) {
    return PostedByModel(
      userId: json['_id'] ?? '',
      userName: json['userName'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': userId,
      'userName': userName,
      'profilePicture': profilePicture,
    };
  }
}
