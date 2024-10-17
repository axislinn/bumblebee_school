import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_bloc.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_event.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_state.dart';
import 'package:bumblebee_school_final/model/admin+teacher/post_model.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/post_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostListWidget extends StatefulWidget {
  @override
  _PostListWidgetState createState() => _PostListWidgetState();
}

class _PostListWidgetState extends State<PostListWidget> {
  late PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _postBloc = BlocProvider.of<PostBloc>(context);
    _postBloc.add(FetchPosts());
  }

  void _onDeletePost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token != null) {
      try {
        final postRepository = PostRepository();
        final ApiResponse response =
            await postRepository.deletePost(token, postId);

        if (response.success) {
          // Trigger the deletion event in the bloc
          _postBloc.add(DeletePost(postId));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to delete post: ${response.message}')),
          );
        }
      } catch (e) {
        print("Error deleting post: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting post')),
        );
      }
    } else {
      print("User token not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is PostSuccess) {
          final posts = state.posts; // Updated list of posts
          if (posts.isEmpty) {
            return Center(child: Text('No posts available.'));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                title: Text(post.heading),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Dispatch delete post event
                    context.read<PostBloc>().add(
                        DeletePost(post.id!)); // Ensure post.id is available
                  },
                ),
              );
            },
          );
        } else if (state is PostFailure) {
          return Center(child: Text(state.error));
        }
        return Center(child: Text('Something went wrong.'));
      },
    );
  }
}

class PostWidget extends StatelessWidget {
  final PostModel post;
  final Function(String) onDelete;

  const PostWidget({
    Key? key,
    required this.post,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedCreatedAt =
        post.createdAt != null ? timeago.format(post.createdAt!) : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.postedBy != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (post.postedBy!.profilePicture.isNotEmpty)
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(post.postedBy!.profilePicture),
                      radius: 20,
                    ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.school?.schoolName != null)
                        Text(
                          post.school!.schoolName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      if (post.postedBy?.userName != null)
                        Text(
                          'Admin: ${post.postedBy!.userName}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 10),
            if (formattedCreatedAt != null)
              Text(
                'Posted $formattedCreatedAt',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(height: 10),
            Text(
              post.heading,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Type: ${post.contentType == "announcement" ? "Announcement" : "Feed"}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 10),
            if (post.body?.isNotEmpty ?? false)
              Text(
                post.body!,
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 10),
            if (post.contentPictures != null &&
                post.contentPictures!.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.contentPictures!.length,
                  itemBuilder: (context, index) {
                    final pictureUrl = post.contentPictures![index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: pictureUrl.isNotEmpty
                          ? Image.network(
                              pictureUrl,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox(),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),

            // Display attached documents if available
            if (post.documents != null && post.documents!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attached Documents:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  ...post.documents!.map((doc) => GestureDetector(
                        onTap: () {
                          // Handle document click
                        },
                        child: Text(
                          doc,
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              decoration: TextDecoration.underline),
                        ),
                      )),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up, color: Colors.blue),
                  onPressed: () {
                    // Handle like/reaction logic
                  },
                ),
                const SizedBox(width: 5),
                Text('${post.reactions ?? 0} Reactions'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmDelete(context, post.id!);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                onDelete(postId); // Call the onDelete callback
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
