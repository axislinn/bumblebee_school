import 'dart:io';

import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_event.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_state.dart';
import 'package:bumblebee_school_final/model/admin+teacher/post_model.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/post_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;

  PostBloc({required this.postRepository}) : super(PostInitial()) {
    // Register event handlers
    on<CreatePost>(_onCreatePost);
    on<FetchPosts>(_onFetchPosts);
  }

// // File-to-MultipartFile conversion function
  Future<http.MultipartFile> fileToMultipartFile(
      File file, String fieldName) async {
    final mimeType = lookupMimeType(file.path)?.split('/');
    if (mimeType == null) {
      throw Exception('Unable to determine mime type for file: ${file.path}');
    }

    return await http.MultipartFile.fromPath(
      fieldName,
      file.path,
      contentType: MediaType(mimeType[0], mimeType[1]),
    );
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<PostState> emit) async {
    emit(PostLoading());

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('userToken');
      final String? schoolId = prefs.getString('schoolId');

      if (token == null || schoolId == null) {
        emit(PostFailure('Authentication token or School ID not found'));
        return;
      }

      // Convert List<File> to List<MultipartFile> for images and documents
      final List<http.MultipartFile> imageFiles = await Future.wait(
        event.contentPictures
            .map((image) => fileToMultipartFile(image, 'contentPictures'))
            .toList(),
      );

      final List<http.MultipartFile> documentFiles = await Future.wait(
        event.documents
            .map((document) => fileToMultipartFile(document, 'documents'))
            .toList(),
      );

      // API Call based on content type
      if (event.contentType == 'announcement') {
        final result = await postRepository.createAnnouncement(
          token,
          event.heading,
          event.body,
          event.classId,
          schoolId,
          imageFiles,
          documentFiles,
          event.gradeName,
          event.className,
          event.contentType,
        );

        if (result.success) {
          emit(PostSuccess([])); // Handle success
        } else {
          emit(PostFailure(result.message)); // Handle failure
        }
      } else if (event.contentType == 'feed') {
        final result = await postRepository.createFeedPost(
          token,
          event.heading,
          event.body,
          schoolId,
          imageFiles,
          documentFiles,
          event.contentType,
        );

        if (result.success) {
          emit(PostSuccess([])); // Handle success
        } else {
          emit(PostFailure(result.message)); // Handle failure
        }
      } else {
        emit(PostFailure('Invalid content type'));
      }
    } catch (e) {
      emit(PostFailure('An error occurred while creating the post: $e'));
    }
  }

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());

    try {
      // Retrieve token from SharedPreferences for authentication
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      // Fetch posts from the repository
      final List<PostModel> posts = await postRepository.fetchPosts(token);

      // Emit the loaded state with the fetched posts
      emit(PostSuccess(posts));
    } catch (e) {
      // Log the error for debugging
      print("An error occurred while fetching posts: $e");
      emit(PostFailure('An error occurred: $e'));
    }
  }
}
