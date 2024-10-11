import 'package:bumblebee_school_final/model/admin+teacher/post_model.dart';

class ApiResponseModel {
  final bool con;
  final String msg;
  final List<PostModel>? items;

  ApiResponseModel({
    required this.con,
    required this.msg,
    this.items,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ApiResponseModel(
      con: json['con'] ?? false,
      msg: json['msg'] ?? '',
      items: json['result'] != null && json['result']['items'] != null
          ? List<PostModel>.from(
              json['result']['items'].map((item) => PostModel.fromJson(item)))
          : null,
    );
  }
}
