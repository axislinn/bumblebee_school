import 'dart:io'; // Import for file handling
import 'package:equatable/equatable.dart'; // Optional for Equatable

abstract class PostEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreatePost extends PostEvent {
  final String? token;
  final String heading;
  final String? body;
  final String contentType;
  final String classId;
  final String schoolId;
  final List<File> contentPictures; // Now accepts multiple images
  final List<File> documents; // List of selected documents
  final String? gradeName; // Assuming this is the missing parameter
  final String className;

  CreatePost({
    this.token,
    required this.heading,
    this.body,
    required this.contentType,
    required this.classId,
    required this.schoolId,
    required this.contentPictures, // Optionally pass an image file here
    required this.documents, // Ensure this is defined
    this.gradeName,
    required this.className,
  });

  @override
  List<Object?> get props => [
        token,
        heading,
        body,
        contentType,
        classId,
        contentPictures,
        documents, // Ensure this is included in the props
        gradeName,
        className,
      ];
}

class FetchPosts extends PostEvent {} // New event for fetching posts

class FetchAnnouncements extends PostEvent {} // Add this line for announcements

class DeletePost extends PostEvent {
  final String postId;
  DeletePost(this.postId);
}
