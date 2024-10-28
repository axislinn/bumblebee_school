class TeacherRequestModel {
  final String classId;
  final String requestId;
  final bool response;

  TeacherRequestModel({
    required this.classId,
    required this.requestId,
    required this.response,
  });

  factory TeacherRequestModel.fromJson(Map<String, dynamic> json) {
    // Handle potential null values safely
    return TeacherRequestModel(
      classId: json['classId'] ?? '', // Default to an empty string if null
      requestId: json['requestId'] ?? '', // Default to an empty string if null
      response: json['response'] ?? false, // Default to false if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'requestId': requestId,
      'response': response,
    };
  }

  // Factory method to create a list of TeacherRequestModel from JSON
  static List<TeacherRequestModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => TeacherRequestModel.fromJson(item)).toList();
  }
}
