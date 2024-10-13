import 'package:bumblebee_school_final/model/admin+teacher/class_model.dart';
import 'package:bumblebee_school_final/model/admin+teacher/post_by_model.dart';
import 'package:bumblebee_school_final/model/admin/school_model.dart';

class PostModel {
  final String? id;
  final String heading;
  final String? body;
  final List<String>? documents; // Keep as List<String> for flexibility
  final List<String>? contentPictures; // Support multiple images
  final String contentType;
  final int? reactions;
  final String? classId;
  final String? schoolId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PostedByModel? postedBy;

  // Referencing school and class as objects
  final SchoolModel? school;
  final ClassModel? classModel;

  PostModel({
    this.id,
    required this.heading,
    this.body,
    this.contentPictures,
    this.documents,
    required this.contentType,
    this.reactions,
    this.classId,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.postedBy,
    this.school,
    this.classModel,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'],
      heading: json['heading'] ?? '',
      body: json['body'],
      contentPictures: json['contentPictures'] != null
          ? List<String>.from(json['contentPictures'])
          : null,
      documents: json['documents'] != null
          ? List<String>.from(json['documents'])
          : null,
      contentType: json['contentType'] ?? '',
      reactions: json['reactions'] ?? 0,
      classId: json['classId'] is Map
          ? json['classId']['id'] as String?
          : json['classId'] as String?, // Handle null safely
      schoolId: json['schoolId'] is Map
          ? json['schoolId']['id'] as String?
          : json['schoolId'] as String?, // Handle null safely
      school:
          json['school'] != null ? SchoolModel.fromJson(json['school']) : null,
      classModel:
          json['class'] != null ? ClassModel.fromJson(json['class']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      postedBy: json['posted_by'] != null
          ? PostedByModel.fromJson(json['posted_by'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'heading': heading,
      'body': body,
      'contentPictures': contentPictures,
      'documents': documents,
      'contentType': contentType,
      'reactions': reactions,
      'classId': classId,
      'schoolId': schoolId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'posted_by': postedBy?.toJson(),
      'school': school?.toJson(),
      'class': classModel?.toJson(),
    };
  }
}
