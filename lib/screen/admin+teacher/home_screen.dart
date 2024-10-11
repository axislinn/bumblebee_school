import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_bloc.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_event.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_state.dart';
import 'package:bumblebee_school_final/model/admin+teacher/post_model.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/post_repository.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/bottom_nav/bottom_nav.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/navi_drawer/navi_drawer_screen.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/post/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(postRepository: PostRepository())
        ..add(FetchPosts()), // Fetch posts when screen is created
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Home Screen'),
        ),
        endDrawer: const NaviDrawer(),
        body: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is PostSuccess) {
              final posts = state.posts;
              if (posts.isEmpty) {
                return Center(child: Text('No posts available'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PostBloc>().add(FetchPosts());
                },
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostWidget(post: post);
                  },
                ),
              );
            } else if (state is PostFailure) {
              return Center(
                  child: Text('Failed to load posts: ${state.error}'));
            } else {
              return Center(child: Text('Unexpected error occurred.'));
            }
          },
        ),
        floatingActionButton: _currentIndex == 0
            ? Padding(
                padding: const EdgeInsets.only(bottom: 70.0),
                child: FloatingActionButton(
                  onPressed: () {
                    _navigateToCreatePostScreen(context);
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.grey,
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomNav(
          // selectedIndex: _currentIndex,
          // onItemTapped: (index) {
          //   setState(() {
          //     _currentIndex = index;
          //   });
          // },
        ),
      ),
    );
  }

  void _navigateToCreatePostScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => PostBloc(postRepository: PostRepository()),
          child: CreatePostScreen(),
        ),
      ),
    ).then((_) {
      if (_currentIndex == 0) {
        context.read<PostBloc>().add(FetchPosts());
      }
    });
  }
}

class PostWidget extends StatelessWidget {
  final PostModel post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

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
                      Text(
                        post.postedBy?.userName ?? 'Anonymous',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (post.school?.schoolName != null)
                        Text(
                          post.school!.schoolName,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
