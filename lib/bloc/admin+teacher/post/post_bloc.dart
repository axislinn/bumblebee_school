import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_event.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_state.dart';
import 'package:bumblebee_school_final/model/admin+teacher/post_model.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/post_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;

  PostBloc({required this.postRepository}) : super(PostInitial()) {
    // Register event handlers
    on<CreatePost>(_onCreatePost);
    on<FetchPosts>(_onFetchPosts);
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<PostState> emit) async {
    emit(PostLoading());

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('userToken');
      final String? schoolId = prefs.getString('schoolId');

      print("Token: $token");
      print("SchoolId: $schoolId");

      if (token == null || schoolId == null) {
        print('Authentication token or School ID not found');
        emit(PostFailure('Authentication token or School ID not found'));
        return;
      }

      // Convert List<File> to List<String> (file paths) for images and documents
      final List<String> imagePaths =
          event.contentPictures.map((image) => image.path).toList();
      final List<String> documentPaths =
          event.documents.map((document) => document.path).toList();

      print("Submitting Post with details:");
      print("Heading: ${event.heading}");
      print("ContentType: ${event.contentType}");
      print("ClassId: ${event.classId}");
      print("SchoolId: $schoolId");
      print("ContentPictures: $imagePaths");
      print("Documents: $documentPaths");
      print("GradeName: ${event.gradeName}");

      // Check the content type and call the appropriate method
      if (event.contentType == 'announcement') {
        // Call the announcement post creation
        final result = await postRepository.createAnnouncement(
          token, // Token
          event.heading, // Heading
          event.classId, // Class ID
          schoolId, // School ID
          imagePaths, // Image paths
          documentPaths, // Document paths
          event.gradeName, // Grade Name
          event.className, // Class Name
          event.contentType,
        );

        if (result.success) {
          emit(PostSuccess([])); // Adjust the success state as necessary
        } else {
          print('Failed to create announcement: ${result.message}');
          emit(PostFailure(result.message));
        }
      } else if (event.contentType == 'feed') {
        // Call the feed post creation
        final result = await postRepository.createFeedPost(
          token, // Token
          event.heading, // Heading
          schoolId, // School ID
          imagePaths, // Image paths
          documentPaths, // Document paths
          event.gradeName, // Grade Name
          event.className, // Class Name
          event.contentType,
        );

        if (result.success) {
          emit(PostSuccess([])); // Adjust the success state as necessary
        } else {
          print('Failed to create feed post: ${result.message}');
          emit(PostFailure(result.message));
        }
      } else {
        print('Invalid content type: ${event.contentType}');
        emit(PostFailure('Invalid content type'));
      }
    } catch (e) {
      print("An error occurred while creating the post: $e");
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
