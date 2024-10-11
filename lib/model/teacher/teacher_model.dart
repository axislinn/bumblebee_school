class TeacherModel {
  final String id; // Unique identifier for the teacher
  final String fullName;
  final String email;
  final String phone;
  final String? profilePicture; // Optional field for teacher's profile picture
  final String? bio; // Optional field for teacher's biography
  final List<String>? subjects; // Optional list of subjects the teacher teaches
  final String schoolId; // Reference to the school the teacher belongs to
  final DateTime? createdAt; // Optional field for when the teacher was added to the system
  final DateTime? updatedAt; // Optional field for when the teacher's information was last updated

  TeacherModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profilePicture,
    this.bio,
    this.subjects,
    required this.schoolId,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create a TeacherModel from JSON
  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profilePicture'],
      bio: json['bio'],
      subjects: json['subjects'] != null ? List<String>.from(json['subjects']) : null,
      schoolId: json['schoolId'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Method to convert a TeacherModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profilePicture': profilePicture,
      'bio': bio,
      'subjects': subjects,
      'schoolId': schoolId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
