import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_bloc.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_event.dart';
import 'package:bumblebee_school_final/model/admin+teacher/post_model.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/post_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostWidget extends StatefulWidget {
  final PostModel post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  void initState() {
    super.initState();
    _onDeletePost(widget.post.id!);
  }

  Future<void> _onDeletePost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token != null) {
      try {
        // Create an instance of PostRepository
        final postRepository = PostRepository();

        final ApiResponse response =
            await postRepository.deletePost(token, postId);

        if (response.success) {
          print("Post deleted successfully: $postId");
          // Optionally refresh the UI or show a confirmation message
        } else {
          print("Failed to delete post: ${response.message}");
        }
      } catch (e) {
        print("Error deleting post: $e");
      }
    } else {
      print("User token not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedCreatedAt = widget.post.createdAt != null
        ? timeago.format(widget.post.createdAt!)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.post.postedBy != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile picture display if available
                  if (widget.post.postedBy!.profilePicture.isNotEmpty)
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(widget.post.postedBy!.profilePicture),
                      radius: 20,
                    ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the school name
                      if (widget.post.school?.schoolName != null)
                        Text(
                          widget.post.school!.schoolName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      // Display the admin's role and username
                      if (widget.post.postedBy?.userName != null)
                        Text(
                          'Admin: ${widget.post.postedBy!.userName}',
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

            // Display heading of the post
            Text(
              widget.post.heading,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Display content type: either Feed or Announcement
            Text(
              'Type: ${widget.post.contentType == "announcement" ? "Announcement" : "Feed"}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // Display post body if available
            if (widget.post.body?.isNotEmpty ?? false)
              Text(
                widget.post.body!,
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 10),

            // Display content pictures if available
            if (widget.post.contentPictures != null &&
                widget.post.contentPictures!.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.post.contentPictures!.length,
                  itemBuilder: (context, index) {
                    final pictureUrl = widget.post.contentPictures![index];
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
            if (widget.post.documents != null &&
                widget.post.documents!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attached Documents:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  ...widget.post.documents!.map((doc) => GestureDetector(
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

            // Reactions section
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up, color: Colors.blue),
                  onPressed: () {
                    // Handle like/reaction logic
                  },
                ),
                const SizedBox(width: 5),
                Text('${widget.post.reactions ?? 0} Reactions'),
                const Spacer(), // Spacer to push delete button to the right
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    final postBloc = BlocProvider.of<PostBloc>(context);
                    _confirmDelete(context, postBloc, widget.post.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PostBloc postBloc, String? postId) {
    if (postId == null) {
      // Optionally show a message or handle the null case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot delete the post. Post ID is missing.')),
      );
      return;
    }

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
                // Use the passed PostBloc instead of BlocProvider.of<PostBloc>(context)
                postBloc.add(DeletePost(postId));
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
