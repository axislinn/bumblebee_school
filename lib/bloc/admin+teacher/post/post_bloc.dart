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

      if (token == null || schoolId == null) {
        emit(PostFailure('Authentication token or School ID not found'));
        return;
      }

      // Convert List<File> to List<String> (file paths or base64 encoded)
      final List<String> imagePaths =
          event.contentPictures.map((file) => file.path).toList();
      final List<String> documentPaths =
          event.documents.map((file) => file.path).toList();

      // Debug print to verify
      print('Image Paths: $imagePaths');
      print('Document Paths: $documentPaths');

      ApiResponse result;

      if (event.contentType == 'announcement') {
        result = await postRepository.createAnnouncement(
          token,
          event.heading,
          event.classId,
          schoolId,
          imagePaths,
          documentPaths,
          event.gradeName,
          event.className,
          event.contentType,
        );
      } else if (event.contentType == 'feed') {
        result = await postRepository.createFeedPost(
          token,
          event.heading,
          schoolId,
          imagePaths,
          documentPaths,
          event.gradeName,
          event.className,
          event.contentType,
        );
      } else {
        emit(PostFailure('Invalid content type'));
        return;
      }

      if (result.success) {
        emit(PostSuccess([])); // You can pass actual post data if necessary
      } else {
        emit(PostFailure(result.message));
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
