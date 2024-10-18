import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_bloc.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_event.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_state.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/body_widget.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/bottom_nav/bottom_nav.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/navi_drawer/navi_drawer_screen.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/post/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch posts when the HomeScreen is initialized
    context.read<PostBloc>().add(FetchPosts());
    context.read<PostBloc>().add(FetchAnnouncements());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            final allPosts = [...state.posts, ...state.announcements];
            if (allPosts.isEmpty) {
              return Center(child: Text('No posts available'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                // Fetch posts again when the user pulls down
                context.read<PostBloc>().add(FetchPosts());
                context.read<PostBloc>().add(FetchAnnouncements());
              },
              child: ListView.builder(
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                  final post = allPosts[index];
                  return PostWidget(
                    post: post,
                    onDelete: (String postId) {
                      // Trigger the delete action
                      context.read<PostBloc>().add(DeletePost(postId));
                    },
                  );
                },
              ),
            );
          } else if (state is PostFailure) {
            return Center(child: Text('Failed to load posts: ${state.error}'));
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
                  navigateToCreatePostScreen(context);
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.grey,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomNav(
          // Uncomment and implement the navigation logic as needed
          // selectedIndex: _currentIndex,
          // onItemTapped: (index) {
          //   setState(() {
          //     _currentIndex = index;
          //   });
          // },
          ),
    );
  }

  void navigateToCreatePostScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(
          onPostCreated: () {
            // This function will be called when a post is created
            context.read<PostBloc>().add(FetchPosts());
            context.read<PostBloc>().add(FetchAnnouncements());
          },
        ),
      ),
    );
  }
}
