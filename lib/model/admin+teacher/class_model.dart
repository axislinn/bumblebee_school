class ClassModel {
  final String id;
  final String grade;
  final String className;
  final String classCode;
  final String school;
  final List<String> students;
  final List<String> teachers;
  final List<String> guardians;
  final List<String> announcements;

  ClassModel({
    required this.id,
    required this.grade,
    required this.className,
    required this.classCode,
    required this.school,
    required this.students,
    required this.teachers,
    required this.guardians,
    required this.announcements,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['_id'] ?? '',
      grade: json['grade'] ?? '',
      className: json['className'] ?? '',
      classCode: json['classCode'] ?? '',
      // Handling 'school' as either a String or an object
      school: json['school'] is Map ? json['school']['name'] ?? '' : json['school'] ?? '',
      // Handling lists and ensuring all items are Strings
      students: json['students'] != null ? List<String>.from(json['students'].map((item) => item.toString())) : [],
      teachers: json['teachers'] != null ? List<String>.from(json['teachers'].map((item) => item.toString())) : [],
      guardians: json['guardians'] != null ? List<String>.from(json['guardians'].map((item) => item.toString())) : [],
      announcements: json['announcements'] != null ? List<String>.from(json['announcements'].map((item) => item.toString())) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'grade': grade,
      'className': className,
      'classCode': classCode,
      'school': school,
      'students': students,
      'teachers': teachers,
      'guardians': guardians,
      'announcements': announcements,
    };
  }
}
