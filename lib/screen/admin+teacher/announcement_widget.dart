import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_bloc.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_event.dart';
import 'package:bumblebee_school_final/model/admin+teacher/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnnouncementWidget extends StatelessWidget {
  final PostModel post;
  final Function(String) onDelete;

  const AnnouncementWidget({
    Key? key,
    required this.post,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building Announcement Widget for post: ${post.toJson()}');

    final formattedCreatedAt =
        post.createdAt != null ? timeago.format(post.createdAt!) : null;
    print('Formatted Created At: $formattedCreatedAt');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (post.postedBy != null &&
                    post.postedBy!.profilePicture.isNotEmpty)
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
                        'Posted by: ${post.postedBy!.userName}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    if (post.classModel?.className != null &&
                        post.classModel?.grade != null)
                      Text(
                        'Class: ${post.classModel!.className}, Grade: ${post.classModel!.grade}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'Delete') {
                      if (post.id != null) {
                        _confirmDelete(context,
                            post.id); // Proceed with deletion if ID is valid
                      } else {
                        // Show message if post ID is missing
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Announcement ID is missing. Cannot delete post.'),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'Delete',
                        child: Text('Delete Post'),
                      ),
                    ];
                  },
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
                          print('Document tapped: $doc');
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
                    print('Like button pressed for post ID: ${post.id}');
                  },
                ),
                const SizedBox(width: 5),
                Text('${post.reactions ?? 0} Reactions'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String? postId) {
    if (postId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Cannot delete the announcement. Announcement ID is missing.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this announcement?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                context.read<PostBloc>().add(DeletePost(postId));
                Navigator.of(context).pop();
                onDelete(postId);
                print('Announcement deleted: $postId');
              },
            ),
          ],
        );
      },
    );
  }
}
