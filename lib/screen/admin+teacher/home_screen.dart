import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_bloc.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_event.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_state.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/announcement_widget.dart';
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
  bool _hasFetchedData = false; // Flag to check if data has been fetched

  @override
  void initState() {
    super.initState();
    // Fetch posts and announcements only if they haven't been fetched yet
    _fetchInitialData();
  }

  void _fetchInitialData() {
    // Check if data has already been fetched
    if (!_hasFetchedData) {
      context.read<PostBloc>().add(FetchPosts());
      context.read<PostBloc>().add(FetchAnnouncements());
      _hasFetchedData = true; // Set flag to true after fetching
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home Screen'),
      ),
      endDrawer: const NaviDrawer(),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostSuccess) {
            final allItems = [...state.posts, ...state.announcements];

            if (allItems.isEmpty) {
              return const Center(
                  child: Text('No posts or announcements available'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Re-fetch posts and announcements if needed
                context.read<PostBloc>().add(FetchPosts());
                context.read<PostBloc>().add(FetchAnnouncements());
              },
              child: ListView.builder(
                itemCount: allItems.length,
                itemBuilder: (context, index) {
                  final item = allItems[index];

                  if (item.contentType == "feed") {
                    return PostWidget(
                      post: item,
                      onDelete: (id) {
                        context.read<PostBloc>().add(DeletePost(id));
                      },
                    );
                  } else if (item.contentType == "announcement") {
                    return AnnouncementWidget(
                      post: item,
                      onDelete: (id) {
                        context.read<PostBloc>().add(DeletePost(id));
                      },
                    );
                  } else {
                    return const Center(child: Text('Unknown content type'));
                  }
                },
              ),
            );
          } else if (state is PostFailure) {
            return Center(child: Text('Failed to load posts: ${state.error}'));
          } else {
            return const Center(child: Text('Unexpected error occurred.'));
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
                child: const Icon(Icons.add),
                backgroundColor: Colors.grey,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomNav(),
    );
  }

  void navigateToCreatePostScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(
          onPostCreated: () {
            // After creating a post, you can optionally fetch again if needed
            // context.read<PostBloc>().add(FetchPosts());
            // context.read<PostBloc>().add(FetchAnnouncements());
          },
        ),
      ),
    ).then((_) {
      // Optionally, if you want to refetch data when coming back from CreatePostScreen
      // Uncomment the following lines if you want to refresh the data when coming back
      // _fetchInitialData();
    });
  }
}
